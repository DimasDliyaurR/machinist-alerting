import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:masinis_helper/src/core/app_constant.dart';
import 'package:masinis_helper/src/extension/foreground_alert.dart';
import 'package:masinis_helper/src/extension/location_ext.dart';
import 'package:masinis_helper/src/repository/record_repository.dart';

class AlertProvider extends ChangeNotifier with LocationExt {
  final RecordRepository _recordRepository;
  bool isListening = false;
  int radius = 10;
  Color color = Colors.grey;
  double currentDistance = 0.0;
  String? nameStation;
  String? accuracyGps;

  StreamSubscription<Position>? _locationSubscription;

  AlertProvider(this._recordRepository) {
    _prepareForeground();
    _onInit();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }

  Future<void> _onInit() async {
    isListening =
        await FlutterForegroundTask.isRunningService is ServiceRequestSuccess;
    notifyListeners();
  }

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
        color = KeyUtil.getColor<StatusPosition?>(
          KeyUtil.textToPosition(data["distance"]),
        )!;
      }

      notifyListeners();
    }
  }

  void _startForeground() async {
    final notifPerm = await FlutterForegroundTask.checkNotificationPermission();
    if (notifPerm != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
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

  void startListen() async {
    if (isListening) return;

    isListening = true;
    _startForeground();
    notifyListeners();
  }

  void stopListen() async {
    if (isListening) {
      FlutterForegroundTask.stopService();
      _locationSubscription?.cancel();
      isListening = false;
      color = Colors.grey;
      notifyListeners();
    }
  }
}
