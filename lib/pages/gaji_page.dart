import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GajiPage extends StatefulWidget {
  const GajiPage({super.key});

  @override
  State<GajiPage> createState() => _GajiPageState();
}

class _GajiPageState extends State<GajiPage> {
  final storage = const FlutterSecureStorage();
  String? _tokenSecure;
  int selectedMonthIndex = 0;
  List<Map<String, dynamic>> salaryData = [];
  Map<String, dynamic> currentSalary = {};
  List<DropdownMenuItem<int>> dropdownItems = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _tokenSecure = await storage.read(key: 'tokenSecure');
    if (_tokenSecure != null) {
      setState(() {}); // Ensures UI updates with token
      getSalaryData();
    }
  }

  Future<void> getSalaryData() async {
    String apiUrl = '${const String.fromEnvironment('devUrl')}api/v1/slip/2';

    try {
      final response =
          await http.get(Uri.parse(apiUrl), headers: _getHeaders());
      if (response.statusCode == 200) {
        final data =
            List<Map<String, dynamic>>.from(json.decode(response.body)['data']);

        setState(() {
          salaryData = data;
          dropdownItems = data.asMap().entries.map((entry) {
            final i = entry.key;
            final salary = entry.value;
            final month =
                DateFormat('MMMM').format(DateTime(0, salary['bulan']));
            final year = salary['tahun'].toString();
            return DropdownMenuItem(value: i, child: Text("$month $year"));
          }).toList();

          if (salaryData.isNotEmpty) {
            selectedMonthIndex = salaryData.length - 1;
            currentSalary = salaryData[selectedMonthIndex];
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching salary data: $e");
    }
  }

  String convertToIDR(String? amount) {
    if (amount == null || amount == 'null') return 'Rp.0';
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.')
        .format(int.parse(amount))
        .replaceAll(',00', '');
  }

  Map<String, String> _getHeaders() {
    return {
      'Authorization': 'Bearer $_tokenSecure',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Gaji'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: getSalaryData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown to select month
            DropdownButton<int>(
              value: selectedMonthIndex,
              items: dropdownItems,
              onChanged: (int? newIndex) {
                setState(() {
                  selectedMonthIndex = newIndex!;
                  currentSalary = salaryData[selectedMonthIndex];
                });
              },
              isExpanded: true,
            ),

            const SizedBox(height: 16),

            // Salary Details
            Expanded(
              child: ListView(
                children: [
                  _buildSection("Pendapatan", Colors.green, [
                    _buildSalaryItem("Gaji Pokok", currentSalary['gaji_pokok']),
                    _buildSalaryItem("BPJS TK", currentSalary['bpjs_tk']),
                    _buildSalaryItem("BPJS 4%", currentSalary['bpjs_4p']),
                    _buildSalaryItem("THR", currentSalary['thr']),
                    _buildSalaryItem(
                        "Tunjangan Keluarga", currentSalary['t_keluarga']),
                    _buildSalaryItem("Jasa Pelayanan", currentSalary['jaspel']),
                    _buildSalaryItem("Total Gaji", currentSalary['jumlah_gaji'],
                        isTotal: true),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection("Potongan", Colors.red, [
                    _buildSalaryItem(
                        "Potongan BPJS TK", currentSalary['pot_bpjs_tk']),
                    _buildSalaryItem(
                        "Potongan BPJS 1%", currentSalary['pot_bpjs_1p']),
                    _buildSalaryItem(
                        "Potongan BPJS 4%", currentSalary['pot_bpjs_4p']),
                    _buildSalaryItem(
                        "Potongan Kinerja", currentSalary['pot_kinerja']),
                    _buildSalaryItem("Potongan THR", currentSalary['pot_thr']),
                    _buildSalaryItem(
                        "Potongan PPH 21", currentSalary['pot_pph21']),
                    _buildSalaryItem(
                        "Total Potongan", currentSalary['jumlah_potongan'],
                        isTotal: true),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection("Gaji Diterima", Colors.blue, [
                    _buildSalaryItem(
                        "Total Diterima", currentSalary['jumlah_diterima'],
                        isTotal: true, fontSize: 24),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Color color, List<Widget> items) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const Divider(),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryItem(String title, dynamic value,
      {bool isTotal = false, double fontSize = 16}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(convertToIDR(value?.toString()),
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
