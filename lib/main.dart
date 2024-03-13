import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hasta_app/home_page.dart';
import 'package:hasta_app/login_screen.dart';
import 'package:hasta_app/pages/absensi_page.dart';
import 'package:hasta_app/pages/gaji_page.dart';
import 'package:hasta_app/pages/ralan_page.dart';
import 'package:hasta_app/pages/ranap_page.dart';
import 'package:hasta_app/reg_screen.dart';
import 'package:hasta_app/splash_screen.dart';

import 'welcome_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: ('inter'),
        useMaterial3: true,
      ),
      // home: const SplashScreen(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const RegScreen(),
        '/absensi-cam': (context) => const AbsensiScanPage(),
        '/ranap': (context) => const RanapPage(),
        '/gaji': (context) => const GajiPage(),
        '/ralan': (context) => const RalanPage(),
      },
    );
  }
}
