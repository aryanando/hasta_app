import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hasta_app/services/api_client.dart';
import 'package:hasta_app/widget/number_widget.dart';
import 'package:http/http.dart' as http;

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  bool _alreadyUpload = false;
  String? _tokenSecure;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool hasError = false;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await ApiClient().get("/me");
      if (response.data['success']) {
        setState(() {
          userData = response.data['data'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load user data.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print("❌ Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff7fc7d9),
        title: const Text('Profil'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error loading profile data."))
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildProfilePhoto(),
                    const SizedBox(height: 24),
                    _buildUserInfo(),
                    const SizedBox(height: 24),
                    const NumbersWidget(),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton.icon(
                        icon: _alreadyUpload
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const Icon(Icons.upload, color: Colors.red),
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/upload-esurvey')
                              .then((value) {
                            getDataUpload();
                          });
                        },
                        label: Text(_alreadyUpload
                            ? 'Anda sudah upload E-Survey'
                            : 'Upload E-Survey'),
                      ),
                    ),
                  ],
                ),
    );
  }

  /// 🔹 Builds Profile Information Section
  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          userData?['name'] ?? 'Unknown User',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          userData?['email'] ?? 'No Email Available',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Unit: ${userData?['unit']?[0]['unit_name'] ?? 'N/A'}",
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhoto() {
    String? imageUrl = userData?['photo'] != null
        ? 'https://api.batubhayangkara.com/storage/${userData?['photo']}'
        : null;

    return Center(
      child: CircleAvatar(
        radius: 64,
        backgroundColor: Colors.grey[200], // Placeholder background
        backgroundImage: imageUrl != null
            ? NetworkImage(imageUrl)
            : const AssetImage("assets/default_avatar.png")
                as ImageProvider, // Default image
        onBackgroundImageError: (exception, stackTrace) {
          print("❌ Image load failed: $exception");
        },
      ),
    );
  }

  /// 🔹 Fetches Data Upload Status
  Future<void> getDataUpload() async {
    try {
      final response = await ApiClient().get("/esurvey");
      if (response.data['success']) {
        setState(() {
          _alreadyUpload = response.data['data']['alreadyUp'] == 1;
        });
      }
    } catch (e) {
      print("❌ Error fetching e-survey status: $e");
    }
  }
}
