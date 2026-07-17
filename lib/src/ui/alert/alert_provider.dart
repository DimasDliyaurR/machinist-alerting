import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:masinis_helper/src/core/app_constant.dart';
import 'package:masinis_helper/src/extension/foreground_alert.dart';
import 'package:masinis_helper/src/extension/location_ext.dart';
import 'package:masinis_helper/src/extension/permission_ext.dart';
import 'package:masinis_helper/src/helper/foreground_helper.dart';

class AlertProvider extends ChangeNotifier with LocationExt, PermissionExt {
  bool isListening = false;
  bool isFinish = true;
  int radius = 10;
  int indexRoute = 0;
  Color color = Colors.grey;
  double currentDistance = 0.0;
  String? nameStation;
  String? accuracyGps;
  bool isReadyToGo = false;

  List<Map<String, dynamic>> allStations = [];

  final List<Map<String, dynamic>> selectedStations = [];

  List<Map<String, dynamic>>? routeTrain;

  StatusPosition? currentStatus;

  RecordRepository recordRepository;

  StreamSubscription<Position>? _locationSubscription;

  AlertProvider(this.recordRepository) {
    _prepareForeground();
    _onInit();
    loadStations();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }

  Future<void> _onInit() async {
    isListening = await FlutterForegroundTask.isRunningService;
    isFinish = !isListening;
    if (!isFinish) {
      List<Map<String, dynamic>>? stations =
          await getDataForeground<List<Map<String, dynamic>>>(
            key: KeyUtil.routeTrain,
          );
      if (stations != null) {
        routeTrain = stations;
      }
    }
    notifyListeners();
  }

  Future<void> loadStations() async {
    final data = await recordRepository.getRecord(50);
    allStations = data;
    notifyListeners();
  }

  bool _isSameStation(Map<String, dynamic> a, Map<String, dynamic> b) {
    return a['nama'] == b['nama'] &&
        a['latitude'] == b['latitude'] &&
        a['longitude'] == b['longitude'];
  }

  bool isSelected(Map<String, dynamic> station) {
    return selectedStations.any((e) => _isSameStation(e, station));
  }

  void toggleStation(Map<String, dynamic> station) {
    if (isSelected(station)) {
      selectedStations.removeWhere((e) => _isSameStation(e, station));
    } else {
      selectedStations.add(station);
    }
    notifyListeners();
  }

  String? get validationError {
    if (selectedStations.length < 2) {
      return "Pilih lebih dari 1 stasiun untuk memulai";
    }
    return null;
  }

  bool get canStart => selectedStations.length > 1;

  bool get isNear => currentStatus == StatusPosition.near;

  bool get isLastStation =>
      routeTrain != null && indexRoute >= (routeTrain!.length - 1);

  void _onReceiveTaskData(Object data) async {
    if (data is Map<String, dynamic>) {
      if (data["listen_status"] != null) {
        if (data["listen_status"] == "STATUS:STOPING") {
          stopListen();
        }
      } else {
        currentDistance = data["currentDistance"];
        nameStation = data["nama"];
        accuracyGps = data["accuracyGps"];
        currentStatus = KeyUtil.textToPosition(data["distance"]);
        color = KeyUtil.getColor<StatusPosition?>(currentStatus)!;
      }

      notifyListeners();
    }
  }

  void nextRoute() async {
    if (routeTrain == null) return;
    if (isLastStation) isFinish = true;

    indexRoute++;
    await saveDataForeground(key: KeyUtil.indexTrain, value: indexRoute);
    stopListen();
    _startForeground();
    _onInit();
  }

  void _startForeground() async {
    final notifPerm = await FlutterForegroundTask.checkNotificationPermission();
    if (notifPerm != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (routeTrain != null) {
      await saveDataForeground(
        key: KeyUtil.routeTrain,
        value: routeTrain as List<Map<String, dynamic>>,
      );

      await saveDataForeground(key: KeyUtil.indexTrain, value: indexRoute);
    }

    if (await FlutterForegroundTask.isRunningService == false) {
      final result = await FlutterForegroundTask.startService(
        notificationTitle: 'Machinis Alert Mulai',
        notificationText: 'Sedang memindai stasiun di sekitar Anda...',
        notificationButtons: [
          const NotificationButton(id: 'btn_stop', text: "Berhenti"),
        ],
        callback: startCallback,
      );

      if (result is ServiceRequestFailure) {
        debugPrint("Gagal : ${result.error}");
      }
    }
  }

  void _prepareForeground() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'channel_machinis_alert_v2',
        channelName: 'Notifikasi Machinis Alert',
        channelDescription: 'Mengaktifkan Notifikasi Machinis Alert',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(2000),
        autoRunOnBoot: false,
        allowWakeLock: true,
      ),
    );
  }

  bool startListen() {
    if (isListening) return true;
    if (!canStart) return false;

    routeTrain = List<Map<String, dynamic>>.from(selectedStations);
    currentStatus = null;

    isListening = true;
    _startForeground();
    notifyListeners();
    return true;
  }

  void stopListen() async {
    if (isListening) {
      FlutterForegroundTask.stopService();
      _locationSubscription?.cancel();
      isListening = false;
      color = Colors.grey;
      currentStatus = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    FlutterForegroundTask.stopService();
    indexRoute = 0;
    super.dispose();
  }
}
