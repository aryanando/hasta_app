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
  final storage = const FlutterSecureStorage();
  String? _tokenSecure;
  List<Map<String, dynamic>> _dataDokter = [];
  List<Map<String, dynamic>> _jadwal = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _tokenSecure = await storage.read(key: 'tokenSecure');
    if (_tokenSecure != null) {
      getDokterData();
    }
  }

  Future<void> getDokterData() async {
    String apiUrl = '${const String.fromEnvironment('devUrl')}api/v1/dokter';

    try {
      final response =
          await http.get(Uri.parse(apiUrl), headers: _getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          _dataDokter = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      debugPrint("Error fetching doctor data: $e");
    }
  }

  Map<String, String> _getHeaders() {
    return {
      'Authorization': 'Bearer $_tokenSecure',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  void _showFullModal(BuildContext context, Map<String, dynamic> dokter) {
    setState(() {
      _jadwal = List<Map<String, dynamic>>.from(dokter['jadwal_poli']);
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      isScrollControlled: true, // Ensures the modal adapts to content
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5, // Default modal height (50% of screen)
          minChildSize: 0.3, // Minimum height when dragged down
          maxChildSize: 0.9, // Maximum modal height
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    dokter['nm_dokter'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),

                  // Scrollable List of Doctor Schedules
                  Expanded(
                    child: ListView.builder(
                      controller:
                          controller, // Attach Draggable Scroll Controller
                      itemCount: _jadwal.length,
                      itemBuilder: (context, index) {
                        final jadwal = _jadwal[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today,
                                color: Colors.blue),
                            title: Text(jadwal['hari_kerja'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                "${jadwal['jam_mulai']} - ${jadwal['jam_selesai']}"),
                          ),
                        );
                      },
                    ),
                  ),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Tutup"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String getNamaPoli(List<dynamic> jadwalPoli) {
    if (jadwalPoli.isEmpty) return "Tidak ada jadwal";
    return jadwalPoli.first['poli_klinik']['nm_poli'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Dokter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: getDokterData,
          ),
        ],
      ),
      body: _dataDokter.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _dataDokter.length,
              itemBuilder: (context, index) {
                final dokter = _dataDokter[index];
                if (dokter['jadwal_poli'].isEmpty)
                  return const SizedBox.shrink();

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const FaIcon(FontAwesomeIcons.stethoscope,
                        color: Colors.blue),
                    title: Text(dokter['nm_dokter'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(getNamaPoli(dokter['jadwal_poli'])),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showFullModal(context, dokter),
                  ),
                );
              },
            ),
    );
  }
}
