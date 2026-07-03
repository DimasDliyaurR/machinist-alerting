import 'package:flutter/material.dart';

import 'package:masinis_helper/src/repository/record_repository.dart';

class HomeProvider extends ChangeNotifier {
  final RecordRepository _recordRepository;

  HomeProvider(this._recordRepository) {
    getData();
  }

  List<Map<String, dynamic>> _record = [];
  List<Map<String, dynamic>> get record => _record;

  Future<void> getData() async {
    _record = await _recordRepository.getRecord(50);
    notifyListeners();
  }
}
