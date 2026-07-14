import 'package:flutter/material.dart';
import 'package:masinis_helper/src/extension/permission_ext.dart';
import 'package:masinis_helper/src/repository/record_repository.dart';

class HomeProvider extends ChangeNotifier with PermissionExt {
  final RecordRepository _recordRepository;
  bool statusPermission = false;

  HomeProvider(this._recordRepository) {
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

  List<Map<String, dynamic>> _record = [];
  List<Map<String, dynamic>> get record => _record;

  Future<void> getData() async {
    _record = await _recordRepository.getRecord(50);
    notifyListeners();
  }
}
