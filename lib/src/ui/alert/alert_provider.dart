import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:masinis_helper/src/core/app_constant.dart';
import 'package:masinis_helper/src/extension/location_ext.dart';
import 'package:masinis_helper/src/helper/harvesine_formula.dart';
import 'package:masinis_helper/src/repository/record_repository.dart';

class AlertProvider extends ChangeNotifier with LocationExt {
  final RecordRepository _recordRepository;
  bool isListening = false;
  int radius = 10;
  Color color = Colors.grey;
  double currentDistance = 0.0;
  String? nameStation;
  String? accuracyGps;

  StreamSubscription<LocationData>? _locationSubscription;

  AlertProvider(this._recordRepository);

  void startListen() async {
    if (isListening) return;

    isListening = true;
    notifyListeners();

    List<Map<String, dynamic>> data = await _recordRepository.getRecord(50);

    _locationSubscription = await locationTracker((
      LocationData? currentLocation,
    ) {
      if (currentLocation == null ||
          currentLocation.latitude == null ||
          currentLocation.longitude == null) {
        return;
      }

      print("Accuration 🔥: ${currentLocation.accuracy}");

      double closestDistance = double.infinity;
      Map<String, dynamic>? candidate;

      for (var row in data) {
        double lat = double.parse(row["latitude"].toString());
        double lon = double.parse(row["longitude"].toString());

        double distance = haversineFormula(
          distanceLat: lat,
          distanceLong: lon,
          currentLat: currentLocation.latitude!,
          currentLon: currentLocation.longitude!,
        );

        print("=" * 50);
        print(
          "latitude ${currentLocation.latitude} => longitude ${currentLocation.longitude}",
        );
        print("distance $distance => closestDistance $closestDistance");
        print(distance <= closestDistance);
        if (distance <= closestDistance) {
          print("distance => $distance");
          closestDistance = distance;
          candidate = row;
        }
      }

      print("Closest Distance 🔥: $closestDistance");
      if (closestDistance <= radius) {
        accuracyGps = currentLocation.accuracy.toString();
        currentDistance = closestDistance;
        nameStation = candidate?["nama"];
        double scale = (closestDistance / radius) * 100;
        color = KeyUtil.getColor(scale.toInt())!;
      } else {
        currentDistance = closestDistance;
        color = Colors.grey;
      }

      print("=" * 50);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
