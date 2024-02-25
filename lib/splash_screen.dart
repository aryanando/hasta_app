import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  String? _tokenSecure;

  final storage = const FlutterSecureStorage();
  late AnimationController controller;

  // Method to load the shared preference data
  void _loadPreferences() async {
    final tokenSecure = await storage.read(key: 'tokenSecure') ?? "";
    setState(() {
      _tokenSecure = tokenSecure;
    });
    // print('Token Anda Adalah: $_token');
    _checkToken(_tokenSecure);
  }

  void _checkToken(String? myToken){
    if(myToken != Null){
      print('Token Anda Adalah Secure: $myToken');
      getUserData(myToken);
    }
  }

  Future<void> getUserData(String? token) async {
    const apiUrl = '${const String.fromEnvironment('devUrl')}api/v1/login';
  }


  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        
        setState(() {});
      });
    controller.repeat(reverse: false);
    super.initState();
    _loadPreferences();
    
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color(0xff7fc7d9),
          Color(0xff365486),
        ])),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 150.0),
              child: Image(image: AssetImage('assets/logo.png')),
            ),
            const SizedBox(
              height: 100,
            ),
            CircularProgressIndicator(
              color: Colors.white,
              value: controller.value,
              semanticsLabel: 'Circular progress indicator',
            ),
          ],
        ),
      ),
    );
  }
}
