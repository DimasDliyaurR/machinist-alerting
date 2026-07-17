import 'package:flutter/material.dart';
import 'package:masinis_helper/src/ui/signal/bottom_sheet/form_signal_bottom_sheet.dart';
import 'package:masinis_helper/src/ui/signal/signal_provider.dart';
import 'package:provider/provider.dart';

class SignalView extends StatefulWidget {
  const SignalView({super.key});

  @override
  State<SignalView> createState() => _SignalViewState();
}

class _SignalViewState extends State<SignalView> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignalProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text("Signal List")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isDismissible: false,
            isScrollControlled: true,

            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ChangeNotifierProvider.value(
                  value: provider,
                  child: const FormSignalBottomSheet(),
                ),
              );
            },
          );
        },
        backgroundColor: Colors.blue.shade50,
        child: Icon(Icons.add),
      ),
      body: provider.signal.isEmpty
          ? Center(child: Text("Belum ada Signal yang terdaftar."))
          : Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<SignalProvider>().getData();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: provider.signal.length,
                  itemBuilder: (context, index) {
                    final data = provider.signal[index];

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
                            data.id.toString(),
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(data.nama.toString()),
                        trailing: PopupMenuButton<String>(
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: "hapus",
                                  child: Text('Hapus'),
                                ),
                                const PopupMenuItem<String>(
                                  value: "edit",
                                  child: Text('Edit'),
                                ),
                              ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
