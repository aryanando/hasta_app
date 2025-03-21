import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hasta_app/services/api_client.dart';
import 'package:intl/intl.dart';

class AbsensiComponent extends StatefulWidget {
  const AbsensiComponent({super.key});

  @override
  State<AbsensiComponent> createState() => _AbsensiComponentState();
}

class _AbsensiComponentState extends State<AbsensiComponent> {
  bool isLoading = true;
  Map<String, dynamic>? shiftData;

  @override
  void initState() {
    super.initState();
    fetchAbsensiData();
  }

  /// Fetch attendance data from the API
  Future<void> fetchAbsensiData() async {
    setState(() => isLoading = true);
    try {
      Response response = await ApiClient().get('/shift-user-for-absensi');

      if (response.data['success'] == true) {
        List<dynamic> shiftResponse = response.data['data'] ?? [];
        if (shiftResponse.isEmpty) {
          setState(() {
            shiftData = null;
          });
          return;
        }

        DateTime now = DateTime.now();
        DateTime yesterday = now.subtract(const Duration(days: 1));
        String yesterdayStr = DateFormat('yyyy-MM-dd').format(yesterday);

        // Extract shift data
        var selectedShift;
        if (shiftResponse.length == 2) {
          var yesterdayShift = shiftResponse[0];
          var todayShift = shiftResponse[1];

          // Check if yesterday's shift is a "Next Day Shift"
          bool isYesterdayNextDayShift =
              yesterdayShift['shifts']['next_day'] == 1;

          selectedShift = isYesterdayNextDayShift ? yesterdayShift : todayShift;
        } else {
          var singleShift = shiftResponse[0];

          // Determine if it's a next-day shift from yesterday
          bool isSingleShiftYesterday =
              singleShift['valid_date_start'].startsWith(yesterdayStr);
          bool isNextDayShift = singleShift['shifts']['next_day'] == 1;

          if (isSingleShiftYesterday && isNextDayShift) {
            DateTime now = DateTime.now();
            DateTime checkOutTime = DateTime.parse(
                "${singleShift['valid_date_end'].substring(0, 10)} ${singleShift['shifts']['check_out']}");

            bool isOverThreeHoursFromCheckOut =
                now.isAfter(checkOutTime.add(const Duration(hours: 5)));

            // ✅ If the user has checked out OR it's 3 hours past checkout, set to "Libur"
            if (singleShift['check_out'] != null ||
                isOverThreeHoursFromCheckOut) {
              selectedShift = null; // "Libur"
            } else {
              selectedShift = singleShift;
            }
          } else {
            selectedShift = singleShift;
          }
        }

        setState(() {
          shiftData = selectedShift;
        });
      } else {
        print("API error: ${response.data['message']}");
      }
    } catch (error) {
      print('Error fetching attendance data: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine background color based on shift status
    Color containerColor = shiftData == null
        ? Colors.grey[300]! // No shift
        : (shiftData!['check_in'] != null
            ? Colors.green[200]! // Checked in
            : Colors.red[200]!); // Not checked in yet
    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : shiftData == null
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 50,
                            color: Colors
                                .black54, // Darker color for better contrast
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Tidak ada jadwal shift.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .black87, // Darker text for higher contrast
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Shift: ${shiftData!['shifts']['shift_name']}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        "Masuk: ${shiftData!['shifts']['check_in']}"),
                                    Text(
                                        "Pulang: ${shiftData!['shifts']['check_out']}"),
                                  ],
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Text(
                                    shiftData!['check_in'] != null
                                        ? shiftData!['check_out'] != null
                                            ? "Sudah Pulang"
                                            : "Sudah Absen"
                                        : "Belum Absen",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: shiftData!['check_in'] != null
                                          ? shiftData!['check_out'] != null
                                              ? Colors.blue
                                              : Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          if (shiftData != null) {
                            DateTime now = DateTime.now();
                            DateTime checkInTime = DateTime.parse(
                                "${shiftData!['valid_date_start'].substring(0, 10)} ${shiftData!['shifts']['check_in']}");
                            DateTime checkOutTime = DateTime.parse(
                                "${shiftData!['valid_date_end'].substring(0, 10)} ${shiftData!['shifts']['check_out']}");

                            bool isCheckedIn = shiftData!['check_in'] != null;
                            bool isCheckedOut = shiftData!['check_out'] != null;

                            bool enableCheckIn = now.isAfter(checkInTime
                                    .subtract(const Duration(hours: 3))) &&
                                now.isBefore(checkInTime
                                    .add(const Duration(hours: 1))) &&
                                !isCheckedIn;

                            bool enableCheckOut = now.isAfter(checkOutTime
                                    .subtract(const Duration(hours: 1))) &&
                                now.isBefore(checkOutTime
                                    .add(const Duration(hours: 5))) &&
                                !isCheckedOut;

                            if (enableCheckIn) {
                              Navigator.pushNamed(
                                context,
                                '/absensi-cam',
                                arguments: {
                                  "shiftID": shiftData!['id'].toString()
                                },
                              ).then((result) {
                                if (result == true) {
                                  fetchAbsensiData(); // ✅ Only re-fetch on success
                                }
                              });
                            } else if (enableCheckOut) {
                              Navigator.pushNamed(
                                context,
                                '/absensi-pulang-cam',
                                arguments: {
                                  "shiftID": shiftData!['id'].toString()
                                },
                              ).then((result) {
                                if (result == true) {
                                  fetchAbsensiData(); // ✅ Only re-fetch on success
                                }
                              });
                            }
                          }
                        },
                        child: Builder(
                          builder: (context) {
                            DateTime now = DateTime.now();
                            DateTime? checkInTime, checkOutTime;
                            bool isCheckedIn = shiftData?['check_in'] != null;
                            bool isCheckedOut = shiftData?['check_out'] != null;

                            if (shiftData != null) {
                              checkInTime = DateTime.parse(
                                  "${shiftData!['valid_date_start'].substring(0, 10)} ${shiftData!['shifts']['check_in']}");
                              checkOutTime = DateTime.parse(
                                  "${shiftData!['valid_date_end'].substring(0, 10)} ${shiftData!['shifts']['check_out']}");
                            }

                            bool enableCheckIn = shiftData != null &&
                                now.isAfter(checkInTime!
                                    .subtract(const Duration(hours: 3))) &&
                                now.isBefore(checkInTime
                                    .add(const Duration(hours: 1))) &&
                                !isCheckedIn;

                            bool enableCheckOut = shiftData != null &&
                                now.isAfter(checkOutTime!
                                    .subtract(const Duration(hours: 1))) &&
                                now.isBefore(checkOutTime
                                    .add(const Duration(hours: 5))) &&
                                // isCheckedIn &&
                                !isCheckedOut;

                            print(
                                // shiftData != null &&
                                now.isAfter(checkOutTime!
                                        .subtract(const Duration(hours: 1))) &&
                                    now.isBefore(checkOutTime
                                        .add(const Duration(hours: 5))) &&
                                    // isCheckedIn &&
                                    !isCheckedOut);

                            return Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: (shiftData == null ||
                                        (!enableCheckIn && !enableCheckOut))
                                    ? Colors.grey[400] // Disabled state
                                    : Colors.blueAccent, // Active state
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.qr_code_scanner,
                                size: 70,
                                color: (shiftData == null ||
                                        (!enableCheckIn && !enableCheckOut))
                                    ? Colors.grey[600] // Disabled icon color
                                    : Colors.white, // Active icon color
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
