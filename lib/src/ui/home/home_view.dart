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

class _HomeUI extends StatelessWidget {
  const _HomeUI();

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
        crossAxisAlignment: CrossAxisAlignment.start, // Ratakan elemen ke kiri
        children: [
          // --- 1. BAGIAN MENU UTAMA (Disejajarkan ke samping / Row) ---
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
                const SizedBox(width: 16), // Jarak antar tombol
                Expanded(
                  child: _buildActionCard(
                    title: "Radar Aktif",
                    icon: Icons.radar,
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(context, KeyUtil.alert),
                  ),
                ),
              ],
            ),
          ),

          // --- 2. JUDUL SEGMEN RIWAYAT ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Riwayat Titik Pantau",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // --- 3. LIST VIEW MODERN ---
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

                  // Menggunakan Card bawaan Flutter agar ada bayangan (elevation)
                  // Menggunakan Card bawaan Flutter agar ada bayangan (elevation)
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
                      // 🟢 PERBAIKAN DI SINI: EdgeInsets.only dan penempatan kurung
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

  // --- WIDGET REUSABLE: Kartu Menu ---
  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Material membungkus InkWell agar efek klik (ripple) muncul sempurna
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
