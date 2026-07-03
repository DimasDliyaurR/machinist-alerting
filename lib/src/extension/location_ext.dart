import 'dart:async';
import 'package:location/location.dart';

mixin LocationExt {
  final Location _location = Location();

  Future<bool> permissionState() async {
    if (!await _location.serviceEnabled() &&
        !await _location.requestService()) {
      return false;
    }

    if (await _location.hasPermission() == PermissionStatus.denied &&
        await _location.requestPermission() != PermissionStatus.granted) {
      return false;
    }

    return true;
  }

  Future<LocationData?> getCurrentLocation() async {
    await _location.changeSettings(accuracy: LocationAccuracy.high);
    bool checkPermission = await permissionState();
    if (!checkPermission) {
      return null;
    }
    return await _location.getLocation();
  }

  Future<StreamSubscription<LocationData>?> locationTracker(
    void Function(LocationData currentLocation) wrapper,
  ) async {
    bool checkPermission = await permissionState();
    if (!checkPermission) return null;

    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
      distanceFilter: 0,
    );

    return _location.onLocationChanged.listen(wrapper);
  }
}
