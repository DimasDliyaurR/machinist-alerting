import 'package:masinis_helper/src/core/app_constant.dart';
import 'package:masinis_helper/src/ui/home/home_view.dart';
import 'package:masinis_helper/src/ui/signal/signal_entry_view.dart';

var appRoutes = {
  KeyUtil.home: (context) => HomeView(),
  KeyUtil.signal: (context) => SignalEntryView(),

  // KeyUtil.record: (context) => RecordView(),
  // KeyUtil.alert: (context) => RadarEntryView(),
};
