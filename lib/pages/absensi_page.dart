import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hasta_app/welcome_screen.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

class AbsensiScanPage extends StatefulWidget {
  const AbsensiScanPage({super.key});

  @override
  State<StatefulWidget> createState() => _AbsensiScanPageState();
}

class _AbsensiScanPageState extends State<AbsensiScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? _tokenSecure;
  int _isValidQr = 0;
  MobileScannerController cameraController = MobileScannerController();
  final storage = const FlutterSecureStorage();
  Map _userData = {};
  Map _shiftID = {};
  

  @override
  void initState() {
    // TODO: implement initState
    _isValidQr = 0;
    _loadPreferences();
    super.initState();
    cameraController = MobileScannerController();
  }

  void _loadPreferences() async {
    final tokenSecure = await storage.read(key: 'tokenSecure') ?? "";
    final userData = await storage.read(key: 'userData') ?? "{}";
    final shiftID = await storage.read(key: 'shiftID') ?? "{}";

    setState(() {
      cameraController.start();
      _userData = jsonDecode(userData);
      _shiftID = jsonDecode(shiftID);
      _tokenSecure = tokenSecure;
    });
      
    // print('Token Anda Adalah: $_tokenSecure');
    if (_tokenSecure != "") {
      _checkToken(_tokenSecure);
    } else {
      
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
        (route) => false,
      );
    }
  }

  void _checkToken(String? myToken) {
    if (myToken != "") {
      // print('Token Anda Adalah Secure: $myToken');
      // _absensiHandle(myToken);
      // absensiHandle(myToken);
      print('asdd ${_shiftID['id']}' );
    } else {
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _absensiHandle(String? token, String? absensiToken) async {
    if (_isValidQr == 0) {
      String apiUrl =
          '${const String.fromEnvironment('devUrl')}api/v1/absensi/$absensiToken';
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: jsonEncode({
            'shift_id': _shiftID['id'],
            'user_id': _userData['id'],
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          //menyimpan data token
          print(response.body);

          setState(() {
            _isValidQr = 1;
            cameraController.stop();
          });
        } else {
          debugPrint(apiUrl);
          print(response.statusCode);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Mobile Scanner'),
          actions: [
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  switch (state as TorchState) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off, color: Colors.grey);
                    case TorchState.on:
                      return const Icon(Icons.flash_on, color: Colors.yellow);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.toggleTorch(),
            ),
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.cameraFacingState,
                builder: (context, state, child) {
                  switch (state as CameraFacing) {
                    case CameraFacing.front:
                      return const Icon(Icons.camera_front);
                    case CameraFacing.back:
                      return const Icon(Icons.camera_rear);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.switchCamera(),
            ),
          ],
        ),
        body: MobileScanner(
          // fit: BoxFit.contain,
          controller: cameraController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            final Uint8List? image = capture.image;
            for (final barcode in barcodes) {
              debugPrint('Barcode found! ${barcode.rawValue}');
              _absensiHandle(_tokenSecure, barcode.rawValue);
            }
          },
        ),
    );
  }

}
