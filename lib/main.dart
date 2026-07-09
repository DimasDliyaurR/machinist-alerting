import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:masinis_helper/src/extension/locator.dart';
import 'package:masinis_helper/src/ui/app/app.dart';
import 'package:masinis_helper/src/ui/home/home_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();

  setUpLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GetIt.I.get<HomeProvider>(),
        ),
      ],
      child: MyApp(),
    ),
  );
}
