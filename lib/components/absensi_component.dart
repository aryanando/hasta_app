import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Shift Scanner UI')),
      body: const AbsensiComponent(),
    ),
  ));
}

class AbsensiComponent extends StatefulWidget {
  const AbsensiComponent({super.key});

  @override
  State<AbsensiComponent> createState() => _AbsensiComponentState();
}

class _AbsensiComponentState extends State<AbsensiComponent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Fit content width
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Fit content height
                  children: const [
                    Text(
                      "Shift: Pagi",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Masuk: 07.00"),
                    Text("Pulang: 15.00"),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Fit content height
                children: const [
                  Icon(Icons.qr_code_scanner, size: 30),
                  SizedBox(height: 4),
                  Text("Scanner", textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
