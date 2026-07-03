import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum StatusPosition { near, medium, far }

class KeyUtil {
  static const String home = "home";
  static const String record = "record";
  static const String alert = "alert";

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

  static Color? getColor(int scale) {
    StatusPosition? status = getPosition(scale);
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
