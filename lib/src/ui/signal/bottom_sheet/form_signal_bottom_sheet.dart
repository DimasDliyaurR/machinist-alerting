import 'package:flutter/material.dart';
import 'package:masinis_helper/src/core/app_constant.dart';
import 'package:masinis_helper/src/dto/signal_dto.dart';
import 'package:masinis_helper/src/ui/signal/signal_provider.dart';
import 'package:provider/provider.dart';

class FormSignalBottomSheet extends StatefulWidget {
  const FormSignalBottomSheet({super.key});

  @override
  State<FormSignalBottomSheet> createState() => _FormSignalBottomSheetState();
}

class _FormSignalBottomSheetState extends State<FormSignalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _tipe = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignalProvider>();
    return FractionallySizedBox(
      heightFactor: 0.75,
      child: PopScope(
        canPop: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [
                TextFormField(
                  controller: _nama,
                  decoration: InputDecoration(
                    labelText: 'Nama Signal',
                    border: OutlineInputBorder(borderRadius: .circular(12)),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Nama wajib diisi!' : null,
                ),

                const SizedBox(height: 16),

                DropdownMenu<TipeSignal>(
                  controller: _tipe,
                  initialSelection: TipeSignal.values[0],
                  expandedInsets: .zero,
                  label: const Text("Tipe"),
                  dropdownMenuEntries: TipeSignal.values.map((
                    TipeSignal tipeSignal,
                  ) {
                    return DropdownMenuEntry<TipeSignal>(
                      value: tipeSignal,
                      label: tipeSignal.name.toString(),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitude,
                        decoration: InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(
                            borderRadius: .circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Latitude rute wajib diisi!';
                          }

                          final parsedInt = int.tryParse(value);
                          if (parsedInt != null) {
                            int max = 180;
                            int low = -180;
                            if (parsedInt > max && parsedInt < low) {
                              return 'Latitude tidak valid';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _longitude,
                        decoration: InputDecoration(
                          labelText: 'Longitude Signal',
                          border: OutlineInputBorder(
                            borderRadius: .circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Longitude rute wajib diisi!';
                          }

                          final parsedInt = int.tryParse(value);
                          if (parsedInt != null) {
                            int max = 90;
                            int low = -90;
                            if (parsedInt > max && parsedInt < low) {
                              return 'Longitude tidak valid';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.gps_fixed),
                  label: const Text("Gunakan Lokasi saat ini"),
                  onPressed: () async {
                    final locationData = await context
                        .read<SignalProvider>()
                        .getCurrentLocation();

                    if (!context.mounted) return;

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

                provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: () async {
                          if (provider.isLoading) return;

                          if (_formKey.currentState!.validate()) {
                            Map<String, dynamic> map = {
                              "nama": _nama.text,
                              "tipe": _tipe.text.toString(),
                              "latitude": _latitude.text,
                              "longitude": _longitude.text,
                            };

                            final success = await context
                                .read<SignalProvider>()
                                .submitForm(SignalDto.formMap(map));

                            if (!context.mounted) return;

                            if (success == 1 && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Signal berhasil ditambahkan!"),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Text(
                          "Simpan data router",
                          style: TextStyle(fontSize: 16, fontWeight: .bold),
                        ),
                      ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                    child: const Text("Keluar Aplikasi"),
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
