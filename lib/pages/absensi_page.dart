import 'dart:convert';

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
MobileScannerController cameraControllerCheckout = MobileScannerController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? _tokenSecure, _userShiftID;
  int _isValidQr = 0;

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    cameraControllerCheckout.start();
    _isValidQr = 0;
    _loadPreferences();
    super.initState();
  }

  void _loadPreferences() async {
    final tokenSecure = await storage.read(key: 'tokenSecure') ?? "";
    final userShiftID = await storage.read(key: 'userShiftId') ?? "{}";
    print(userShiftID);
    setState(() {
      _tokenSecure = tokenSecure;
      _userShiftID = userShiftID;
    });
    _checkToken(tokenSecure);
  }

  void _checkToken(String? myToken) {
    if (myToken == "") {
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
          '${const String.fromEnvironment('devUrl')}api/v1/absensi/$absensiToken/in';
      try {
        final response = await http.put(
          Uri.parse(apiUrl),
          body: jsonEncode({
            'user_shift_id': _userShiftID,
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
            cameraControllerCheckout.stop();
          });
          // Navigator.pop(context);

          //berpindah halaman
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
        title: const Text('Scan Untuk Masuk'),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraControllerCheckout.torchState,
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
            onPressed: () => cameraControllerCheckout.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraControllerCheckout.cameraFacingState,
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
            onPressed: () => cameraControllerCheckout.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        // fit: BoxFit.contain,
        controller: cameraControllerCheckout,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            debugPrint('Barcode found! ${barcode.rawValue}');
            _absensiHandle(_tokenSecure, barcode.rawValue);
          }
        },
      ),
    );
  }
}
