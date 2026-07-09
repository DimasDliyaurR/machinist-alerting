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

  static String? positionToText(StatusPosition? status) {
    if (status == null) {
      return null;
    }

    switch (status) {
      case StatusPosition.near:
        return "near";
      case StatusPosition.medium:
        return "medium";
      case StatusPosition.far:
        return "far";
    }
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
