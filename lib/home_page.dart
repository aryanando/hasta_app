import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:hasta_app/components/image_button.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final int id;
  final String name;
  final String email;
  final String token;

  const HomePage(
      {super.key,
      required this.id,
      required this.name,
      required this.email,
      required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var now = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');
  late String formattedDate = formatter.format(now);
  Future<void> handleLogout(String token) async {
    const url = '${const String.fromEnvironment('devUrl')}api/v1/logout';
    final headers = {
      'Authorization': 'Bearer ${widget.token}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(Uri.parse(url), headers: headers);

    print(response.body);
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff7fc7d9),
      // appBar: AppBar(
      //   title: const Text('Home'),
      //   actions: [
      //     IconButton(
      //       onPressed: () => handleLogout(widget.token),
      //       icon: const Icon(Icons.logout),
      //     ),
      //   ],
      // ),
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
                          onPressed: () => handleLogout(widget.token),
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
                    children: const <Widget>[
                      Card(
                        color: Color(0xffffdee4),
                        child: ListTile(
                          leading: Icon(Icons.close),
                          title: Text('Anda Belum Absen'),
                          subtitle: Text('Silahkan segera melakukan absensi'),
                          trailing: Icon(Icons.more_vert),
                        ),
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
                          ImageButton(imagePath: "Blabla"),
                          Text(
                            'Absensi',
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          ImageButton(imagePath: "Blabla"),
                          Text(
                            'Absensi',
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          ImageButton(imagePath: "Blabla"),
                          Text(
                            'Absensi',
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          ImageButton(imagePath: "Blabla"),
                          Text(
                            'Absensi',
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
                  color: Color(0xffdcf2f1),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
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

                          SizedBox(height: 20,),

                          // List Penumuman
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ListView(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                children: <Widget>[
                                  Card(
                                    color: Colors.white,
                                    child: ListTile(
                                      // leading: Icon(Icons.close),
                                      title: Text('Rapat Besar 23-02-20s4'),
                                      subtitle:
                                          Text('Silahkan datang tepat waktu'),
                                      // trailing: Icon(Icons.more_vert),
                                    ),
                                  ),
                                  Card(
                                    color: Colors.white,
                                    child: ListTile(
                                      // leading: Icon(Icons.close),
                                      title: Text('Rapat Besar 23-02-20s4'),
                                      subtitle:
                                          Text('Silahkan datang tepat waktu'),
                                      // trailing: Icon(Icons.more_vert),
                                    ),
                                  ),
                                  Card(
                                    color: Colors.white,
                                    child: ListTile(
                                      // leading: Icon(Icons.close),
                                      title: Text('Rapat Besar 23-02-20s4'),
                                      subtitle:
                                          Text('Silahkan datang tepat waktu'),
                                      // trailing: Icon(Icons.more_vert),
                                    ),
                                  ),
                                  Card(
                                    color: Colors.white,
                                    child: ListTile(
                                      // leading: Icon(Icons.close),
                                      title: Text('Rapat Besar 23-02-20s4'),
                                      subtitle:
                                          Text('Silahkan datang tepat waktu'),
                                      // trailing: Icon(Icons.more_vert),
                                    ),
                                  ),
                                  Card(
                                    color: Colors.white,
                                    child: ListTile(
                                      // leading: Icon(Icons.close),
                                      title: Text('Rapat Besar 23-02-20s4'),
                                      subtitle:
                                          Text('Silahkan datang tepat waktu'),
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
            child: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.newspaper),
            label: 'Feed',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.perm_identity),
            label: 'Profil',
          ),
        ],
        color: const Color(0xff7fc7d9),
        buttonBackgroundColor: const Color(0xff7fc7d9),
        backgroundColor: Color(0xffdcf2f1),
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
