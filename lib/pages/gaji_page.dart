import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GajiPage extends StatefulWidget {
  const GajiPage({super.key});

  @override
  State<GajiPage> createState() => _GajiPageState();
}

class _GajiPageState extends State<GajiPage> {
  final moonLanding = DateTime.now();
  String? _tokenSecure;
  final storage = const FlutterSecureStorage();
  var month = DateTime.now();
  Map _dataPendapatan = {};
  Map _dataPendapatanAll = {};
  List<DropdownMenuItem<int>> _bulanSlip = [
    const DropdownMenuItem(value: 0, child: Text("Wait")),
    const DropdownMenuItem(value: 1, child: Text("Wait")),
  ];
  int selectedValue = 1;

  List<DropdownMenuItem<int>> get dropdownItems {
    List<DropdownMenuItem<int>> menuItems = _bulanSlip;
    return menuItems;
  }

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
    getSalaryData(_tokenSecure);
  }

  Future<void> getSalaryData(String? myToken) async {
    String apiUrl = '${const String.fromEnvironment('devUrl')}api/v1/slip/2';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $myToken',
      });

      if (response.statusCode == 200) {
        final dataPendapatan = json.decode(response.body)['data'];
        // print(dataPendapatan);

        setState(() {
          int i = -1;
          int j = -1;
          String bulan = '';
          _bulanSlip = [];
          dataPendapatan.forEach((data) => {
                bulan = DateFormat('MMMM').format(DateTime(0, data['bulan'])),
                _dataPendapatanAll[i += 1] = data,
                _bulanSlip.add(
                    DropdownMenuItem(value: j += 1, child: Text("$bulan 2024")))
              });
          selectedValue = j;
          _dataPendapatan = dataPendapatan[j];
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

    print("--------------- You're in Salary Page ---------------");
    print(_dataPendapatanAll);
  }

  String convertToIDR(String amount) {
    if (amount == 'null') {
      amount = '0';
    }
    String formattedAmount =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.')
            .format(int.parse(amount));

    return formattedAmount.replaceAll(',00', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Data Gaji'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload',
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Reload Data')));
                getSalaryData(_tokenSecure);
              },
            ),
          ]),
      body: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 206, 206, 206),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              DropdownButton(
                  value: selectedValue,
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedValue = newValue!;
                      _dataPendapatan = _dataPendapatanAll[selectedValue];
                    });
                  },
                  items: dropdownItems),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Card(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        title: Text("Pendapatan",
                            style: TextStyle(color: Colors.red, fontSize: 20)),
                        subtitle: Text("Data penghasilan selama satu bulan"),
                      ),
                      // Gaji Pokok
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Gaji Pokok :'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['gaji_pokok'].toString() ==
                                        'null'
                                    ? 'Rp.0'
                                    : convertToIDR(_dataPendapatan['gaji_pokok']
                                        .toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // BPJS TK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('BPJS Tenaga Kerjaan:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['bpjs_tk'].toString() ==
                                        'null'
                                    ? 'Rp.0'
                                    : convertToIDR(
                                        _dataPendapatan['bpjs_tk'].toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // BPJS 4%
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('BPJS 4%:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['bpjs_4p'].toString() ==
                                        'null'
                                    ? 'Rp.0'
                                    : convertToIDR(
                                        _dataPendapatan['bpjs_4p'].toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      //THR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('THR:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['thr'].toString() == 'null'
                                    ? 'Rp.0'
                                    : convertToIDR(
                                        _dataPendapatan['thr'].toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Tunjangan Keluarga
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Tunjangan Keluarga:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['t_keluarga'].toString() ==
                                        'null'
                                    ? 'Rp.0'
                                    : convertToIDR(_dataPendapatan['t_keluarga']
                                        .toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Jaspel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Jasa Pelayanan:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['jaspel'].toString() ==
                                        'null'
                                    ? 'Rp.0'
                                    : convertToIDR(
                                        _dataPendapatan['jaspel'].toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin:
                                const EdgeInsets.only(right: 15, bottom: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Total Gaji: ${convertToIDR(_dataPendapatan['jumlah_gaji'].toString())}",
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Card(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        title: Text("Potongan",
                            style: TextStyle(color: Colors.red, fontSize: 20)),
                        subtitle: Text("Data potongan selama satu bulan"),
                      ),
                      // Pot BPJS TK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Potongan BPJS Tenaga Kerjaan:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                    _dataPendapatan['pot_bpjs_tk'].toString() ==
                                            'null'
                                        ? 'Rp.0'
                                        : convertToIDR(
                                            _dataPendapatan['pot_bpjs_tk']
                                                .toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Pot BPJS 1%
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Potongan BPJS 1%:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                    _dataPendapatan['pot_bpjs_1p'].toString() ==
                                            'null'
                                        ? 'Rp.0'
                                        : convertToIDR(
                                            _dataPendapatan['pot_bpjs_1p']
                                                .toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Pot BPJS 4%
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Potongan BPJS 4%:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                    _dataPendapatan['pot_bpjs_4p'].toString() ==
                                            'null'
                                        ? 'Rp.0'
                                        : convertToIDR(
                                            _dataPendapatan['pot_bpjs_4p']
                                                .toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Potongan Tunjangan Keluarga

                      // Potongan Tunjangan Keluarga
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Potongan Tunjangan Keluarga:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['pot_t_keluarga']
                                            .toString() ==
                                        'null'
                                    ? 'Rp.0'
                                    : convertToIDR(
                                        _dataPendapatan['pot_t_keluarga']
                                            .toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Potongan Bon Bensat
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Potongan Bon Bensat:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['pot_bon'].toString() ==
                                        'null'
                                    ? 'Rp.0'
                                    : convertToIDR(
                                        _dataPendapatan['pot_bon'].toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Potongan THR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Potongan THR:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['pot_thr'].toString() ==
                                        'null'
                                    ? 'Rp.0'
                                    : convertToIDR(
                                        _dataPendapatan['pot_thr'].toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Potongan Simp, Cicilan, dan Bon Koperasi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Potongan Simp Koperasi:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['pot_s_koperasi']
                                            .toString() ==
                                        'null'
                                    ? 'Rp.0'
                                    : convertToIDR(
                                        _dataPendapatan['pot_s_koperasi']
                                            .toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Potongan Cicilan, dan Bon Koperasi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Potongan Cicilan Koperasi:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['pot_cicilan_kop']
                                            .toString() ==
                                        'null'
                                    ? 'Rp.0'
                                    : convertToIDR(
                                        _dataPendapatan['pot_cicilan_kop']
                                            .toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Potongan Bon Koperasi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Potongan Bon Koperasi:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['pot_jajan_kop']
                                            .toString() ==
                                        'null'
                                    ? 'Rp.0'
                                    : convertToIDR(
                                        _dataPendapatan['pot_jajan_kop']
                                            .toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Potongan Kinerja
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Potongan Kinerja:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                    _dataPendapatan['pot_kinerja'].toString() ==
                                            'null'
                                        ? 'Rp.0'
                                        : convertToIDR(
                                            _dataPendapatan['pot_kinerja']
                                                .toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Potongan Kinerja
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Potongan PPH 21:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['pot_pph21'].toString() ==
                                        'null'
                                    ? 'Rp.0'
                                    : convertToIDR(_dataPendapatan['pot_pph21']
                                        .toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Potongan Yatim
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Potongan Yatim + PPNI:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['pot_yatim_ppni']
                                            .toString() ==
                                        'null'
                                    ? 'Rp.0'
                                    : convertToIDR(
                                        _dataPendapatan['pot_yatim_ppni']
                                            .toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Potongan Kasir
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Potongan Kasir:'),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_dataPendapatan['pot_tagihan_kasir']
                                            .toString() ==
                                        'null'
                                    ? 'Rp.0'
                                    : convertToIDR(
                                        _dataPendapatan['pot_tagihan_kasir']
                                            .toString())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin:
                                const EdgeInsets.only(right: 15, bottom: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Total Potongan: ${convertToIDR(_dataPendapatan['jumlah_potongan'].toString())}",
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Card(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Diterima:',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  convertToIDR(
                                      _dataPendapatan['jumlah_diterima']
                                          .toString()),
                                  style: const TextStyle(fontSize: 24),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
