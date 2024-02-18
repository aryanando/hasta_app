import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(25.0),
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
                        style: TextStyle(
                          color: Color(0xff0f1035),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                            color: Color.fromARGB(255, 46, 46, 46),
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xffdcf2f1),
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.notifications),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      //       Text('Welcome, ${widget.name}!'),
      //       const SizedBox(height: 16.0),
      //       const SizedBox(height: 16.0),
      //       const Text('Your Identity'),
      //       const SizedBox(height: 16.0),
      //       Text('ID: ${widget.id}'),
      //       const SizedBox(height: 16.0),
      //       Text('Email: ${widget.email}'),
      //       const SizedBox(height: 16.0),
      //       Text('Name: ${widget.name}'),
      //       const SizedBox(height: 16.0),
      //       const Text('Token:'),
      //       Text(widget.token),
      //     ],
      //   ),
      // ),
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
        color: const Color(0xffdcf2f1),
        buttonBackgroundColor: const Color(0xffdcf2f1),
        backgroundColor: Colors.white,
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
