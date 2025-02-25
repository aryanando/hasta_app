import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hasta_app/pages/absensi_histori.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AbsensiCalendarPage extends StatefulWidget {
  const AbsensiCalendarPage({super.key});

  @override
  State<AbsensiCalendarPage> createState() => _AbsensiCalendarPageState();
}

class _AbsensiCalendarPageState extends State<AbsensiCalendarPage> {
  final storage = const FlutterSecureStorage();
  String? _tokenSecure;
  DateTime _selectedDate = DateTime.now();
  Map _dataAbsensiBulanIni = {};

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
        '${const String.fromEnvironment('devUrl')}api/v1/shift-user/${_selectedDate.month}';
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
      debugPrint("Error fetching data: $e");
    }
  }

  String getShiftName(DateTime date) {
    String key = date.day.toString();
    return _dataAbsensiBulanIni[key]?['shift_name'] ?? "Off";
  }

  Color getShiftColor(DateTime date) {
    String key = date.day.toString();
    String colorHex = _dataAbsensiBulanIni[key]?['shift_color'] ?? "DDDDDD";
    return HexColor(colorHex);
  }

  Map? getTodayShiftData() {
    String key = DateTime.now().day.toString();
    return _dataAbsensiBulanIni[key];
  }

  @override
  Widget build(BuildContext context) {
    Map? todayShift = getTodayShiftData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Absensi',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 15),
          _buildTodayShiftCard(todayShift),
          _buildHistoryButton(),
        ],
      ),
    );
  }

  /// 📅 **Build the Calendar View**
  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: DateTime.now(),
      firstDay: DateTime(DateTime.now().year, DateTime.now().month, 1),
      lastDay: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
      calendarFormat: CalendarFormat.month,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
        });
        _showShiftDialog(selectedDay);
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) => _buildDayCell(date),
        todayBuilder: (context, date, _) => _buildDayCell(date, isToday: true),
      ),
    );
  }

  /// 📌 **Customize Each Day Cell in Calendar**
  Widget _buildDayCell(DateTime date, {bool isToday = false}) {
    String shift = getShiftName(date);
    Color shiftColor = getShiftColor(date);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date.day.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isToday ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: shiftColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              shift,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 **Show Attendance Details in a Dialog**
  Future<void> _showShiftDialog(DateTime date) async {
    String key = date.day.toString();
    Map? data = _dataAbsensiBulanIni[key];

    if (data == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detail Kehadiran',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            "📅 Tanggal: ${DateFormat('yyyy-MM-dd').format(date)}\n"
            "⏰ Shift: ${data['shift_name']} (${data['shift_checkin']} - ${data['shift_checkout']})\n"
            "✅ Check-in: ${data['check_in'] ?? '-'}\n"
            "❌ Check-out: ${data['check_out'] ?? '-'}",
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

  /// 🔘 **Today's Shift Card**
  Widget _buildTodayShiftCard(Map? todayShift) {
    if (todayShift == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HexColor(todayShift['shift_color'] ?? "DDDDDD"),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Shift Hari Ini",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "📅 Tanggal: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          Text(
            "⏰ Shift: ${todayShift['shift_name']} (${todayShift['shift_checkin']} - ${todayShift['shift_checkout']})",
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// 🔘 **"View All History" Button**
  Widget _buildHistoryButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AbsensiHistoriPage()),
        );
      },
      icon: const Icon(Icons.history, color: Colors.white),
      label: const Text("Lihat Semua Histori",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
    );
  }
}

/// 🎨 **Hex Color Utility**
class HexColor extends Color {
  HexColor(final String hex)
      : super(int.parse(hex.replaceFirst("#", "FF"), radix: 16));
}
