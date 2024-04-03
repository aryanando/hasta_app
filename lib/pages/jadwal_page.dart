import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:quiver/time.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
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

class _JadwalPageState extends State<JadwalPage> {
  final moonLanding = DateTime.now();
  String? _tokenSecure;
  final storage = const FlutterSecureStorage();
  var month = 4;
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
    // print('Token Anda Adalah: $_token');
    // print('Token Anda Adalah Secure: $_tokenSecure');
    getAbsensiData(_tokenSecure);
  }

  Future<void> getAbsensiData(String? myToken) async {
    String apiUrl =
        '${const String.fromEnvironment('devUrl')}api/v1/shift-user/$month';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $myToken',
      });

      if (response.statusCode == 200) {
        //mengabil data user
        final dataAbsensiBulanIni = json.decode(response.body)['data'];
        print(dataAbsensiBulanIni);
        setState(() {
          _dataAbsensiBulanIni = (dataAbsensiBulanIni['user-shift']);
        });
      } else {
        debugPrint(apiUrl);
        print(response.statusCode);
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Jadwal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          for (var i = 1; i <= daysInMonth(2024, moonLanding.month); i++)
            Column(
              children: [
                Center(
                  child: Card(
                    color: HexColor(
                        _dataAbsensiBulanIni['$i']?['shift_color'] ?? 'DDDDDD'),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Text(
                            '$i',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 20),
                          ),
                          title: Text(
                              "Shift : ${_dataAbsensiBulanIni['$i']?['shift_name'] ?? 'Off'} "),
                          subtitle: Text(
                              "${_dataAbsensiBulanIni['$i']?['shift_checkin'] ?? 'Selamat Menikmati Masa Libur Anda'} - ${_dataAbsensiBulanIni['$i']?['shift_checkout'] ?? ''} "),
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
