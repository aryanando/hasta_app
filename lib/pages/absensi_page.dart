import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hasta_app/login_screen.dart';
import 'package:hasta_app/welcome_screen.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

class AbsensiScanPage extends StatefulWidget {
  const AbsensiScanPage({super.key});

  @override
  State<StatefulWidget> createState() => _AbsensiScanPageState();
}

class _AbsensiScanPageState extends State<AbsensiScanPage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? _tokenSecure;
  int _isValidQr = 0;
  Widget _backButton = const Icon(Icons.cancel, size: 30);

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    _isValidQr = 0;
    _loadPreferences();
    super.initState();
  }

  void _loadPreferences() async {
    final tokenSecure = await storage.read(key: 'tokenSecure') ?? "";
    setState(() {
      _tokenSecure = tokenSecure;
    });
    print('Token Anda Adalah: $_tokenSecure');
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
      print('Token Anda Adalah Secure: $myToken');
      // _absensiHandle(myToken);
      // absensiHandle(myToken);
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

  Future<void> _absensiHandle(String? token) async {
    if (_isValidQr == 0) {
      const apiUrl = '${const String.fromEnvironment('devUrl')}api/v1/absensi/';
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: jsonEncode({
            'shift_id': 1,
            'user_id': 9,
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
          await controller?.pauseCamera();

          setState(() {
            _isValidQr = 1;
            _backButton = IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.check_box_rounded));
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

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Absensi"),
        backgroundColor: const Color(0xff7fc7d9),
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _backButton,
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      _absensiHandle(_tokenSecure);
      controller?.dispose();
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
