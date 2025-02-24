import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:quiver/time.dart';

// void main() {
//   runApp(AbsensiHistoriPage());
// }

class AbsensiHistoriPage extends StatefulWidget {
  const AbsensiHistoriPage({super.key});

  @override
  State<AbsensiHistoriPage> createState() => _AbsensiHistoriPageState();
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class _AbsensiHistoriPageState extends State<AbsensiHistoriPage> {
  bool selectedcurrentyear = false;
  final moonLanding = DateTime.now();
  var month = DateTime.now();
  String? _tokenSecure;
  final storage = const FlutterSecureStorage();
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
    getAbsensiData(_tokenSecure);
  }

  Future<void> getAbsensiData(String? myToken) async {
    String apiUrl =
        '${const String.fromEnvironment('devUrl')}api/v1/shift-user/${month.month}';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $myToken',
      });

      if (response.statusCode == 200) {
        final dataAbsensiBulanIni = json.decode(response.body)['data'];
        setState(() {
          _dataAbsensiBulanIni = (dataAbsensiBulanIni['user-shift']);
          // print(_dataAbsensiBulanIni['1']);
        });
      } else {
        // debugPrint(apiUrl);
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[100],
          title: const Text('Data Absensi'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          children: [
            buildHistory(_dataAbsensiBulanIni),
          ],
        ),
      ),
    );
  }

  Widget buildHistory(Map<dynamic, dynamic> dataAbsensi) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text(
                'Histori Absensi Anda Bulan Ini:',
                style: TextStyle(fontSize: 22),
              ),
              for (int i = 1;
                  i <= daysInMonth(DateTime.now().year, DateTime.now().month);
                  i++)
                if (dataAbsensi[i.toString()] != null)
                  buildHistoryItem(dataAbsensi[i.toString()]),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHistoryItem(Map<dynamic, dynamic> dataAbsensi) {
    String textKeterangan = 'Please Wait';

    Icon iconKehadiran = const Icon(
      Icons.check,
      color: Colors.grey,
    );

    if (dataAbsensi['check_in'] != null) {
      if (DateTime.parse(
                  "${DateFormat('yyyy-MM-dd').format(DateTime.parse(dataAbsensi['valid_date_start']))} ${dataAbsensi['shift_checkin']}")
              .compareTo(DateTime.parse(dataAbsensi['check_in'])) >
          0) {
        textKeterangan = 'Tepat Waktu';
        setState(() {
          iconKehadiran = const Icon(
            Icons.check,
            color: Colors.green,
          );
        });
      } else {
        Duration difference = DateTime.parse(dataAbsensi['check_in'])
            .difference(DateTime.parse(
                "${DateFormat('yyyy-MM-dd').format(DateTime.parse(dataAbsensi['valid_date_start']))} ${dataAbsensi['shift_checkin']}"));
        textKeterangan =
            'Anda Terlambat ${difference.inMinutes > 0 ? "${difference.inMinutes} Menit" : "${difference.inSeconds} Detik"}';
        setState(() {
          iconKehadiran = const Icon(
            Icons.assignment_late_outlined,
            color: Colors.orange,
          );
        });
      }
    } else if (DateTime.parse(
                "${DateFormat('yyyy-MM-dd').format(DateTime.parse(dataAbsensi['valid_date_start']))} ${dataAbsensi['shift_checkin']}")
            .compareTo(DateTime.now()) <
        0) {
      textKeterangan = 'Anda tidak absen';
      setState(() {
        iconKehadiran = Icon(
          Icons.assignment_late_outlined,
          color: Colors.red[300],
        );
      });
    } else {
      textKeterangan = '-';
      setState(() {
        iconKehadiran = const Icon(
          Icons.calendar_month,
          color: Colors.grey,
        );
      });
    }

    return Card(
      child: ListTile(
        leading: iconKehadiran,
        title: Text(DateFormat('dd MMMM yyyy')
            .format(DateTime.parse(dataAbsensi['valid_date_start']))),
        subtitle: Text(textKeterangan),
        trailing: IconButton(
          icon: const Icon(Icons.remove_red_eye_rounded),
          onPressed: () {
            _dialogBuilder(context, dataAbsensi);
          },
        ),
      ),
    );
  }

  Future<void> _dialogBuilder(
      BuildContext context, Map<dynamic, dynamic> dataAbsensi) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Data Kehadiran'),
          content: Text(
            'Tanggal : ${DateFormat('yyyy-MM-dd').format(DateTime.parse(dataAbsensi['valid_date_start']))}\n'
            'Shift : ${dataAbsensi['shift_name']} ${dataAbsensi['shift_checkin']} - ${dataAbsensi['shift_checkout']}\n'
            'Datang : ${dataAbsensi['check_in'] != null ? DateFormat('HH:mm:ss').format(DateTime.parse(dataAbsensi['check_in'])) : '-'}\n'
            'Pulang : ${dataAbsensi['check_out'] != null ? DateFormat('HH:mm:ss').format(DateTime.parse(dataAbsensi['check_out'])) : '-'}',
          ),
          // actions: <Widget>[
          //   TextButton(
          //     style: TextButton.styleFrom(
          //       textStyle: Theme.of(context).textTheme.labelLarge,
          //     ),
          //     child: const Text('Disable'),
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //   ),
          //   TextButton(
          //     style: TextButton.styleFrom(
          //       textStyle: Theme.of(context).textTheme.labelLarge,
          //     ),
          //     child: const Text('Enable'),
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //   ),
          // ],
        );
      },
    );
  }
}
