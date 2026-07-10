import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

Future<T?> getDataForeground<T>({required String key}) async {
  try {
    if (T.toString() == 'bool' ||
        T.toString() == 'bool?' ||
        T.toString() == 'int' ||
        T.toString() == 'double' ||
        T.toString() == 'String') {
      return await FlutterForegroundTask.getData<T>(key: key);
    }

    String? rawJson = await FlutterForegroundTask.getData<String>(key: key);

    print("Get Raw Json ${T.toString()} $key : $rawJson 🪗🪗");
    if (rawJson != null) {
      var decoded = jsonDecode(rawJson);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded) as T;
      }
      print("Get Decoded Json ${key} : $decoded 🪗🪗");
      return decoded as T;
    }

    print("Noo way null 🪗🪗🪗");
    return null;
  } catch (e, stacktrace) {
    debugPrint('Exception : $stacktrace');
    return null;
  }
}

Future<bool> saveDataForeground({
  required String key,
  required Object value,
}) async {
  if (value is bool || value is int || value is double || value is String) {
    return await FlutterForegroundTask.saveData(key: key, value: value);
  }

  String jsonString = jsonEncode(value);
  // print("Save Raw Json ${key} : $jsonString 🪗🪗");
  return await FlutterForegroundTask.saveData(key: key, value: jsonString);
}

Future<void> appendDataForeground({
  required String key,
  required Map<String, dynamic> value,
}) async {
  List<dynamic> oldData = await getDataForeground(key: key) ?? [];

  oldData.add(value);

  await saveDataForeground(key: key, value: oldData);
}
