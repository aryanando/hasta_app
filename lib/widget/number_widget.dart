import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class NumbersWidget extends StatefulWidget {
  @override
  State<NumbersWidget> createState() => _NumbersWidgetState();
}

class _NumbersWidgetState extends State<NumbersWidget> {
  final storage = const FlutterSecureStorage();
  String _tokenSecure = '';
  String _currentRating = '';
  String _currentLateCount = '';
  String _countShifts = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final tokenSecure = await storage.read(key: 'tokenSecure') ?? "";
    setState(() {
      _tokenSecure = tokenSecure;
    });

    getUserStatistic(_tokenSecure);
  }

  Future<void> getUserStatistic(String? myToken) async {
    String apiUrl =
        '${const String.fromEnvironment('devUrl')}api/v1/user-statistic';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $myToken',
      });

      if (response.statusCode == 200) {
        final dataPengumuman = json.decode(response.body)['data'];
        print(dataPengumuman['currentMonthRating']);
        setState(() {
          _currentRating = dataPengumuman['currentMonthRating'].toString();
          _currentLateCount = dataPengumuman['currentMonthLate'].toString();
          _countShifts = dataPengumuman['countShifts'].toString();
        });
        print(_currentRating);
      } else {
        debugPrint(apiUrl);
        print(response.statusCode);
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Color(0xffdddddd), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildButton(context, _currentRating, 'Rating'),
            buildDivider(),
            buildButton(context, _currentLateCount, 'Terlambat'),
            buildDivider(),
            buildButton(context, _countShifts, 'Masuk'),
          ],
        ),
      );

  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.black),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      );
}
