import 'dart:async';
import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:flutter/foundation.dart';

mixin LocationExt {
  Future<bool> permissionState() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        return false;
      }
    }

    LocationPermission permissionGranted = await Geolocator.checkPermission();

    if (permissionGranted == LocationPermission.denied) {
      permissionGranted = await Geolocator.requestPermission();
      if (permissionGranted == LocationPermission.denied) {
        return false;
      }
    }

    if (permissionGranted == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    if (Platform.isAndroid) {
      bool isIgnoringBattery =
          await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      if (!isIgnoringBattery) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      bool canScheduleAlarms =
          await FlutterForegroundTask.canScheduleExactAlarms;
      if (!canScheduleAlarms) {
        await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      }
    }

    return true;
  }

  Future<Position?> getCurrentLocation() async {
    bool hasPermission = await permissionState();

    if (!hasPermission) {
      print("Akses lokasi dibatalkan karena izin ditolak oleh pengguna.");
      return null;
    }

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } catch (e) {
      print("Terjadi kesalahan saat mengambil posisi: $e");
      return null;
    }
  }

  Future<StreamSubscription<Position>?> locationTracker(
    void Function(Position? currentLocation) wrapper, {
    bool runInBackground = false, // Tambahkan ini
  }) async {
    print("Location Tracker 1 🔥🔥");

    // Jangan cek permission lagi jika jalan di background, karena
    // pasti sudah dicek di UI sebelum service dinyalakan.
    if (!runInBackground) {
      bool checkPermission = await permissionState();
      print("Location Tracker 2 🔥🔥");
      if (!checkPermission) return null;
    }

    print("Location Tracker 3 🔥🔥");
    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Ubah sesuai kebutuhan (misal 5 meter)
        // 1. Paksa minta data setiap x detik (misal: 2 detik)
        intervalDuration: const Duration(seconds: 2),

        // 2. (Opsional tapi sering membantu) Paksa pakai GPS hardware langsung
        // alih-alih algoritma Google Play Services yang suka menghemat baterai
        forceLocationManager: true,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        pauseLocationUpdatesAutomatically: false, // Penting untuk iOS
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    }
    print("Location Tracker 4 🔥🔥");

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(wrapper);
  }
}
