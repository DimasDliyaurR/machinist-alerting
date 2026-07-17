import 'package:flutter/material.dart';
import 'package:masinis_helper/src/dto/route_dto.dart';
import 'package:masinis_helper/src/extension/permission_ext.dart';
import 'package:masinis_helper/src/repositories/route_repository.dart';

class HomeProvider extends ChangeNotifier with PermissionExt {
  final RouteRepository _routeRepository;
  bool statusPermission = false;

  HomeProvider(this._routeRepository) {
    getData();
  }

  Future<void> checkPermission() async {
    statusPermission = await permissionState(withAction: false);
    notifyListeners();
  }

  Future<void> actionPermission() async {
    statusPermission = await permissionState();
    notifyListeners();
  }

  List<RouteDto> _record = [];
  List<RouteDto> get record => _record;

  Future<void> getData() async {
    _record = await _routeRepository.getAll(50) ?? [];
    notifyListeners();
  }
}
