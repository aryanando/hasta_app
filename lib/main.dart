import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hasta_app/login_screen.dart';
import 'package:hasta_app/pages/absensi_calendar_page.dart';
import 'package:hasta_app/pages/absensi_histori.dart';
import 'package:hasta_app/pages/absensi_page.dart';
import 'package:hasta_app/pages/absensi_pulang_page.dart';
import 'package:hasta_app/pages/dokter_page.dart';
import 'package:hasta_app/pages/gaji_page.dart';
import 'package:hasta_app/pages/quizzes_page.dart';
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
        fontFamily: 'inter',
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/absensi-cam') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AbsensiScanPage(shiftID: args['shiftID']),
          );
        }

        if (settings.name == '/absensi-pulang-cam') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) =>
                AbsensiPulangScanPage(shiftID: args['shiftID']),
          );
        }

        // Default named routes (for pages without params)
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const RegScreen());
          case '/jadwal':
            return MaterialPageRoute(
                builder: (_) => const AbsensiCalendarPage());
          case '/histori-kehadiran':
            return MaterialPageRoute(
                builder: (_) => const AbsensiHistoriPage());
          case '/ranap':
            return MaterialPageRoute(builder: (_) => RanapListPage());
          case '/gaji':
            return MaterialPageRoute(builder: (_) => const GajiPage());
          case '/ralan':
            return MaterialPageRoute(builder: (_) => const RalanPage());
          case '/dokter':
            return MaterialPageRoute(builder: (_) => const DokterPage());
          case '/upload-esurvey':
            return MaterialPageRoute(builder: (_) => const UploadEsurveyPage());
          case '/quiz':
            return MaterialPageRoute(builder: (_) => const QuizzesPage());
        }

        // 404 fallback
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("404 - Page Not Found")),
          ),
        );
      },
    );
  }
}
