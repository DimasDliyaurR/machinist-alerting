import 'package:flutter/material.dart';
import 'package:masinis_helper/src/core/app_db.dart';
import 'package:masinis_helper/src/dto/record_dto.dart';
import 'package:masinis_helper/src/repository/record_repository.dart';
import 'package:masinis_helper/src/ui/record/record_provider.dart';
import 'package:provider/provider.dart';

class RecordView extends StatelessWidget {
  const RecordView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RecordProvider>(
          create: (context) => RecordProvider(RecordRepository(AppDb())),
        ),
      ],
      child: _RecordFormUI(),
    );
  }
}

class _RecordFormUI extends StatefulWidget {
  const _RecordFormUI();

  @override
  State<_RecordFormUI> createState() => _RecordFormUIState();
}

class _RecordFormUIState extends State<_RecordFormUI> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecordProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Tambah Lokasi",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: 'Nama Stasiun / Lokasi',
                    prefixIcon: const Icon(Icons.train),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16), // 🟢 2. Jarak vertikal antar input
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitude,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? 'Wajib' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _longitude,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? 'Wajib' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                OutlinedButton.icon(
                  icon: const Icon(Icons.gps_fixed),
                  label: const Text("Gunakan Lokasi Saat Ini (GPS)"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final locationData = await context
                        .read<RecordProvider>()
                        .getCurrentLocation();

                    if (locationData != null) {
                      _latitude.text = locationData.latitude.toString();
                      _longitude.text = locationData.longitude.toString();

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Lokasi berhasil didapatkan!"),
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Gagal mendapatkan lokasi atau izin ditolak.",
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Tombol Submit Utama
                provider.recordModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (provider.recordModel.isLoading) return;

                          if (_formKey.currentState!.validate()) {
                            final success = await context
                                .read<RecordProvider>()
                                .submitForm(
                                  record: RecordDto(
                                    nama: _name.text,
                                    latitude: _latitude.text,
                                    longitude: _longitude.text,
                                  ),
                                );

                            if (success != null && success > 0 && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Lokasi berhasil ditambahkan!"),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: const Text(
                          'Simpan Data Pantau',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
