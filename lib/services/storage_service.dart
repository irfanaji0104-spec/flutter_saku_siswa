import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Simpan Data ke Memory HP
Future<void> simpanDataLokal(
  int totalSaldo,
  List<Map<String, dynamic>> riwayat,
) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('total_saldo', totalSaldo);

  // Encode List Map ke List String JSON
  List<String> dataStringList =
      riwayat.map((item) => jsonEncode(item)).toList();
  await prefs.setStringList('riwayat', dataStringList);
}

// 2. Muat Data Saat Aplikasi Dibuka
Future<Map<String, dynamic>> muatDataLokal() async {
  final prefs = await SharedPreferences.getInstance();
  int saldo = prefs.getInt('total_saldo') ?? 0;

  List<String>? dataStringList = prefs.getStringList('riwayat');
  List<Map<String, dynamic>> riwayat = [];

  if (dataStringList != null) {
    riwayat = dataStringList
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  return {
    'saldo': saldo,
    'riwayat': riwayat,
  };
}
