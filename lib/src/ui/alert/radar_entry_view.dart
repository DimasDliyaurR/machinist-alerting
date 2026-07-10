import 'package:flutter/material.dart';
import 'package:masinis_helper/src/core/app_db.dart';
import 'package:masinis_helper/src/repository/record_repository.dart';
import 'package:masinis_helper/src/ui/alert/alert_provider.dart';
import 'package:masinis_helper/src/ui/alert/station_select_view.dart';
import 'package:provider/provider.dart';

class RadarEntryView extends StatelessWidget {
  const RadarEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AlertProvider(RecordRepository(AppDb())),
      child: const StationSelectView(),
    );
  }
}
