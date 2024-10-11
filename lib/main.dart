import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hasta_app/login_screen.dart';
import 'package:hasta_app/pages/absensi_page.dart';
import 'package:hasta_app/pages/absensi_pulang_page.dart';
import 'package:hasta_app/pages/dokter_page.dart';
import 'package:hasta_app/pages/gaji_page.dart';
import 'package:hasta_app/pages/jadwal_page.dart';
import 'package:hasta_app/pages/ralan_page.dart';
import 'package:hasta_app/pages/ranap_page.dart';
import 'package:hasta_app/pages/upload_esurvey_page.dart';
import 'package:hasta_app/reg_screen.dart';
import 'package:hasta_app/splash_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: ('inter'),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const RegScreen(),
        '/absensi-cam': (context) => const AbsensiScanPage(),
        '/absensi-pulang-cam': (context) => const AbsensiPulangScanPage(),
        '/jadwal': (context) => const JadwalPage(),
        '/ranap': (context) => const RanapPage(),
        '/gaji': (context) => const GajiPage(),
        '/ralan': (context) => const RalanPage(),
        '/dokter': (context) => const DokterPage(),
        '/upload-esurvey': (context) => const UploadEsurveyPage(),
      },
    );
  }
}
