import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:masinis_helper/src/core/app_constant.dart';
import 'package:masinis_helper/src/core/app_db.dart';
import 'package:masinis_helper/src/repository/record_repository.dart';
import 'package:masinis_helper/src/ui/home/home_provider.dart';
import 'package:masinis_helper/src/ui/widget/permission_model.dart';
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
      child: const _HomeUI(),
    );
  }
}

class _HomeUI extends StatefulWidget {
  const _HomeUI();

  @override
  State<_HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<_HomeUI> {
  StreamSubscription<ServiceStatus>? _serviceStatusStream;
  bool _isWarningDialogOpen = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _strictCheckPermission();
    });

    _listeningGpsStatus();
  }

  void _killApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  Future<void> _strictCheckPermission() async {
    final provider = context.read<HomeProvider>();
    await provider.checkPermission();

    if (!provider.statusPermission && mounted) {
      showPermissionModal(
        context,
        onGrant: () async {
          await provider.actionPermission();
        },
        onDeny: () {
          _killApp();
        },
      );
    }
  }

  void _listeningGpsStatus() {
    _serviceStatusStream = Geolocator.getServiceStatusStream().listen((
      ServiceStatus status,
    ) {
      if (status == ServiceStatus.disabled) {
        _tampilkanPeringatanGpsMati();
      } else if (status == ServiceStatus.enabled) {
        if (_isWarningDialogOpen && mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          _isWarningDialogOpen = false;
        }
      }
    });
  }

  void _tampilkanPeringatanGpsMati() {
    if (_isWarningDialogOpen) return;
    _isWarningDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.gps_off, color: Colors.red, size: 30),
                SizedBox(width: 10),
                Text("GPS Dimatikan!"),
              ],
            ),
            content: const Text(
              "Aplikasi Radar Masinis tidak dapat beroperasi tanpa GPS fisik yang menyala. "
              "Mohon nyalakan kembali Lokasi Anda, atau aplikasi akan ditutup otomatis.",
            ),
            actions: [
              TextButton(
                onPressed: () => _killApp(),
                child: const Text(
                  "Tutup Aplikasi",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                },
                child: const Text("Buka Pengaturan"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _serviceStatusStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Radar Masinis",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: "Tambah Lokasi",
                    icon: Icons.add_location_alt,
                    color: Colors.blueAccent,
                    onTap: () async {
                      await Navigator.pushNamed(context, KeyUtil.record);
                      if (context.mounted) {
                        context.read<HomeProvider>().getData();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    title: "Radar Aktif",
                    icon: Icons.radar,
                    // Tombol abu-abu jika GPS/Izin bermasalah
                    color: provider.statusPermission
                        ? Colors.green
                        : Colors.grey,
                    onTap: () {
                      if (provider.statusPermission) {
                        Navigator.pushNamed(context, KeyUtil.alert);
                      } else {
                        _strictCheckPermission();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Riwayat Titik Pantau",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<HomeProvider>().getData();
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: provider.record.length,
                itemBuilder: (context, index) {
                  final data = provider.record[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Text(
                          data["id"].toString(),
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        data["nama"].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "Lat: ${data['latitude']}\nLong: ${data['longitude']}",
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
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

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
