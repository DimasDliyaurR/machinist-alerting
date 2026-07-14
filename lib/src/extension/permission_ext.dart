import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

mixin PermissionExt {
  Future<bool> permissionState({bool withAction = true}) async {
    bool status = true;

    // Enable GPS
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("serviceEnabled : $serviceEnabled 🔥🔥");
    if (!serviceEnabled) {
      if (withAction) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        print("Permission Service Enabled = $serviceEnabled 🔥🔥");
        if (!serviceEnabled) {
          status = false;
        }
      } else {
        status = false;
      }
    }

    // Enable Permission GPS
    LocationPermission permissionGranted = await Geolocator.checkPermission();
    print("permissionGranted : $permissionGranted 🔥🔥");
    if (permissionGranted == LocationPermission.denied) {
      if (withAction) {
        permissionGranted = await Geolocator.requestPermission();
        print("Permission Granted = $permissionGranted 🔥🔥");
        if (permissionGranted == LocationPermission.denied) {
          status = false;
        }
      } else {
        status = false;
      }
    }

    // Enable Permission Forever GPS
    if (permissionGranted == LocationPermission.deniedForever) {
      if (withAction) {
        bool permissionOpenSetting = await Geolocator.openAppSettings();
        print("Permission Open Settings = $permissionOpenSetting 🔥🔥");
        if (!permissionOpenSetting) {
          status = false;
        }
      } else {
        status = false;
      }
    }

    if (Platform.isAndroid) {
      // Enable ignoring battery permission
      bool isIgnoringBattery =
          await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      if (!isIgnoringBattery) {
        if (withAction) {
          isIgnoringBattery =
              await FlutterForegroundTask.requestIgnoreBatteryOptimization();
          if (!isIgnoringBattery) {
            status = false;
          }
        } else {
          status = false;
        }
      }

      // Enable can canSchedule alarm
      bool canScheduleAlarms =
          await FlutterForegroundTask.canScheduleExactAlarms;
      if (!canScheduleAlarms) {
        if (withAction) {
          canScheduleAlarms =
              await FlutterForegroundTask.openAlarmsAndRemindersSettings();
          if (canScheduleAlarms) {
            status = false;
          }
        } else {
          status = false;
        }
      }
    }

    // Enable can notification
    final notifPerm = await FlutterForegroundTask.checkNotificationPermission();
    if (notifPerm != NotificationPermission.granted) {
      if (withAction) {
        NotificationPermission permission =
            await FlutterForegroundTask.requestNotificationPermission();
        if (permission != NotificationPermission.granted) {
          return false;
        }
      } else {
        status = false;
      }
    }

    return status;
  }
}
