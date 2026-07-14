import 'package:flutter/material.dart';
import 'package:masinis_helper/src/ui/alert/alert_provider.dart';
import 'package:masinis_helper/src/ui/alert/alert_view.dart';
import 'package:provider/provider.dart';

class StationSelectView extends StatelessWidget {
  const StationSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Rute Stasiun"),
        centerTitle: true,
      ),
      body: provider.allStations.isEmpty
          ? const Center(child: Text("Belum ada data stasiun"))
          : ListView.builder(
              itemCount: provider.allStations.length,
              itemBuilder: (context, index) {
                final station = provider.allStations[index];
                final checked = provider.isSelected(station);

                final selectedIndex = provider.selectedStations.indexWhere(
                  (e) =>
                      e['nama'] == station['nama'] &&
                      e['latitude'] == station['latitude'],
                );

                final orderNumber = selectedIndex != -1
                    ? selectedIndex + 1
                    : null;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  elevation: checked ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: checked ? Colors.blueAccent : Colors.grey.shade300,
                      width: checked ? 1.5 : 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: checked,
                    activeColor: Colors.blueAccent,
                    onChanged: (_) {
                      if (provider.isFinish) {
                        context.read<AlertProvider>().toggleStation(station);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Tidak bisa memilih rute, Radar sedang aktif!",
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                    },
                    secondary: checked
                        ? CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            radius: 18,
                            child: Text(
                              orderNumber.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            radius: 18,
                            child: const Icon(
                              Icons.train,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                    title: Text(
                      station['nama'].toString(),
                      style: TextStyle(
                        fontWeight: checked
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: checked ? Colors.black87 : Colors.black54,
                      ),
                    ),
                    subtitle: Text(
                      "Lat: ${station['latitude']} | Lon: ${station['longitude']}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final alertProvider = context.read<AlertProvider>();
                if (provider.isFinish) {
                  final error = provider.validationError;
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  final started = alertProvider.startListen();
                  if (!started) return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: alertProvider,
                      child: const AlertView(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.isFinish
                    ? (provider.canStart ? Colors.blueAccent : Colors.grey)
                    : Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                provider.isFinish
                    ? "Mulai Radar (${provider.selectedStations.length} Stasiun)"
                    : "Radar masih Aktif",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
