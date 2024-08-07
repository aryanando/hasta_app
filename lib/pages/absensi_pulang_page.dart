import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
          '${const String.fromEnvironment('devUrl')}api/v1/absensi/$absensiToken/out';
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
          _showSimpleModalDialog(context);
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

  _showSimpleModalDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Color.fromARGB(255, 165, 240, 136),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              
              constraints: BoxConstraints(maxHeight: 150),
              child: InkWell(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                            text: "Success !!!",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 26,
                                color: Colors.black,
                                wordSpacing: 1)),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          icon: const FaIcon(FontAwesomeIcons.check)),
                          SizedBox(height: 20,),
                          Text('Tap to Close!!!')
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Untuk Pulang'),
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
