import 'dart:convert';

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hasta_app/components/absensi_notif_card.dart';
import 'package:hasta_app/components/image_button.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final int id;
  final String name;
  final String email;

  const HomePage({
    super.key,
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variables to store the shared preference data
  String? _tokenSecure;
  int _cardColor = 0xffffdee4;
  String _cardTittle = "";
  String _cardMessage = "";
  String _absensiState = "/absensi-cam";

  final storage = const FlutterSecureStorage();

  // Method to load the shared preference data
  void _loadPreferences() async {
    final tokenSecure = await storage.read(key: 'tokenSecure') ?? "";
    final userData = await storage.read(key: 'userData') ?? "";
    setState(() {
      _tokenSecure = tokenSecure;
    });
    // print('Token Anda Adalah: $_token');
    // print('Token Anda Adalah Secure: $_tokenSecure');
    getAbsensiData(_tokenSecure);
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _cardColor = (0xffffdee4);
    _cardTittle = "Anda Belum Absen";
    _cardMessage = "Ketuk disini untuk scan absensi datang";
    _absensiState = "/absensi-cam";
  }

  var now = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');
  late String formattedDate = formatter.format(now);

  Future<void> handleLogout(String token) async {
    const url = '${const String.fromEnvironment('devUrl')}api/v1/logout';
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.post(Uri.parse(url), headers: headers);
    await storage.deleteAll();

    print(response.body);
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
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
        if (dataAbsensiHariIni['shift_hari_ini'].length == 2) {
          if (dataAbsensiHariIni['absensi_hari_ini'].length == 0) {
            await storage.write(
                key: 'shiftID',
                value: jsonEncode(dataAbsensiHariIni['shift_hari_ini'][1]));
          } else {
            await storage.write(
                key: 'shiftID',
                value: jsonEncode(dataAbsensiHariIni['shift_hari_ini'][0]));
          }
        } else {
          await storage.write(
              key: 'shiftID',
              value: jsonEncode(dataAbsensiHariIni['shift_hari_ini'][0]));
        }
        if (dataAbsensiHariIni['shift_hari_ini'].length != 0) {
          if (dataAbsensiHariIni['absensi_hari_ini'].length != 0) {
            setState(() {
              _cardColor = 0xffa4ffa4;
              _cardTittle = "Anda Telah Checkin";
              _cardMessage =
                  "Untuk pulang silahkan ketuk notif ini sekali lagi";
              _absensiState = "/absensi-pulang-cam";
            });
          }
          if (dataAbsensiHariIni['absensi_hari_ini'][0]['check_out'] != null) {
            _cardColor = 0xff91d2ff;
            _cardTittle = "Anda Telah Checkout";
            _cardMessage = "Selamat sore, hati-hati dijalan, sampai jumpa esok";
            _absensiState = "/jadwal";
          }
        } else {
          setState(() {
            _cardColor = 0xffdddddd;
            _cardTittle = "Anda sedang Off (Libur)";
            _cardMessage =
                "Jika ada kesalahan silahkan hubungi Karu, selamat berlibur";
            _absensiState = "/jadwal";
          });
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
      backgroundColor: const Color(0xff7fc7d9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hai, ${widget.name}!',
                            style: const TextStyle(
                              color: Color(0xff0f1035),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 46, 46, 46),
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: const Color(0xffdcf2f1),
                            borderRadius: BorderRadius.circular(12)),
                        child: IconButton(
                          onPressed: () => handleLogout(_tokenSecure!),
                          icon: const Icon(Icons.logout),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            _absensiState,
                          ).then((value) {
                            getAbsensiData(_tokenSecure);
                          });
                        },
                        child: AbsensiNotifCard(
                            cardColor: _cardColor,
                            cardTittle: _cardTittle,
                            cardMessage: _cardMessage),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Favorite',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.more_horiz,
                        color: Colors.black,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          ImageButton(
                            imagePath: "Blabla",
                            icons: Icons.fact_check_rounded,
                            pageRoute: "/jadwal",
                          ),
                          Text(
                            'Jadwal',
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          ImageButton(
                            imagePath: "Blabla",
                            icons: Icons.bed,
                            pageRoute: "/ranap",
                          ),
                          Text(
                            'Ranap',
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          ImageButton(
                            imagePath: "Blabla",
                            icons: Icons.money,
                            pageRoute: "/gaji",
                          ),
                          Text(
                            'Slip',
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          ImageButton(
                            imagePath: "Blabla",
                            icons: Icons.health_and_safety_rounded,
                            pageRoute: "/ralan",
                          ),
                          Text(
                            'Ralan',
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50)),
                child: Container(
                  color: const Color(0xffdcf2f1),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: [
                          // Header Pengumuman
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Pengumuman",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Icon(Icons.more_horiz)
                            ],
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // List Penumuman
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ListView(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                children: const <Widget>[
                                  Card(
                                    color: Colors.white,
                                    child: ListTile(
                                      // leading: Icon(Icons.close),
                                      title: Text('Beta Tester Release'),
                                      subtitle: Text(
                                          'Anda beruntung menjadi bagian pengembangan APP Ini'),
                                      // trailing: Icon(Icons.more_vert),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        items: const [
          CurvedNavigationBarItem(
            child: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.perm_identity),
            label: 'Profil',
          ),
        ],
        color: const Color(0xff7fc7d9),
        buttonBackgroundColor: const Color(0xff7fc7d9),
        backgroundColor: const Color(0xffdcf2f1),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          // setState(() {
          //   _page = index;
          // });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
