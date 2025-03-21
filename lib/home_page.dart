import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hasta_app/components/absensi_notif_card.dart';
import 'package:hasta_app/components/image_button.dart';
import 'package:hasta_app/pages/profil_page.dart';
import 'package:hasta_app/pages/quizzes_page.dart';
import 'package:hasta_app/services/helper/shared_perference_helper.dart';
import 'package:hasta_app/widget/number_home_widget.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

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
  String? _tokenSecure;
  int _cardColor = 0xffffdee4;
  String _cardTittle = "";
  String _cardMessage = "";
  String _absensiState = "/absensi-cam";
  bool _alreadyUpload = false;
  final Map _dataPengumuman = {};

  final storage = const FlutterSecureStorage();
  void _loadPreferences() async {
    final tokenSecure = await storage.read(key: 'tokenSecure') ?? "";
    setState(() {
      _tokenSecure = tokenSecure;
    });
    getAbsensiData(_tokenSecure);
    getPengumuman(_tokenSecure);
    getDataUpload();
  }

  Future<void> getPengumuman(String? myToken) async {
    String apiUrl =
        '${const String.fromEnvironment('devUrl')}api/v1/pengumuman';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $myToken',
      });

      if (response.statusCode == 200) {
        final dataPengumuman = json.decode(response.body)['data'];

        setState(() {
          int i = -1;
          dataPengumuman.forEach((data) => {_dataPengumuman[i += 1] = data});
        });
      } else {
        debugPrint(apiUrl);
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      } else {}
    }
  }

  Future<void> getDataUpload() async {
    String apiUrl = '${const String.fromEnvironment('devUrl')}api/v1/esurvey';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_tokenSecure',
      });

      if (response.statusCode == 200) {
        final dataUpload = json.decode(response.body)['data'];

        setState(() {
          if (dataUpload['alreadyUp'] == 1) {
            _alreadyUpload = true;
          }
        });
      } else {
        debugPrint(apiUrl);
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      } else {}
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _cardColor = 0xffdddddd;
    _cardTittle = "Anda sedang Off (Libur)";
    _cardMessage = "Jika ada kesalahan silahkan hubungi Karu, selamat berlibur";
    _absensiState = "/jadwal";
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

    await http.post(Uri.parse(url), headers: headers);
    await storage.deleteAll();
    await SharedPrefHelper.removeToken();

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

      if (response.statusCode == 200) {
        final dataAbsensiHariIni = json.decode(response.body)['data'];

        if (dataAbsensiHariIni['check_in'] == null) {
          setState(() {
            _cardColor = 0xffffbaba;
            _cardTittle = "Anda Belum Absen";
            _cardMessage = "Untuk absensi silahkan ketuk notif ini!!!";
            _absensiState = "/absensi-cam";
          });
          await storage.write(
              key: 'userShiftId', value: jsonEncode(dataAbsensiHariIni['id']));
        } else if (dataAbsensiHariIni['check_out'] == null) {
          setState(() {
            _cardColor = 0xffa4ffa4;
            _cardTittle = "Anda Telah Checkin";
            _cardMessage = "Untuk pulang silahkan ketuk notif ini sekali lagi";
            _absensiState = "/absensi-pulang-cam";
          });
          await storage.write(
              key: 'userShiftId', value: jsonEncode(dataAbsensiHariIni['id']));
        } else {
          setState(() {
            _cardColor = 0xff91d2ff;
            _cardTittle = "Anda Telah Checkout";
            _cardMessage = "Selamat sore, hati-hati dijalan, sampai jumpa esok";
            _absensiState = "/jadwal";
          });
        }
      } else {
        debugPrint(apiUrl);
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xff7fc7d9)),
      title: 'Home',
      home: PersistentTabView(
        tabs: [
          PersistentTabConfig(
            screen: Scaffold(
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
                                    'Hai, ${widget.name.length > 10 ? '${widget.name.substring(0, 10)}...' : widget.name}!',
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
                          const NumbersHomeWidget(),
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
                                    pageRoute: "/dokter",
                                  ),
                                  Text(
                                    'Jadwal Dokter',
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
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                      child: ElevatedButton.icon(
                        icon: _alreadyUpload
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.upload,
                                color: Colors.red,
                              ),
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/upload-esurvey')
                              .then((value) {
                            getDataUpload();
                          });
                        },
                        label: Text(_alreadyUpload
                            ? 'Anda sudah upload E-Survey'
                            : 'Upload E-Survey'),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50)),
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/backgrounds/rs_01.png"),
                              fit: BoxFit.cover,
                            ),
                            color: Color(0xffdcf2f1),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Pengumuman",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Icon(Icons.more_horiz)
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: ListView(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        children: <Widget>[
                                          for (var i = 0;
                                              i < _dataPengumuman.length;
                                              i++)
                                            if (_dataPengumuman[i]['status'] ==
                                                1)
                                              Card(
                                                color: Colors.white,
                                                child: ListTile(
                                                  title: Text(_dataPengumuman[i]
                                                      ['name']),
                                                  subtitle: Text(
                                                      _dataPengumuman[i]
                                                          ['content']),
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
            ),
            item: ItemConfig(
              icon: const Icon(Icons.home),
              title: "Home",
            ),
          ),
          PersistentTabConfig(
            screen: const SafeArea(
              child: QuizzesPage(),
            ),
            item: ItemConfig(
              icon: const Icon(Icons.quiz),
              title: "Quiz",
            ),
          ),
          PersistentTabConfig(
            screen: SafeArea(
              child: ProfilPage(),
            ),
            item: ItemConfig(
              icon: const Icon(Icons.tag_faces),
              title: "Profil",
            ),
          ),
        ],
        navBarBuilder: (navBarConfig) => Style1BottomNavBar(
          navBarConfig: navBarConfig,
        ),
      ),
    );
  }
}
