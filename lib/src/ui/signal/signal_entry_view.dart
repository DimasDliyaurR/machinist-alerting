import 'package:flutter/material.dart';
import 'package:masinis_helper/src/core/app_db.dart';
import 'package:masinis_helper/src/repositories/signal_repository.dart';
import 'package:masinis_helper/src/ui/signal/signal_provider.dart';
import 'package:masinis_helper/src/ui/signal/signal_view.dart';
import 'package:provider/provider.dart';

class SignalEntryView extends StatelessWidget {
  const SignalEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignalProvider(SignalRepository(AppDb())),
      child: const SignalView(),
    );
  }
}
