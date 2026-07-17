import 'package:flutter/material.dart';

enum StatusPosition { near, medium, far }

enum TipeSignal { meninggalkan, berangkat }

class KeyUtil {
  static const String home = "home";
  static const String record = "record";
  static const String signal = "signal";
  static const String alert = "alert";

  static const String routeTrain = "route_train";
  static const String indexTrain = "index_train";

  static StatusPosition? getPosition(int percentage) {
    if (percentage <= 30) {
      return StatusPosition.near;
    } else if (percentage <= 70) {
      return StatusPosition.medium;
    } else if (percentage <= 100) {
      return StatusPosition.far;
    }
    return null;
  }

  static String? enumToText<T extends Enum>(T? status) {
    if (status == null) {
      return null;
    }

    return status.name;
  }

  static StatusPosition? textToPosition(String? text) {
    if (text == null) {
      return null;
    }

    switch (text) {
      case "near":
        return StatusPosition.near;
      case "medium":
        return StatusPosition.medium;
      case "far":
        return StatusPosition.far;
    }

    return null;
  }

  static Color? getColor<T>(T scale) {
    StatusPosition? status;

    if (scale is int) {
      status = getPosition(scale);
    } else if (scale is StatusPosition) {
      status = scale;
    }
    switch (status) {
      case StatusPosition.near:
        return Colors.red;
      case StatusPosition.medium:
        return Colors.orange;
      case StatusPosition.far:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
