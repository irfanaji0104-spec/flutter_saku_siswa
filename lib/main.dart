import 'package:flutter/material.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const SakuSiswaApp());
}

class SakuSiswaApp extends StatelessWidget {
  const SakuSiswaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SakuSiswa',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalSaldo = 0;
  List<Map<String, dynamic>> _riwayatPengeluaran = [];

  @override
  void initState() {
    super.initState();
    _muatDataLokal();
  }

  // --- LOGIKA SHAREDPREFERENCES --- //

// 1. Membaca data dari SharedPreferences (via Storage Service)
  Future<void> _muatDataLokal() async {
    final data = await muatDataLokal();
    setState(() {
      _totalSaldo = data['saldo'];
      _riwayatPengeluaran = data['riwayat'];
    });
  }

// 2. Menyimpan data ke SharedPreferences (via Storage Service)
  Future<void> _simpanDataLokal() async {
    await simpanDataLokal(_totalSaldo, _riwayatPengeluaran);
  }

  // 3. Menambah transaksi baru
  void _tambahPengeluaran(String judul, int nominal) {
    if (nominal <= 0 || judul.isEmpty) return;

    setState(() {
      _totalSaldo -= nominal;
      _riwayatPengeluaran.insert(0, {
        'judul': judul,
        'nominal': nominal,
        'tanggal': DateTime.now().toString().substring(0, 10),
      });
    });

    _simpanDataLokal(); // Simpan permanen ke storage HP
  }

  // 4. Modal Bottom Sheet Form Input (UI Modern)
  void _tampilkanModalInput() {
    final judulController = TextEditingController();
    final nominalController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tambah Pengeluaran',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: judulController,
              decoration: const InputDecoration(
                labelText: 'Keterangan (misal: Beli Pop Ice / Print Tugas)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nominalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal (Rp)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final judul = judulController.text;
                  final nominal = int.tryParse(nominalController.text) ?? 0;
                  _tambahPengeluaran(judul, nominal);
                  Navigator.pop(ctx);
                },
                child: const Text('Simpan Pengeluaran'),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SakuSiswa Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // CARD UI STANDAR INDUSTRI
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: Colors.teal.shade700,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('Sisa Uang Saku Saat Ini',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      'Rp $_totalSaldo',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _totalSaldo += 50000);
                        _simpanDataLokal();
                      },
                      icon: const Icon(Icons.add_card, color: Colors.white),
                      label: const Text('Isi Uang Saku (+Rp50.000)',
                          style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Riwayat Pengeluaran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),

            // DYNAMIC LISTVIEW
            Expanded(
              child: _riwayatPengeluaran.isEmpty
                  ? const Center(
                      child: Text(
                          'Belum ada pengeluaran hari ini. Hemat banget! 🎉'))
                  : ListView.builder(
                      itemCount: _riwayatPengeluaran.length,
                      itemBuilder: (context, index) {
                        final item = _riwayatPengeluaran[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.shopping_bag_outlined),
                            ),
                            title: Text(item['judul']),
                            subtitle: Text(item['tanggal']),
                            trailing: Text(
                              '- Rp ${item['nominal']}',
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tampilkanModalInput,
        icon: const Icon(Icons.remove_circle_outline),
        label: const Text('Catat Pengeluaran'),
      ),
    );
  }
}
