import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hasta_app/welcome_screen.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:http/http.dart' as http;

class RanapPage extends StatefulWidget {
  const RanapPage({super.key});

  @override
  State<RanapPage> createState() => _RanapPageState();
}

class _RanapPageState extends State<RanapPage> with TickerProviderStateMixin {
  List<Pasien> pasiens = [];

  String? _tokenSecure;

  final storage = const FlutterSecureStorage();
  late AnimationController controller;

  void _loadPreferences() async {
    final tokenSecure = await storage.read(key: 'tokenSecure') ?? "";
    setState(() {
      _tokenSecure = tokenSecure;
    });
    if (_tokenSecure != "") {
      _checkToken(_tokenSecure);
    } else {
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
        (route) => false,
      );
    }
  }

  void _checkToken(String? myToken) {
    if (myToken != "") {
      getUserData(myToken);
    } else {
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
        (route) => false,
      );
    }
  }

  Future<void> getUserData(String? token) async {
    setState(() {
      pasiens = [];
    });
    const apiUrl = '${const String.fromEnvironment('devUrl')}api/v1/ranap';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      inspect(response.statusCode);

      if (response.statusCode == 200) {
        final dataRanap = json.decode(response.body)['data'];

        setState(() {
          for (var pasien in dataRanap) {
            pasiens.add(Pasien(
              room: pasien['bgsl'],
              name: pasien['nama'],
              alamat:
                  "${pasien['alamat']}, ${pasien['kel']}, ${pasien['kec']}, ${pasien['kab']}, ${pasien['prov']}",
              pj: pasien['pj'],
            ));
          }
        });
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    pasiens = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff7fc7d9),
        title: const Text('Rawat Inap'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () => getUserData(_tokenSecure),
              icon: const Icon(Icons.replay_outlined),
            ),
          )
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text('Daftar Pasien Rawat Inap'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: renderSimpleSearchableList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget renderSimpleSearchableList() {
    return SearchableList<Pasien>(
      itemBuilder: (Pasien user) => ActorItem(actor: user),
      seperatorBuilder: (context, index) {
        return const Divider();
      },
      // builder: (list, index, item) {
      //   return ActorItem(actor: item);
      // },
      errorWidget: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            color: Colors.red,
          ),
          SizedBox(
            height: 20,
          ),
          Text('Kesalahan Ketika Mengambil Data Pasien')
        ],
      ),
      initialList: pasiens,
      filter: (p0) {
        pasiens
            .where(
              (element) => element.name.toLowerCase().contains(p0),
            )
            .toList();

        return pasiens
            .where(
              (element) =>
                  element.alamat.toLowerCase().contains(p0) ||
                  element.name.toLowerCase().contains(p0),
            )
            .toList();
      },
      emptyWidget: const EmptyView(),
      onRefresh: () async {},
      // onItemSelected: (Pasien item) {},
      inputDecoration: InputDecoration(
        labelText: "Cari Pasien",
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      closeKeyboardWhenScrolling: true,
    );
  }
}

class ActorItem extends StatelessWidget {
  final Pasien actor;

  const ActorItem({
    super.key,
    required this.actor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          Icon(
            Icons.bed_rounded,
            color: Colors.yellow[700],
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nama: ${actor.name}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Alamat: ${actor.alamat}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ruang: ${actor.room}',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Penanggung Jawab: ${actor.pj}',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          color: Colors.red,
        ),
        Text('Nama Pasien Tidak Ditemukan'),
      ],
    );
  }
}

class Pasien {
  String room;
  String name;
  String alamat;
  String pj;

  Pasien({
    required this.room,
    required this.name,
    required this.alamat,
    required this.pj,
  });
}
