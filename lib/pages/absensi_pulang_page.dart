import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hasta_app/welcome_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

class AbsensiPulangScanPage extends StatefulWidget {
  const AbsensiPulangScanPage({super.key});

  @override
  State<StatefulWidget> createState() => _AbsensiPulangPageState();
}

class _AbsensiPulangPageState extends State<AbsensiPulangScanPage> {
  MobileScannerController cameraControllerCheckout = MobileScannerController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? _tokenSecure;
  int _isValidQr = 0;
  int _idAbsensi = 0;

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
    setState(() {
      _tokenSecure = tokenSecure;
    });
    // print('Token Anda Adalah: $_tokenSecure');
    if (_tokenSecure != "") {
      _checkToken(_tokenSecure);
    } else {
      print(_tokenSecure);
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
      getAbsensiData(myToken);
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
        final response = await http.put(
          Uri.parse(apiUrl),
          body: jsonEncode({
            'absens_id': _idAbsensi,
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

  Future<void> getAbsensiData(String? myToken) async {
    const apiUrl = '${const String.fromEnvironment('devUrl')}api/v1/absensi';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $myToken',
      });

      // inspect(response.statusCode);

      if (response.statusCode == 200) {
        //mengabil data user
        final dataAbsensiHariIni = json.decode(response.body)['data'];
        print(dataAbsensiHariIni);
        if (dataAbsensiHariIni['shift_hari_ini'].length != 0) {
          if (dataAbsensiHariIni['absensi_hari_ini'].length != 0) {
            setState(() {
              _idAbsensi = dataAbsensiHariIni['absensi_hari_ini'][0]['id'];
            });
          }
        }

        print(json.decode(response.body));
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
        title: const Text('Mobile Scanner'),
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
