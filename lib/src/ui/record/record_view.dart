import 'package:flutter/material.dart';
import 'package:masinis_helper/src/core/app_db.dart';
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
        appBar: AppBar(title: const Text("Record")),
        body: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (value) =>
                        value!.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: _latitude,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    validator: (value) =>
                        value!.isEmpty ? 'Latitude wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: _longitude,
                    decoration: const InputDecoration(labelText: '_longitude'),
                    validator: (value) =>
                        value!.isEmpty ? 'Longitude wajib diisi' : null,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.gps_fixed),
                    label: const Text("Ambil Titik Koordinat"),
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
                  provider.recordModel.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            if (provider.recordModel.isLoading) {
                              return;
                            }
                            if (_formKey.currentState!.validate()) {
                              final success = await context
                                  .read<RecordProvider>()
                                  .submitForm(
                                    _name.text,
                                    _latitude.text,
                                    _longitude.text,
                                  );

                              if (success == 1 && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Login Sukses!"),
                                  ),
                                );
                                Navigator.pop(context);
                                _name.clear();
                                _latitude.clear();
                                _longitude.clear();

                                _formKey.currentState!.reset();
                              }
                            }
                          },
                          child: const Text('Submit'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
