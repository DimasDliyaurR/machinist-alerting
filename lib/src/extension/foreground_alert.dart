import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:masinis_helper/src/core/app_constant.dart';
import 'package:masinis_helper/src/extension/location_ext.dart';
import 'package:masinis_helper/src/helper/foreground_helper.dart';
import 'package:masinis_helper/src/helper/harvesine_formula.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundAlert());
}

class ForegroundAlert extends TaskHandler with LocationExt {
  int radius = 10;
  int? index;
  List<Map<String, dynamic>>? data;
  bool _isStop = false;
  bool _isPlayingAlarm = false;
  ForegroundAlert();
  StreamSubscription<Position>? _locationSubscription;

  late AudioPlayer player;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    player = AudioPlayer();

    _locationSubscription = await locationTracker((
      Position? currentLocation,
    ) async {
      if (_isStop) {
        return;
      }

      if (currentLocation == null) {
        return;
      }

      double closestDistance = double.infinity;
      Map<String, dynamic>? candidate;

      data = await getDataForeground<List<Map<String, dynamic>>>(
        key: KeyUtil.routeTrain,
      );

      index = await getDataForeground<int>(key: KeyUtil.indexTrain);

      if (data != null && index != null) {
        Map<String, dynamic> row = data![index!];
        double lat = double.parse(row["latitude"].toString());
        double lon = double.parse(row["longitude"].toString());

        double distance = haversineFormula(
          distanceLat: lat,
          distanceLong: lon,
          currentLat: currentLocation.latitude,
          currentLon: currentLocation.longitude,
        );

        if (distance <= closestDistance) {
          closestDistance = distance;
          candidate = row;
        }
      }

      if (closestDistance <= radius) {
        double scale = (closestDistance / radius) * 100;
        StatusPosition? position = KeyUtil.getPosition(scale.toInt());

        FlutterForegroundTask.sendDataToMain({
          "currentDistance": closestDistance,
          "accuracyGps": currentLocation.accuracy.toString(),
          "nama": candidate?["nama"],
          "distance": KeyUtil.enumToText<StatusPosition>(
            KeyUtil.getPosition(scale.toInt()),
          ),
        });

        FlutterForegroundTask.updateService(
          notificationTitle: 'Machinis Alert',
          notificationText:
              '${candidate == null ? "-" : candidate["nama"]} | ${KeyUtil.enumToText<StatusPosition>(KeyUtil.getPosition(scale.toInt()))}',
        );

        if (position == StatusPosition.near) {
          if (!_isPlayingAlarm) {
            _isPlayingAlarm = true;

            try {
              await player.setAsset("assets/sounds/alarm.wav");
              await player.play();

              await Future.delayed(const Duration(seconds: 5));

              await player.stop();
            } catch (e) {
              debugPrint("Terjadi error pada just_audio: $e");
            } finally {
              // 3. Buka kuncinya kembali setelah selesai atau jika terjadi error
              _isPlayingAlarm = false;
            }
          } else {
            debugPrint("Audio Masih sibuk");
          }
        }
      } else {
        FlutterForegroundTask.sendDataToMain({
          "currentDistance": closestDistance,
          "accuracyGps": currentLocation.accuracy.toString(),
          "nama": candidate == null ? "" : candidate["nama"],
          "distance": KeyUtil.enumToText<StatusPosition>(StatusPosition.far),
        });
      }
    }, runInBackground: true);
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  void onNotificationButtonPressed(String id) async {
    if (id == 'btn_stop') {
      _isStop = false;

      FlutterForegroundTask.updateService(
        notificationTitle: 'Machinis Alert',
        notificationText: 'Sedang memindai rambu...',
        notificationButtons: [
          const NotificationButton(id: 'btn_stop', text: 'Berhenti'),
        ],
      );

      FlutterForegroundTask.sendDataToMain({'listen_status': 'STATUS:STOPING'});
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _locationSubscription?.cancel();
    FlutterForegroundTask.stopService();
  }
}
