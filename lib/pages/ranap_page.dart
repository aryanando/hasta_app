import 'package:flutter/material.dart';
import 'package:hasta_app/home_page.dart';

class RanapPage extends StatefulWidget {
  const RanapPage({super.key});

  @override
  State<RanapPage> createState() => _RanapPageState();
}

class _RanapPageState extends State<RanapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Ranap'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const HomePage(
                      id: 1,
                      name: "haha",
                      email: "hoho",
                    )),
          ),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            IconButton(
                onPressed: () => Navigator.pushNamed(context, '/ralan'),
                icon: Icon(Icons.health_and_safety_rounded))
          ],
        ),
      ),
    );
  }
}
