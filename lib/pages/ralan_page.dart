import 'package:flutter/material.dart';

class RalanPage extends StatefulWidget {
  const RalanPage({super.key});

  @override
  State<RalanPage> createState() => _RalanPageState();
}

class _RalanPageState extends State<RalanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Ralan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
