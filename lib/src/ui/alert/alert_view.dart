import 'package:flutter/material.dart';
import 'package:masinis_helper/src/ui/alert/alert_provider.dart';
import 'package:provider/provider.dart';

class AlertView extends StatelessWidget {
  const AlertView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Radar Masinis")),
      body: Column(
        children: [
          const SizedBox(height: 20),

          Text(
            "Akurasi GPS: ${provider.accuracyGps ?? "Mencari satelit..."}",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),

          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: provider.color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: provider.color, width: 8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    provider.isListening ? Icons.radar : Icons.location_off,
                    size: 70,
                    color: provider.color,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    provider.isListening
                        ? "${provider.currentDistance.toStringAsFixed(1)} m"
                        : "Nonaktif",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: provider.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              provider.isListening && provider.nameStation != null
                  ? provider.nameStation!
                  : "Menunggu Titik Stasiun...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: provider.color,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 45,
                child: ElevatedButton(
                  onPressed: provider.isListening
                      ? () => context.read<AlertProvider>().stopListen()
                      : () => context.read<AlertProvider>().startListen(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.isListening
                        ? Colors.blueGrey
                        : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    provider.isListening ? "Hentikan Radar" : "Nyalakan Radar",
                  ),
                ),
              ),

              const SizedBox(width: 16),

              if (provider.isListening && provider.isNear)
                SizedBox(
                  width: 150,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AlertProvider>().nextRoute();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.isLastStation
                          ? Colors.red
                          : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      provider.isLastStation ? "Berakhir" : "Lanjut Stasiun",
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(thickness: 2),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Rute Perjalanan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: provider.routeTrain == null || provider.routeTrain!.isEmpty
                ? const Center(child: Text("Belum ada rute yang dipilih"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: provider.routeTrain!.length,
                    itemBuilder: (context, index) {
                      final station = provider.routeTrain![index];

                      final isCurrentTarget = index == provider.indexRoute;
                      final isPassed = index < provider.indexRoute;

                      return Card(
                        elevation: isCurrentTarget ? 4 : 1,
                        color: isCurrentTarget
                            ? Colors.blue.shade50
                            : Colors.white,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isCurrentTarget
                                ? Colors.blueAccent
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            isPassed
                                ? Icons.check_circle
                                : (isCurrentTarget
                                      ? Icons.train
                                      : Icons.radio_button_unchecked),
                            color: isPassed
                                ? Colors.green
                                : (isCurrentTarget
                                      ? Colors.blueAccent
                                      : Colors.grey),
                            size: 30,
                          ),
                          title: Text(
                            station["nama"] ?? "Stasiun Tanpa Nama",
                            style: TextStyle(
                              fontWeight: isCurrentTarget
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isPassed ? Colors.grey : Colors.black87,
                              decoration: isPassed
                                  ? TextDecoration.lineThrough
                                  : null, // Coret nama jika sudah lewat
                            ),
                          ),
                          subtitle: Text(
                            "Lat: ${station['latitude']} | Long: ${station['longitude']}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: isCurrentTarget
                              ? const Text(
                                  "Tujuan\nSaat Ini",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
