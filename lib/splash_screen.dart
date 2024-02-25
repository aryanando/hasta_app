import 'package:flutter/material.dart';
import 'package:hasta_app/reg_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // Variables to store the shared preference data
  String? _token;
  String? _name;

  // Method to load the shared preference data
  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? '';
      _name = prefs.getString('name') ?? '';
    });
    print('Token Anda Adalah: $_token');
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
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
        child: Column(children: [
          const Padding(
            padding: EdgeInsets.only(top: 150.0),
            child: Image(image: AssetImage('assets/logo.png')),
          ),
          const SizedBox(
            height: 100,
          ),
          Text(
            'Selamat Datang $_name',
            style: const TextStyle(fontSize: 30, color: Colors.white),
          ),
          const SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white),
              ),
              child: const Center(
                child: Text(
                  'Masuk',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const RegScreen()));
            },
            child: Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white),
              ),
              child: const Center(
                child: Text(
                  'Daftar',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          ),
          // const Spacer(),
          // const Text(
          //   'Login with Social Media',
          //   style: TextStyle(fontSize: 17, color: Colors.white),
          // ), //
          // const SizedBox(
          //   height: 12,
          // ),
          // const Image(image: AssetImage('assets/social.png'))
        ]),
      ),
    );
  }
}
