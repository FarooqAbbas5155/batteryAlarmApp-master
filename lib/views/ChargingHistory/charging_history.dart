import 'package:battery_alarm/views/ChargingHistory/charging_history_provider.dart';
import 'package:battery_alarm/views/controller/home_controller.dart';
import 'package:battery_alarm/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BatteryHistoryScreen extends StatefulWidget {
  const BatteryHistoryScreen({
    super.key,
  });

  @override
  State<BatteryHistoryScreen> createState() => _BatteryHistoryScreenState();
}

class _BatteryHistoryScreenState extends State<BatteryHistoryScreen> {
  @override
  void initState() {
    var provider = Provider.of<ChargingHistoryProvider>(context, listen: false);
    provider.loadHistory();
    super.initState();
  }

  var controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ChargingHistoryProvider>(
        builder: (context, pro, child) {
          final history = pro.history;
          print('dataaa: ${history.length}');
          return history.isEmpty
              ? Center(
            child: KText(
              text: "Calculating..",
              fontSize: 16.sp,
              color: Colors.white,
            ),
          )
              : Obx(() {
            return controller.charging.value == true? ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: Container(
                    height: 188.h,
                    width: 312.w,
                    padding: EdgeInsets.symmetric(
                        vertical: 16.h, horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: foreGround,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        TextRow(
                          text1: entry.chargeTime != null
                              ? formatChargeTime(entry.chargeTime!)
                              : "",
                          text1Color: linesColor,
                          text2: "+${entry.totalPercentage}%",
                          text2Color: textColor,
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          height: 5.w,
                          width: 312.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: const [
                                Color(0xffF74A5E), // First color
                                Color(0xffF74A5E), // First color
                                Color(0xff727477), // Second color
                                Color(0xff727477), // Second color
                              ],
                              stops: [
                                0.0,
                                // First color start
                                entry.percentage /
                                    100,
                                // First color end (dynamic based on _totalPercentage)
                                entry.percentage /
                                    100,
                                // Second color start (dynamic based on _totalPercentage)
                                1.0,
                                // Second color end
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        TextRow(
                          text1: "${entry.plugInPercentage}%",
                          fontSize1: 16.sp,
                          text1Color: Colors.white,
                          text2: "${entry.percentage}%",
                          text2Color: Colors.white,
                        ),
                        SizedBox(height: 18.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconTextRow(
                              text: "Plug in",
                              icon: "assets/icons/Plug_in.png",
                              iconsColor: Colors.green,
                              iconSize: 18.sp,
                            ),
                            const IconTextRow(
                              text: "Plug out",
                              icon: "assets/icons/plug_out.png",
                              iconsColor: Colors.red,
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        TextRow(
                          text1: entry.plugInTimestamp != null
                              ? DateFormat("HH:mm:ss | dd MMM yyyy")
                              .format(entry.plugInTimestamp!)
                              : "10%",
                          fontSize1: 12.sp,
                          text2: entry.plugOutTimestamp != null
                              ? DateFormat("HH:mm:ss | dd MMM yyyy")
                              .format(entry.plugOutTimestamp!)
                              : "100%",
                          fontSize2: 12.sp,
                        )
                      ],
                    ),
                  ),
                );
              },
            ):Center(child: Text("Update Charging setting",style: TextStyle(color: Colors.white),),);
          });
        },
      ),
    );
  }
}

String formatChargeTime(Duration chargeTime) {
  if (chargeTime.inSeconds < 60) {
    // Display in seconds if it's less than a minute
    return 'Charged for ${chargeTime.inSeconds} seconds';
  } else {
    // Display in minutes if it's one minute or more
    return 'Charged for ${chargeTime.inMinutes} minutes';
  }
}

class TextRow extends StatelessWidget {
  const TextRow({
    super.key,
    required this.text1,
    required this.text2,
    this.text1Color,
    this.text2Color,
    this.fontSize1,
    this.fontSize2,
  });

  final String text1;
  final String text2;
  final Color? text1Color;
  final Color? text2Color;
  final double? fontSize1;
  final double? fontSize2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        KText(
          text: text1,
          color: text1Color ?? const Color(0xff6D6D6D),
          fontSize: fontSize1 ?? 14.sp,
        ),
        KText(
          text: text2,
          fontSize: fontSize2 ?? 16.sp,
          color: text2Color ?? const Color(0xff6D6D6D),
        )
      ],
    );
  }
}

class IconTextRow extends StatelessWidget {
  const IconTextRow({
    super.key,
    required this.text,
    required this.icon,
    required this.iconsColor,
    this.iconSize,
  });

  final String text;
  final String icon;
  final Color iconsColor;
  final double? iconSize;


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          icon,
          height: iconSize ?? 24.h,
          width: iconSize ?? 24.w,
          color: iconsColor,
        ),
        SizedBox(width: 4.w,),
        KText(
          text: text,
          fontSize: 16.sp,
          color: const Color(0xFFFFFFFF),
        )
      ],
    );
  }
}

class KText extends StatelessWidget {
  const KText(
      {super.key, this.fontSize, this.fontWeight, this.color, this.text});

  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      style: GoogleFonts.inter(
        fontSize: fontSize ?? 16,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color ?? Colors.white,
      ),
    );
  }
}


// class BatteryHistoryChart extends StatelessWidget {
//   final List<BatteryInfo> batteryHistory;

//   const BatteryHistoryChart({super.key, required this.batteryHistory});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 200,
//       child: LineChart(
//         LineChartData(
//           backgroundColor: Colors.black,
//           lineTouchData: const LineTouchData(enabled: true),
//           gridData: const FlGridData(show: false),
//           titlesData: const FlTitlesData(show: true),
//           borderData: FlBorderData(
//             show: true,
//             border: Border.all(color: const Color(0xff37434d), width: 1),
//           ),
//           minX: 0,
//           maxX: batteryHistory.length.toDouble() - 1,
//           minY: 0,
//           maxY: 100,
//           lineBarsData: [
//             LineChartBarData(
//               spots: List.generate(
//                 batteryHistory.length,
//                 (index) => FlSpot(
//                     index.toDouble(), batteryHistory[index].level.toDouble()),
//               ),
//               isCurved: true,
//               dotData: const FlDotData(show: false),
//               belowBarData: BarAreaData(show: true),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../widgets/colors.dart';
// import 'package:battery_plus/battery_plus.dart';
// import '../database_helper.dart';

// class BatteryHistory extends StatefulWidget {
//   const BatteryHistory({Key? key}) : super(key: key);

//   @override
//   _BatteryHistoryState createState() => _BatteryHistoryState();
// }

// class _BatteryHistoryState extends State<BatteryHistory> {
//   final DatabaseHelper databaseHelper = DatabaseHelper();
//   bool isCharging = false;
//   ChargingRecord? lastChargingRecord;
//   Battery battery = Battery();

//   @override
//   void initState() {
//     super.initState();
//     databaseHelper.initializeDatabase();
//     loadLastChargingRecord();

//     battery.onBatteryStateChanged.listen((BatteryState state) {
//       setState(() {
//         isCharging = state == BatteryState.charging;
//       });

//       if (isCharging) {
//         // Fetch and display charging history when charging starts
//         fetchChargingHistory();

//         DateTime startTime = DateTime.now(); // Define the start time
//         DateTime endTime = DateTime.now(); // Define the end time
//         DateTime startChargingTime =
//             DateTime.now(); // Define the start charging time
//         DateTime fullChargeTime = DateTime.now(); // Define the full charge time
//         bool isUSBCharger = true; // Define whether it's a USB charger
//         bool isWirelessCharger =
//             false; // Define whether it's a wireless charger
//         int chargeAdded = 1000; // Define the charge added

//         // Now you can use these variables when calling your functions
//         final chargingDuration = calculateChargingDuration(startTime, endTime);
//         final fullChargeDuration =
//             calculateFullChargeDuration(startChargingTime, fullChargeTime);
//         final overchargedDuration =
//             calculateOverchargedDuration(chargingDuration, fullChargeDuration);
//         final chargerType =
//             detectChargerType(isCharging, isUSBCharger, isWirelessCharger);
//         final chargeQuantity = calculateChargeQuantity(chargeAdded);

//         // Save the current charging record
//         final chargingRecord = ChargingRecord(
//           id: 1, // Let the database assign an ID
//           chargingDuration: chargingDuration,
//           fullChargeDuration: fullChargeDuration,
//           overchargedDuration: overchargedDuration,
//           chargerType: chargerType,
//           chargeQuantity: chargeQuantity,
//         );
//         databaseHelper.saveChargingRecord(chargingRecord);
//       }
//     });
//   }

//   int calculateChargingDuration(DateTime startTime, DateTime endTime) {
//     // Calculate and return the charging duration in seconds.
//     Duration duration = endTime.difference(startTime);
//     return duration.inSeconds;
//   }

//   int calculateFullChargeDuration(
//       DateTime startChargingTime, DateTime fullChargeTime) {
//     // Calculate and return the full charge duration in seconds.
//     Duration duration = fullChargeTime.difference(startChargingTime);
//     return duration.inSeconds;
//   }

//   int calculateOverchargedDuration(
//       int chargingDuration, int fullChargeDuration) {
//     // Calculate and return the overcharged duration in seconds.
//     int overchargedDuration = chargingDuration - fullChargeDuration;
//     return overchargedDuration > 0 ? overchargedDuration : 0;
//   }

//   String detectChargerType(
//       bool isCharging, bool isUSBCharger, bool isWirelessCharger) {
//     // Detect and return the charger type (e.g., 'USB', 'Wireless', 'Unknown').
//     if (isCharging) {
//       if (isUSBCharger) {
//         return 'USB Charger';
//       } else if (isWirelessCharger) {
//         return 'Wireless Charger';
//       }
//     }
//     return 'Unknown';
//   }

//   int calculateChargeQuantity(int chargeAdded) {
//     // Calculate and return the charge quantity in your preferred unit.
//     return chargeAdded;
//   }

//   Future<void> loadLastChargingRecord() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final int? lastChargeId = prefs.getInt('lastChargeId');
//     print('Last Charge ID: $lastChargeId'); // Add this line
//     if (lastChargeId != null) {
//       final record = await databaseHelper.getChargingRecord(lastChargeId);
//       setState(() {
//         lastChargingRecord = record;
//       });
//     }
//   }

//   Future<void> fetchChargingHistory() async {
//     final records = await databaseHelper.fetchAllChargingRecords();
//     if (records.isNotEmpty) {
//       final lastRecord = records.last;

//       // Save the last charge record ID to shared preferences
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.setInt('lastChargeId', lastRecord.id);

//       setState(() {
//         lastChargingRecord = lastRecord;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('last record : $lastChargingRecord');
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               isCharging ? 'Charging' : 'Not Charging',
//               style: TextStyle(fontSize: 24, color: textColor),
//             ),
//             if (lastChargingRecord != null)
//               Column(
//                 children: [
//                   Text(
//                     'Last Charging Record:',
//                     style: TextStyle(color: textColor),
//                   ),
//                   Text(
//                     'Charging Duration: ${lastChargingRecord!.chargingDuration} seconds',
//                     style: TextStyle(color: textColor),
//                   ),
//                   Text(
//                     'Full Charge Duration: ${lastChargingRecord!.fullChargeDuration} seconds',
//                     style: TextStyle(color: textColor),
//                   ),
//                   Text(
//                     'Overcharged Duration: ${lastChargingRecord!.overchargedDuration} seconds',
//                     style: TextStyle(color: textColor),
//                   ),
//                   Text(
//                     'Charger Type: ${lastChargingRecord!.chargerType}',
//                     style: TextStyle(color: textColor),
//                   ),
//                   Text(
//                     'Charge Quantity: ${lastChargingRecord!.chargeQuantity}',
//                     style: TextStyle(color: textColor),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class BatteryChargingHistory extends StatelessWidget {
//   const BatteryChargingHistory({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final topMargin = screenHeight * 0.02; // Margin from the top
//     final leftMargin = screenWidth * 0.02; // Margin from the top
//     final rightMargin = screenWidth * 0.02; // Margin from the right
//     final upMargin = screenHeight * 0.01;
//     return Scaffold(
//       body: Column(
//         children: [
//           SizedBox(width: topMargin),
//           SizedBox(width: topMargin),
//           Row(
//             children: [
//               SizedBox(width: leftMargin),
//               Expanded(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: Card(
//                     color: foreGround,
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Current Capacity',
//                               style: TextStyle(
//                                 color: linesColor,
//                               )),
//                           SizedBox(height: upMargin),
//                           Text('2800 mAh',
//                               style: TextStyle(
//                                 color: textColor,
//                               )),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: Card(
//                     color: foreGround,
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Current Capacity',
//                               style: TextStyle(
//                                 color: linesColor,
//                               )),
//                           SizedBox(height: upMargin),
//                           Text('2800 mAh',
//                               style: TextStyle(
//                                 color: textColor,
//                               )),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: Card(
//                     color: foreGround,
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Current Capacity',
//                               style: TextStyle(
//                                 color: linesColor,
//                               )),
//                           SizedBox(height: upMargin),
//                           Text('2800 mAh',
//                               style: TextStyle(
//                                 color: textColor,
//                               )),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: rightMargin),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


