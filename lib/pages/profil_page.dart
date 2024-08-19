import 'package:flutter/material.dart';

class ProfilPage extends StatefulWidget {
  final String name;
  final String email;

  const ProfilPage({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  get onClicked => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff7fc7d9),
        title: const Text('Profil'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          photoWidget(),
          const SizedBox(
            height: 24,
          ),
          nameWidget(widget.name, widget.email),
        ],
      ),
    );
  }

  Widget nameWidget(String name, String email) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        Text(
          email,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget photoWidget() {
    const image = NetworkImage(
        'https://www.gravatar.com/avatar/2c7d99fe281ecd3bcd65ab915bac6dd5?s=250');
    return Center(
      child: Stack(
        children: [
          ClipOval(
            child: Container(
              padding: const EdgeInsets.all(2),
              color: Colors.white,
              child: ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: Ink.image(
                    image: image,
                    fit: BoxFit.cover,
                    width: 128,
                    height: 128,
                    child: InkWell(
                      onTap: onClicked,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: ClipOval(
              child: Container(
                padding: const EdgeInsets.all(2),
                color: Colors.white,
                child: ClipOval(
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    color: Colors.black,
                    child: const Icon(
                      color: Colors.white,
                      Icons.edit,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
