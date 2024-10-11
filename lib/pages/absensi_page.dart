import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hasta_app/welcome_screen.dart';
import 'package:hasta_app/widget/number_home_widget.dart';
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
    // print(userShiftID);
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
          setState(() {
            _isValidQr = 1;
            cameraControllerCheckout.stop();
          });
          _showSimpleModalDialog(context);
        } else {
          debugPrint(apiUrl);
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
            backgroundColor: const Color.fromARGB(255, 165, 240, 136),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 150),
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
                        text: const TextSpan(
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
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Tap to Close!!!')
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
      backgroundColor: const Color(0xff7fc7d9),
      appBar: AppBar(
        title: const Text('Scan Untuk Masuk'),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xff7fc7d9)),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: MobileScanner(
                    fit: BoxFit.cover,
                    controller: cameraControllerCheckout,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        debugPrint('Barcode found! ${barcode.rawValue}');
                        _absensiHandle(_tokenSecure, barcode.rawValue);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const NumbersHomeWidget()
          ],
        ),
      ),
    );
  }
}
