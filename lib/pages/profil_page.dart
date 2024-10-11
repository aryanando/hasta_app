import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hasta_app/widget/number_widget.dart';
import 'package:http/http.dart' as http;

class ProfilPage extends StatefulWidget {
  final String name;
  final String email;

  const ProfilPage({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  get onClicked => null;
  bool _alreadyUpload = false;
  String? _tokenSecure;
  final storage = const FlutterSecureStorage();

  void _loadPreferences() async {
    final tokenSecure = await storage.read(key: 'tokenSecure') ?? "";
    setState(() {
      _tokenSecure = tokenSecure;
    });
    getDataUpload();
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> getDataUpload() async {
    String apiUrl = '${const String.fromEnvironment('devUrl')}api/v1/esurvey';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_tokenSecure',
      });

      if (response.statusCode == 200) {
        //mengabil data user
        final dataUpload = json.decode(response.body)['data'];

        setState(() {
          if (dataUpload['alreadyUp'] == 1) {
            _alreadyUpload = true;
            // print(_dataUploadImage);
          }
        });
      } else {
        debugPrint(apiUrl);
        // print(response.statusCode);
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
        backgroundColor: const Color(0xff7fc7d9),
        title: const Text('Profil'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          photoWidget(),
          const SizedBox(
            height: 24,
          ),
          nameWidget(widget.name, widget.email),
          const SizedBox(
            height: 24,
          ),
          const NumbersWidget(),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 8.0),
            child: ElevatedButton.icon(
              icon: _alreadyUpload
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                  : const Icon(
                      Icons.upload,
                      color: Colors.red,
                    ),
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

  Widget nameWidget(String name, String email) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        Text(
          email,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget photoWidget() {
    const image = NetworkImage(
        'https://www.gravatar.com/avatar/2c7d99fe281ecd3bcd65ab915bac6dd5?s=250');
    return Center(
      child: Stack(
        children: [
          ClipOval(
            child: Container(
              padding: const EdgeInsets.all(2),
              color: Colors.white,
              child: ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: Ink.image(
                    image: image,
                    fit: BoxFit.cover,
                    width: 128,
                    height: 128,
                    child: InkWell(
                      onTap: onClicked,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: ClipOval(
              child: Container(
                padding: const EdgeInsets.all(2),
                color: Colors.white,
                child: ClipOval(
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    color: Colors.black,
                    child: const Icon(
                      color: Colors.white,
                      Icons.edit,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
