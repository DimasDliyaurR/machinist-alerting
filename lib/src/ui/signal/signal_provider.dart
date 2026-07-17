import 'package:flutter/material.dart';
import 'package:masinis_helper/src/dto/signal_dto.dart';
import 'package:masinis_helper/src/extension/location_ext.dart';
import 'package:masinis_helper/src/repositories/signal_repository.dart';

class SignalProvider extends ChangeNotifier with LocationExt {
  final SignalRepository _signalRepository;
  String? errorMessage;
  bool isLoading = false;

  SignalProvider(this._signalRepository) {
    getData();
  }

  List<SignalDto> _signal = [];
  List<SignalDto> get signal => _signal;

  Future<void> getData() async {
    _signal = await _signalRepository.getAll(50) ?? [];
    notifyListeners();
  }

  Future<int> submitForm(SignalDto signal) async {
    isLoading = true;
    notifyListeners();
    final int result = await _signalRepository.insert(signal);

    isLoading = false;

    if (result > 0) {
      getData();
    }

    return result;
  }
}
