import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hasta_app/home_page.dart';
import 'package:hasta_app/login_screen.dart';
import 'package:hasta_app/welcome_screen.dart';
import 'package:http/http.dart' as http;

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

  void _loadPreferences() async {
    final tokenSecure = await storage.read(key: 'tokenSecure') ?? "";
    setState(() {
      _tokenSecure = tokenSecure;
    });
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
      getUserData(myToken);
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

  Future<void> getUserData(String? token) async {
    const apiUrl = '${const String.fromEnvironment('devUrl')}api/v1/me';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      inspect(response.statusCode);

      if (response.statusCode == 200) {
        final user = json.decode(response.body)['data'];
        await storage.write(key: 'data', value: response.body);
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              id: user['id'],
              name: user['name'],
              email: user['email'],
            ),
          ),
          (route) => false,
        );
      } else {
        debugPrint(apiUrl);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: false);
    super.initState();
    Future.delayed(
      const Duration(seconds: 3),
      () {
        _loadPreferences();
      },
    );
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
              padding: EdgeInsets.fromLTRB(20, 150, 20, 0),
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
