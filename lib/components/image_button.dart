import 'package:flutter/material.dart';

class ImageButton extends StatelessWidget {
  final String imagePath;
  final IconData icons;
  final String pageRoute;

  const ImageButton(
      {super.key,
      required this.imagePath,
      required this.icons,
      required this.pageRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xffdcf2f1),
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(10),
      child: IconButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              pageRoute,
            );
          },
          icon: Icon(
            icons,
            size: 40,
          )),
    );
  }
}
