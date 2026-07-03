import 'package:flutter/material.dart';
import 'package:masinis_helper/src/core/app_constant.dart';
import 'package:masinis_helper/src/core/app_db.dart';
import 'package:masinis_helper/src/repository/record_repository.dart';
import 'package:masinis_helper/src/ui/home/home_provider.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HomeProvider(RecordRepository(AppDb())),
        ),
      ],
      child: _HomeUI(),
    );
  }
}

class _HomeUI extends StatefulWidget {
  const _HomeUI();

  @override
  State<StatefulWidget> createState() => _HomeUIState();
}

class _HomeUIState extends State<_HomeUI> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Machinist Alerting")),
      body: Column(
        children: [
          Container(
            child: Center(
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      await Navigator.pushNamed(context, KeyUtil.record);

                      if (context.mounted) {
                        context.read<HomeProvider>().getData();
                      }
                    },
                    child: card(
                      const Text(
                        "Record",
                        style: TextStyle(color: Colors.white),
                      ),
                      Colors.blue,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, KeyUtil.alert),
                    child: card(
                      const Text(
                        "Alert",
                        style: TextStyle(color: Colors.white),
                      ),
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<HomeProvider>().getData();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: provider.record.length,
                itemBuilder: (context, index) {
                  final data = provider.record[index];

                  return ListTile(
                    leading: CircleAvatar(child: Text(data["id"].toString())),
                    title: Text(data["nama"].toString()),
                    subtitle: Text(
                      "Lat: ${data['latitude']} | Long: ${data['longitude']}",
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget card(Widget title, Color? colors) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(color: colors),
      child: Center(child: title),
    );
  }
}
