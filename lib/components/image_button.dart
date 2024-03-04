import 'package:flutter/material.dart';

class ImageButton extends StatelessWidget {
  final String imagePath;
  final IconData icons;

  const ImageButton({
    Key? key,
    required this.imagePath,
    required this.icons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xffdcf2f1),
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(10),
      child: Icon(icons, size: 40,),
    );
  }
}
