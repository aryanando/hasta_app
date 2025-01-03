import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:quiver/time.dart';

// void main() {
//   runApp(AbsensiCalendarPage());
// }

class AbsensiCalendarPage extends StatefulWidget {
  const AbsensiCalendarPage({super.key});

  @override
  State<AbsensiCalendarPage> createState() => _AbsensiCalendarPageState();
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class _AbsensiCalendarPageState extends State<AbsensiCalendarPage> {
  final PageController _pageController =
      PageController(initialPage: DateTime.now().month - 1);

  DateTime _currentMonth = DateTime.now();
  bool selectedcurrentyear = false;
  final moonLanding = DateTime.now();
  var dateTimes = DateTime.now();
  String? _tokenSecure;
  final storage = const FlutterSecureStorage();
  Map _dataAbsensiBulanIni = {};

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
    getAbsensiData(_tokenSecure);
  }

  Future<void> getAbsensiData(String? myToken) async {
    String apiUrl =
        '${const String.fromEnvironment('devUrl')}api/v1/shift-user/${dateTimes.month}';
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $myToken',
      });

      if (response.statusCode == 200) {
        final dataAbsensiBulanIni = json.decode(response.body)['data'];
        setState(() {
          _dataAbsensiBulanIni = (dataAbsensiBulanIni['user-shift']);
          // print(_dataAbsensiBulanIni['1']);
        });
      } else {
        // debugPrint(apiUrl);
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[100],
          title: const Text('Absensi Calendar'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Container(
                height: 550,
                color: Colors.green[100],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildWeeks(),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentMonth =
                                  DateTime(_currentMonth.year, index + 1, 1);
                            });
                          },
                          itemCount: 12 *
                              1, // Show 10 years, adjust this count as needed
                          itemBuilder: (context, pageIndex) {
                            DateTime month = DateTime(
                                _currentMonth.year, (pageIndex % 12) + 1, 1);
                            return buildCalendar(month);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            buildHistory(_dataAbsensiBulanIni),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Checks if the current month is the last month of the year (December)
    // bool isLastMonthOfYear = _currentMonth.month == 12;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // IconButton(
          //   icon: Icon(Icons.arrow_back),
          //   onPressed: () {
          //     // Moves to the previous page if the current page index is greater than 0
          //     if (_pageController.page! > 0) {
          //       _pageController.previousPage(
          //         duration: Duration(milliseconds: 300),
          //         curve: Curves.easeInOut,
          //       );
          //     }
          //   },
          // ),
          // Displays the name of the current month
          Text(
            '${DateFormat('MMMM').format(_currentMonth)} 2024',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // DropdownButton<int>(
          //   // Dropdown for selecting a year
          //   value: _currentMonth.year,
          //   onChanged: (int? year) {
          //     if (year != null) {
          //       setState(() {
          //         // Sets the current month to January of the selected year
          //         _currentMonth = DateTime(year, 1, 1);

          //         // Calculates the month index based on the selected year and sets the page
          //         int yearDiff = DateTime.now().year - year;
          //         int monthIndex = 12 * yearDiff + _currentMonth.month - 1;
          //         _pageController.jumpToPage(monthIndex);
          //       });
          //     }
          //   },
          //   items: [
          //     // Generates DropdownMenuItems for a range of years from current year to 10 years ahead
          //     for (int year = DateTime.now().year;
          //         year <= DateTime.now().year + 10;
          //         year++)
          //       DropdownMenuItem<int>(
          //         value: year,
          //         child: Text(year.toString()),
          //       ),
          //   ],
          // ),
          // IconButton(
          //   icon: Icon(Icons.arrow_forward),
          //   onPressed: () {
          //     // Moves to the next page if it's not the last month of the year
          //     if (!isLastMonthOfYear) {
          //       setState(() {
          //         _pageController.nextPage(
          //           duration: Duration(milliseconds: 300),
          //           curve: Curves.easeInOut,
          //         );
          //       });
          //     }
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildWeeks() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildWeekDay('Sen'),
          _buildWeekDay('Sel'),
          _buildWeekDay('Rab'),
          _buildWeekDay('Kam'),
          _buildWeekDay('Jum'),
          _buildWeekDay('Sab'),
          _buildWeekDay('Min'),
        ],
      ),
    );
  }

  Widget _buildWeekDay(String day) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Text(
        day,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildCalendar(DateTime month) {
    // Calculating various details for the month's display
    int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    int weekdayOfFirstDay = firstDayOfMonth.weekday;

    DateTime lastDayOfPreviousMonth =
        firstDayOfMonth.subtract(const Duration(days: 1));
    int daysInPreviousMonth = lastDayOfPreviousMonth.day;

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.8,
      ),
      // Calculating the total number of cells required in the grid
      itemCount: daysInMonth + weekdayOfFirstDay - 1,
      itemBuilder: (context, index) {
        if (index < weekdayOfFirstDay - 1) {
          int previousMonthDay =
              daysInPreviousMonth - (weekdayOfFirstDay - index) + 2;
          return Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide.none,
                left: BorderSide(width: 1.0, color: Colors.grey),
                right: BorderSide(width: 1.0, color: Colors.grey),
                bottom: BorderSide(width: 1.0, color: Colors.grey),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              previousMonthDay.toString(),
              style: const TextStyle(color: Colors.grey),
            ),
          );
        } else {
          // Displaying the current month's days
          DateTime date =
              DateTime(month.year, month.month, index - weekdayOfFirstDay + 2);
          String text = date.day.toString();

          // print(date.month.toString());
          int indexJadwal = index - (weekdayOfFirstDay - 2);
          // print(index - (weekdayOfFirstDay - 2));
          String dataShifts = 'off';
          String dataShiftsColor = 'DDDDDD';
          if (_dataAbsensiBulanIni[indexJadwal.toString()] != null) {
            dataShifts =
                (_dataAbsensiBulanIni[indexJadwal.toString()]['shift_name']);
            dataShiftsColor =
                (_dataAbsensiBulanIni[indexJadwal.toString()]['shift_color']);
          }
          return InkWell(
            onTap: () {
              // Handle tap on a date cell
              // This is where you can add functionality when a date is tapped
              _dialogBuilder(
                  context, _dataAbsensiBulanIni[indexJadwal.toString()]);
            },
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide.none,
                  left: BorderSide(width: 1.0, color: Colors.grey),
                  right: BorderSide(width: 1.0, color: Colors.grey),
                  bottom: BorderSide(width: 1.0, color: Colors.grey),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                      child: Container(
                        // Add the line below
                        height: 20,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          // border: Border.all(color: Colors.green, width: 2.0),
                        ),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              height: 30,
                              width: 60,
                              color: HexColor(dataShiftsColor),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                // child: Text(
                                //   dataShifts,
                                //   style: TextStyle(fontSize: 10),
                                // ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 3, right: 3, top: 3),
                              child: Text(
                                dataShifts,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildHistory(Map<dynamic, dynamic> dataAbsensi) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text(
                'Histori Absensi Anda Terbaru:',
                style: TextStyle(fontSize: 22),
              ),
              for (int i = 1;
                  i <= daysInMonth(DateTime.now().year, DateTime.now().month);
                  i++)
                if (dataAbsensi[i.toString()] != null &&
                    (i >= DateTime.now().day - 4) &&
                    (i <= DateTime.now().day))
                  buildHistoryItem(dataAbsensi[i.toString()]),
              const SizedBox(
                height: 8,
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/histori-kehadiran',
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text('Lihat Semua'),
                iconAlignment: IconAlignment.start,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHistoryItem(Map<dynamic, dynamic> dataAbsensi) {
    String textKeterangan = 'Please Wait';

    Icon iconKehadiran = const Icon(
      Icons.check,
      color: Colors.grey,
    );

    if (dataAbsensi['check_in'] != null) {
      if (DateTime.parse(
                  "${DateFormat('yyyy-MM-dd').format(DateTime.parse(dataAbsensi['valid_date_start']))} ${dataAbsensi['shift_checkin']}")
              .compareTo(DateTime.parse(dataAbsensi['check_in'])) >
          0) {
        textKeterangan = 'Tepat Waktu';
        setState(() {
          iconKehadiran = const Icon(
            Icons.check,
            color: Colors.green,
          );
        });
      } else {
        Duration difference = DateTime.parse(dataAbsensi['check_in'])
            .difference(DateTime.parse(
                "${DateFormat('yyyy-MM-dd').format(DateTime.parse(dataAbsensi['valid_date_start']))} ${dataAbsensi['shift_checkin']}"));
        textKeterangan =
            'Anda Terlambat ${difference.inMinutes > 0 ? "${difference.inMinutes} Menit" : "${difference.inSeconds} Detik"}';
        setState(() {
          iconKehadiran = const Icon(
            Icons.assignment_late_outlined,
            color: Colors.orange,
          );
        });
      }
    } else if (DateTime.parse(
                "${DateFormat('yyyy-MM-dd').format(DateTime.parse(dataAbsensi['valid_date_start']))} ${dataAbsensi['shift_checkin']}")
            .compareTo(DateTime.now()) <
        0) {
      textKeterangan = 'Anda tidak absen';
      setState(() {
        iconKehadiran = Icon(
          Icons.assignment_late_outlined,
          color: Colors.red[300],
        );
      });
    } else {
      textKeterangan = '-';
      setState(() {
        iconKehadiran = const Icon(
          Icons.calendar_month,
          color: Colors.grey,
        );
      });
    }

    return Card(
      child: ListTile(
        leading: iconKehadiran,
        title: Text(DateFormat('dd MMMM yyyy')
            .format(DateTime.parse(dataAbsensi['valid_date_start']))),
        subtitle: Text(textKeterangan),
        trailing: IconButton(
          icon: const Icon(Icons.remove_red_eye_rounded),
          onPressed: () {
            _dialogBuilder(context, dataAbsensi);
          },
        ),
      ),
    );
  }

  Future<void> _dialogBuilder(
      BuildContext context, Map<dynamic, dynamic> dataAbsensi) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Data Kehadiran'),
          content: Text(
            'Tanggal : ${DateFormat('yyyy-MM-dd').format(DateTime.parse(dataAbsensi['valid_date_start']))}\n'
            'Shift : ${dataAbsensi['shift_name']} ${dataAbsensi['shift_checkin']} - ${dataAbsensi['shift_checkout']}\n'
            'Datang : ${dataAbsensi['check_in'] != null ? DateFormat('HH:mm:ss').format(DateTime.parse(dataAbsensi['check_in'])) : '-'}\n'
            'Pulang : ${dataAbsensi['check_out'] != null ? DateFormat('HH:mm:ss').format(DateTime.parse(dataAbsensi['check_out'])) : '-'}',
          ),
          // actions: <Widget>[
          //   TextButton(
          //     style: TextButton.styleFrom(
          //       textStyle: Theme.of(context).textTheme.labelLarge,
          //     ),
          //     child: const Text('Disable'),
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //   ),
          //   TextButton(
          //     style: TextButton.styleFrom(
          //       textStyle: Theme.of(context).textTheme.labelLarge,
          //     ),
          //     child: const Text('Enable'),
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //   ),
          // ],
        );
      },
    );
  }
}
