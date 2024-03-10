import 'package:flutter/material.dart';

class AbsensiNotifCard extends StatelessWidget {
  final int cardColor;
  final String cardTittle;
  final String cardMessage;
  const AbsensiNotifCard({super.key, required this.cardColor, required this.cardTittle, required this.cardMessage,});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(cardColor),
      child: ListTile(
        leading: const Icon(Icons.close),
        title: Text(cardTittle),
        subtitle: Text(cardMessage),
        trailing: const Icon(Icons.more_vert),
      ),
    );
  }
}

// Color.fromARGB(255, 204, 255, 208),