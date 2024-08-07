import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class DokterPage extends StatefulWidget {
  const DokterPage({super.key});

  @override
  State<DokterPage> createState() => _DokterPageState();
}

class _DokterPageState extends State<DokterPage> {
  String? _tokenSecure;
  final storage = const FlutterSecureStorage();
  Map _dataDokter = {};
  Map _jadwal = {};

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
    getDokterData(_tokenSecure);
  }

  Future<void> getDokterData(String? myToken) async {
    String apiUrl = '${const String.fromEnvironment('devUrl')}api/v1/dokter';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $myToken',
      });

      if (response.statusCode == 200) {
        //mengabil data user
        final dataDokter = json.decode(response.body)['data'];
        // print(dataDokter);
        // setState(() {
        //   _dataDokter = (json.decode(response.body)['data']);
        // });
        setState(() {
          int i = -1;
          dataDokter.forEach((data) => {_dataDokter[i += 1] = data});
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

  _showFullModal(context, Map dataDokter) {
    jadwalDokterPoli(dataDokter['jadwal_poli']);
    showGeneralDialog(
      context: context,
      barrierDismissible:
          false, // should dialog be dismissed when tapped outside
      barrierLabel: "Modal", // label for barrier
      transitionDuration: const Duration(
          milliseconds:
              500), // how long it takes to popup dialog after button click
      pageBuilder: (_, __, ___) {
        // your widget implementation
        return Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              leading: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  }),
              title: Text(
                dataDokter['nm_dokter'],
                style: const TextStyle(
                    color: Colors.black87,
                    fontFamily: 'Overpass',
                    fontSize: 20),
              ),
              elevation: 0.0),
          backgroundColor: Color.fromARGB(192, 148, 199, 223).withOpacity(0.90),
          body: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xfff8f8f8),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (var i = 0; i < _jadwal.length; i++)
                    Column(
                      children: [
                        Center(
                          child: Card(
                            child: InkWell(
                              onTap: () {},
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: const Icon(
                                      Icons.calendar_month,
                                    ),
                                    title: Text(_jadwal[i]['hari_kerja']),
                                    subtitle: Text("${_jadwal[i]['jam_mulai']} Sampai Dengan ${_jadwal[i]['jam_selesai']}"),
                                  ),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                      ],
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  String getNamaPoli(List dataDokter) {
    Map jadwal = {};
    int i = -1;
    dataDokter.forEach((data) => {jadwal[i += 1] = data});
    Map nm_pol = (jadwal[0]['poli_klinik']);
    return nm_pol['nm_poli'];
  }

  bool jadwalDokterPoli(List jadwalDokter) {
    Map jadwal = {};
    int i = -1;
    jadwalDokter.forEach((data) => {jadwal[i += 1] = data});
    setState(() {
      _jadwal = jadwal;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Dokter'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          for (var i = 0; i < _dataDokter.length; i++)
            if (_dataDokter[i]['jadwal_poli'].length > 0)
              Column(
                children: [
                  Center(
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          _showFullModal(context, _dataDokter[i]);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: const FaIcon(FontAwesomeIcons.stethoscope),
                              title: Text(_dataDokter[i]['nm_dokter']),
                              subtitle: Text(
                                  getNamaPoli(_dataDokter[i]['jadwal_poli'])),
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
