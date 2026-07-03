import 'package:flutter/material.dart';
import 'package:masinis_helper/src/core/app_constant.dart';
import 'package:masinis_helper/src/core/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Masinis Helper",
      initialRoute: KeyUtil.home,
      routes: appRoutes,
    );
  }
}
