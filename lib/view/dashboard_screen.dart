import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalSaldo = 800000; // Default saldo awal
  List<Map<String, dynamic>> _riwayatPengeluaran = [];

  @override
  void initState() {
    super.initState();
    _muatDataLokal();
  }

  // --- LOGIKA PERSISTENSI DATA (SharedPreferences) ---
  Future<void> _muatDataLokal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalSaldo = prefs.getInt('total_saldo') ?? 800000;
      final String? dataString = prefs.getString('riwayat_pengeluaran');
      if (dataString != null) {
        _riwayatPengeluaran = List<Map<String, dynamic>>.from(
          jsonDecode(dataString),
        );
      }
    });
  }

  Future<void> _simpanDataLokal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_saldo', _totalSaldo);
    await prefs.setString(
      'riwayat_pengeluaran',
      jsonEncode(_riwayatPengeluaran),
    );
  }

  void _tambahPengeluaran(String judul, int nominal) {
    setState(() {
      _totalSaldo -= nominal;
      _riwayatPengeluaran.insert(0, {
        'judul': judul,
        'nominal': nominal,
        'tanggal': DateTime.now().toString().split(' ')[0],
      });
    });
    _simpanDataLokal();
  }

  void _isiSaldo(int nominal) {
    setState(() {
      _totalSaldo += nominal;
    });
    _simpanDataLokal();
  }

  // --- MODAL INPUT DENGAN FORM VALIDATION ---
  void _tampilkanModalInput() {
    final judulController = TextEditingController();
    final nominalController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Catat Pengeluaran',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: judulController,
              decoration: InputDecoration(
                labelText: 'Keterangan',
                hintText: 'misal: Beli Pop Ice / Print Tugas',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nominalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nominal (Rp)',
                prefixIcon: const Icon(Icons.payments_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final judul = judulController.text.trim();
                  final nominal = int.tryParse(nominalController.text) ?? 0;

                  if (judul.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Keterangan tidak boleh kosong!')),
                    );
                    return;
                  }

                  if (nominal <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Nominal harus lebih dari 0!')),
                    );
                    return;
                  }

                  _tambahPengeluaran(judul, nominal);
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Simpan Pengeluaran',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SakuSiswa Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Penandatangan layout agar rapi dan pas di Web/Desktop (max 600px)
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD SALDO UTAMA
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade800, Colors.teal.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Text(
                            'Sisa Uang Saku Saat Ini',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Rp ${_totalSaldo.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _isiSaldo(50000),
                            icon: const Icon(Icons.add_card_outlined, size: 20),
                            label: const Text('+ Rp 50.000'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // HEADER RIWAYAT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Riwayat Pengeluaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_riwayatPengeluaran.length} Transaksi',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // DAFTAR RIWAYAT
                  Expanded(
                    child: _riwayatPengeluaran.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada pengeluaran.\nHemat banget hari ini! 🥳',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _riwayatPengeluaran.length,
                            itemBuilder: (context, index) {
                              final item = _riwayatPengeluaran[index];
                              return Card(
                                elevation: 0,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant
                                    .withOpacity(0.5),
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.teal.shade100,
                                    child: Icon(
                                      Icons.shopping_bag_outlined,
                                      color: Colors.teal.shade800,
                                    ),
                                  ),
                                  title: Text(
                                    item['judul'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    item['tanggal'] ?? '',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Text(
                                    '- Rp ${item['nominal']}',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
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
