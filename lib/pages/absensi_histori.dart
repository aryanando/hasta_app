import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:quiver/time.dart';

class AbsensiHistoriPage extends StatefulWidget {
  const AbsensiHistoriPage({super.key});

  @override
  State<AbsensiHistoriPage> createState() => _AbsensiHistoriPageState();
}

class _AbsensiHistoriPageState extends State<AbsensiHistoriPage> {
  final storage = const FlutterSecureStorage();
  String? _tokenSecure;
  Map _dataAbsensiBulanIni = {};
  final DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final tokenSecure = await storage.read(key: 'tokenSecure') ?? "";
    setState(() {
      _tokenSecure = tokenSecure;
    });
    getAbsensiData();
  }

  Future<void> getAbsensiData() async {
    String apiUrl =
        '${const String.fromEnvironment('devUrl')}api/v1/shift-user/${_currentMonth.month}';

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_tokenSecure',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          _dataAbsensiBulanIni = data['user-shift'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching attendance data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Histori Absensi',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildHistoryHeader(),
          _buildHistoryList(),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Histori Absensi Bulan ${DateFormat('MMMM yyyy').format(_currentMonth)}',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHistoryList() {
    return Column(
      children: [
        for (int i = 1;
            i <= daysInMonth(_currentMonth.year, _currentMonth.month);
            i++)
          if (_dataAbsensiBulanIni[i.toString()] != null)
            _buildHistoryItem(_dataAbsensiBulanIni[i.toString()]),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHistoryItem(Map<dynamic, dynamic> dataAbsensi) {
    String textKeterangan = 'Please Wait';
    Icon iconKehadiran = const Icon(Icons.check, color: Colors.grey);

    DateTime shiftStart = DateTime.parse(
        "${dataAbsensi['valid_date_start'].split(' ')[0]}T${dataAbsensi['shift_checkin']}");

    DateTime? checkIn = dataAbsensi['check_in'] != null
        ? DateTime.parse(dataAbsensi['check_in'])
        : null;

    if (checkIn != null) {
      if (shiftStart.isAfter(checkIn)) {
        textKeterangan = 'Tepat Waktu';
        iconKehadiran = const Icon(Icons.check_circle, color: Colors.green);
      } else {
        Duration difference = checkIn.difference(shiftStart);
        textKeterangan = 'Terlambat ${difference.inMinutes} Menit';
        iconKehadiran = const Icon(Icons.assignment_late, color: Colors.orange);
      }
    } else if (shiftStart.isBefore(DateTime.now())) {
      textKeterangan = 'Tidak Absen';
      iconKehadiran = const Icon(Icons.cancel, color: Colors.red);
    } else {
      textKeterangan = '-';
      iconKehadiran = const Icon(Icons.pending, color: Colors.grey);
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: iconKehadiran,
        title: Text(
          DateFormat('dd MMMM yyyy')
              .format(DateTime.parse(dataAbsensi['valid_date_start'])),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(textKeterangan),
        trailing: IconButton(
          icon: const Icon(Icons.visibility, color: Colors.blueAccent),
          onPressed: () => _showDetailsDialog(context, dataAbsensi),
        ),
      ),
    );
  }

  Future<void> _showDetailsDialog(
      BuildContext context, Map<dynamic, dynamic> dataAbsensi) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detail Kehadiran',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            "📅 Tanggal: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(dataAbsensi['valid_date_start']))}\n"
            "⏰ Shift: ${dataAbsensi['shift_name']} (${dataAbsensi['shift_checkin']} - ${dataAbsensi['shift_checkout']})\n"
            "✅ Check-in: ${dataAbsensi['check_in'] != null ? DateFormat('HH:mm:ss').format(DateTime.parse(dataAbsensi['check_in'])) : '-'}\n"
            "❌ Check-out: ${dataAbsensi['check_out'] != null ? DateFormat('HH:mm:ss').format(DateTime.parse(dataAbsensi['check_out'])) : '-'}",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}

/// 🎨 **Hex Color Utility for Dynamic Colors**
class HexColor extends Color {
  HexColor(final String hex)
      : super(int.parse(hex.replaceFirst("#", "FF"), radix: 16));
}
