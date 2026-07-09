import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'alert_provider.dart'; // Sesuaikan import Anda

class AlertView extends StatelessWidget {
  const AlertView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => AlertProvider())],
      child: const _AlertUI(),
    );
  }
}

class _AlertUI extends StatefulWidget {
  const _AlertUI();

  @override
  State<_AlertUI> createState() => _AlertUIState();
}

class _AlertUIState extends State<_AlertUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Radar Masinis")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.accuracyGps ?? "Accuracy Non"),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 250,
              height: 250,
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
                      size: 80,
                      color: provider.color,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      provider.isListening && provider.nameStation != null
                          ? "${provider.nameStation ?? ''} | ${provider.currentDistance.toStringAsFixed(1)} m"
                          : "Stasiun | Radar Nonaktif",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: provider.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),

            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: provider.isListening
                    ? () {
                        context.read<AlertProvider>().stopListen();
                      }
                    : () {
                        context.read<AlertProvider>().startListen();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  provider.isListening ? "Mendeteksi..." : "Aktifkan Radar",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
