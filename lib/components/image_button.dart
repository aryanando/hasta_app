import 'package:flutter/material.dart';

class ImageButton extends StatelessWidget {
  final String imagePath;

  const ImageButton({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xffdcf2f1),
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(10),
      child: const Icon(Icons.fact_check_rounded, size: 32,),
    );
  }
}
