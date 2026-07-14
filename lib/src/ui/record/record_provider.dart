import 'package:flutter/material.dart';
import 'package:masinis_helper/src/dto/record_dto.dart';
import 'package:masinis_helper/src/extension/location_ext.dart';
import 'package:masinis_helper/src/repository/record_repository.dart';

class RecordModel {
  bool isLoading;
  String errorMessage;

  RecordModel({required this.isLoading, required this.errorMessage});
}

class RecordProvider extends ChangeNotifier with LocationExt {
  final RecordRepository _recordRepository;
  RecordModel recordModel = RecordModel(isLoading: false, errorMessage: "");

  RecordProvider(this._recordRepository) {
    getData();
  }

  List<Map<String, dynamic>> _record = [];
  List<Map<String, dynamic>> get record => _record;

  Future<int?> submitForm({required RecordDto record}) async {
    recordModel.isLoading = true;
    recordModel.errorMessage = "";
    notifyListeners();
    final result = await _recordRepository.insertRecord(record: record);
    recordModel.isLoading = false;
    if (result > 0) {
      await getData();
    }
    notifyListeners();

    return result;
  }

  Future<void> getData() async {
    _record = await _recordRepository.getRecord(50);
    notifyListeners();
  }
}
