import 'dart:async';

import 'package:battery_alarm/views/battery_info.dart';
import 'package:battery_alarm/views/controller/home_controller.dart';
import 'package:battery_alarm/views/device_info.dart';
import 'package:battery_alarm/views/settings.dart';
import 'package:battery_alarm/widgets/colors.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'ChargingHistory/charging_history.dart';
import 'ChargingHistory/charging_history_provider.dart';
import 'battery_alarm.dart';
import 'helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String appBarTitle = 'Battery Alarm';
  final Battery battery = Battery();
  BatteryState lastState = BatteryState.unknown;
  int lastPercentage = 0;
  DateTime? plugInTime;
  int plugInPercentage = 0;
  int totalPercentage = 0;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  DateTime chargeStartTime = DateTime.now();
  bool newvalue = false;
  @override
  var controller = Get.put(HomeController());

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      battery.onBatteryStateChanged.listen((BatteryState state) async {
        final status =
        state == BatteryState.charging ? 'Charging' : 'Discharging';
        final timestamp = DateTime.now();
        final batteryLevel = await battery.batteryLevel;

        if (state != lastState) {
          lastState = state;

          if (state == BatteryState.charging) {
            plugInTime = timestamp;
            plugInPercentage = batteryLevel;
            chargeStartTime = timestamp;
            setState(() {});
          } else if (state == BatteryState.discharging && plugInTime != null) {
            final plugOutTime = timestamp;
            final plugOutPercentage = batteryLevel;
            final chargeTime = plugOutTime.difference(chargeStartTime);
            setState(() {});

            //asign data to BatteryHistory Class to add in data base

            final historyEntry = BatteryHistory(
              chargeTime: chargeTime,
              status: status,
              percentage: plugOutPercentage,
              timestamp: timestamp,
              plugInTimestamp: plugInTime,
              plugOutTimestamp: plugOutTime,
              plugInPercentage: plugInPercentage,
              totalPercentage: totalPercentage,
            );

            // charging_history_provider.dart  function to add entry in data base
            final historyProvider =
            Provider.of<ChargingHistoryProvider>(context, listen: false);
            await historyProvider.addHistoryEntry(historyEntry);

            plugInTime = null;
          }
        } else if (state == BatteryState.charging) {
          totalPercentage += batteryLevel - lastPercentage;
        }

        lastPercentage = batteryLevel;
      });
    });
    _initBatteryChargingState();
  }

  @override
  void dispose() {
    _batteryStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initBatteryChargingState() async {
    _batteryStateSubscription =
        battery.onBatteryStateChanged.listen((BatteryState state) {
          if (state == BatteryState.charging) {
            setState(() {
              isCharging = true;
            });
          } else {
            setState(() {
              isCharging = false;
            });
          }
        });
  }

  BottomNavigationBarItem buildNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
      activeIcon: Stack(
        children: [
          Icon(icon),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2.0,
              color: themeColor,
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        appBarTitle = 'Battery Alarm';
      } else if (index == 1) {
        appBarTitle = 'Charging History';
      } else if (index == 2) {
        appBarTitle = 'Battery Information';
      } else if (index == 3) {
        appBarTitle = 'Battery Usage';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backGround,
        automaticallyImplyLeading: false,
        title: Align(alignment: Alignment.topLeft, child: Text(appBarTitle)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Settings()));
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _buildBody(_selectedIndex),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        screenWidth: screenWidth,
      ),
    );
  }
}


Widget _buildBody(int selectedIndex) {
  switch (selectedIndex) {
    case 0:
      return const HomeTabContent();
    case 1:
    // Implement your "History" tab content here
      return const BatteryHistoryScreen();
    case 2:
    // Show the "Info" tab content
      return const BatteryInfo();
/*    case 3:
    // Show the "Info" tab content
      return const BatteryUsage();*/
    default:
      return Container(); // Handle other cases as needed
  }
}


class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final double screenWidth;

  const CustomBottomNavigationBar({super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () => onItemTapped(0),
          child: SvgIconWithLabel(
            iconAsset: 'assets/icons/clarity_home-solid.svg',
            label: 'Home',
            isSelected: selectedIndex == 0,
            screenWidth: screenWidth,
          ),
        ),
        GestureDetector(
          onTap: () => onItemTapped(1),
          child: SvgIconWithLabel(
            iconAsset: 'assets/icons/ic_baseline-history.svg',
            label: 'History',
            isSelected: selectedIndex == 1,
            screenWidth: screenWidth,
          ),
        ),
        GestureDetector(
          onTap: () => onItemTapped(2),
          child: SvgIconWithLabel(
            iconAsset: 'assets/icons/ri_battery-2-charge-fill.svg',
            label: 'Info',
            isSelected: selectedIndex == 2,
            screenWidth: screenWidth,
          ),
        ),
        GestureDetector(
          onTap: () => onItemTapped(3),
          child: SvgIconWithLabel(
            iconAsset: 'assets/icons/usage.svg',
            label: 'Usage',
            isSelected: selectedIndex == 3,
            screenWidth: screenWidth,
          ),
        ),
      ],
    );
  }
}

class SvgIconWithLabel extends StatelessWidget {
  final String iconAsset;
  final String label;
  final bool isSelected;
  final double screenWidth;

  const SvgIconWithLabel({
    super.key,
    required this.iconAsset,
    required this.label,
    this.isSelected = false,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          iconAsset,
          color: isSelected ? themeColor : Colors.grey,
        ),
        SizedBox(
            height: screenWidth *
                0.003), // Adjust the spacing between icon and label
        Text(
          label,
          style: TextStyle(
            color: isSelected ? themeColor : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        SizedBox(height: screenWidth * 0.006),
        if (isSelected)
          Container(
            width: screenWidth * 0.13, // Adjust the width of the underline
            height: screenWidth * 0.002,
            color: themeColor, // Color of the underline
          ),
      ],
    );
  }
}

class HomeTabContent extends StatefulWidget {
  const HomeTabContent({super.key});

  @override
  State<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  var controller = Get.put(HomeController());

  bool newValue = false;
  final battery = Battery();
  int batteryTemperature = 0;
  String batteryHealth = "";
  int batteryVoltage = 0;
  int batteryCapacity = 0;
  final BatteryInfoPlugin _batteryInfo = BatteryInfoPlugin();

  // StreamSubscription<BatteryState>? _batteryStateSubscription;
  int batteryLevel = 0;

  Duration timeRemaining = const Duration(hours: 0, minutes: 0);
  bool isPopupShown = false;

  @override
  void initState() {
    super.initState();
    // Schedule the execution of _showPopup after initState is completed
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      // _showPopup();
      if (controller.popup == false) {
        _showPopup();
        setState(() {
          controller.popup =
          true; // Set the flag to true after showing the popup

        });
      }
    });
    _initBatteryInfo();
  }

  // @override
  // void dispose() {
  //   _batteryStateSubscription?.cancel();
  //   super.dispose();
  // }

  // Future<void> _initBatteryChargingState() async {
  //   _batteryStateSubscription =
  //       battery.onBatteryStateChanged.listen((BatteryState state) {
  //     if (state == BatteryState.charging) {
  //       setState(() {
  //         isCharging = true;
  //
  //       });
  //     } else {
  //       setState(() {
  //         isCharging = false;
  //
  //       });
  //     }
  //   });
  // }

  void fetchBatteryInfo() async {
    final batteryStatus = await battery.batteryLevel;

    setState(() {
      batteryLevel = batteryStatus;
    });
  }

  Future<void> _initBatteryInfo() async {
    final info = await _batteryInfo.androidBatteryInfo;
    setState(() {
      batteryTemperature = info?.temperature ?? 0;
      batteryHealth = info?.health ?? "Unknown";
      batteryVoltage = info?.voltage ?? 0;
      batteryCapacity = info?.batteryCapacity ?? 0;
    });
  }


  @override
  Widget build(BuildContext context) {
    fetchBatteryInfo();
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Card(
              color: foreGround,
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  isCharging == true
                                      ? 'Charging'
                                      : 'No Charging',
                                  style: TextStyle(
                                      color: isCharging == true
                                          ? textColor
                                          : themeColor,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: screenWidth * 0.05),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$batteryLevel%',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            // StreamBuilder<AndroidBatteryInfo?>(
                            //   stream: BatteryInfoPlugin().androidBatteryInfoStream,
                            //   builder: (context, snapshot) {
                            //     if (snapshot.data!.chargingStatus == ChargingStatus.Charging) {
                            //       return Text(
                            //         formatChargeTimeRemaining(snapshot.data!.chargeTimeRemaining!),
                            //         style: TextStyle(color: linesColor),
                            //       );
                            //     }
                            //     return Text(
                            //       isCharging == false
                            //           ? "Not connected"
                            //           : snapshot.data!.chargeTimeRemaining! == 0
                            //           ? 'Battery is full'
                            //           : '',
                            //       style: TextStyle(color: linesColor),
                            //     );
                            //   },
                            // )
                            Row(
                              children: [
                                Text(
                                  '${timeRemaining.inHours}h ${timeRemaining
                                      .inMinutes.remainder(60)}m',
                                  style: TextStyle(color: linesColor),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Column(
                        children: [
                          // Align(
                          //   alignment: Alignment.topRight,
                          //   child: AnimatedMP4CircularProgressIndicator(
                          //       screen: 'home'),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Card(
              color: foreGround,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/icons/Temperature.svg'),
                              SizedBox(width: screenWidth * 0.01),
                              Obx(() {
                                return controller.temperature.value == true
                                    ? Text(
                                  '${(batteryTemperature * 9/5 + 32)} °F',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                    : Text(
                                  '0°C',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }),
                            ],
                          ),
                          SizedBox(height: screenWidth * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Temperature',
                                style: TextStyle(
                                  color: linesColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenWidth * 0.03),
                          RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                              width: 1,
                              height: screenWidth * 0.4,
                              color: linesColor,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.03),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                  'assets/icons/Battery Health.svg'),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                batteryHealth,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenWidth * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Battery Health',
                                style: TextStyle(
                                  color: linesColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: screenWidth * 0.3,
                      color: linesColor,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/icons/Voltage.svg'),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                '$batteryVoltage V',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenWidth * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Voltage',
                                style: TextStyle(
                                  color: linesColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenWidth * 0.03),
                          RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                              width: 1,
                              height: screenWidth * 0.4,
                              color: linesColor,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.03),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                  'assets/icons/Battery Capacity.svg'),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                '$batteryCapacity',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenWidth * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Capacity',
                                style: TextStyle(
                                  color: linesColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                right: screenWidth * 0.05, left: screenWidth * 0.05),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BatteryAlarm(),
                  ),
                );
              },
              icon: SvgPicture.asset('assets/icons/Battery Alarm.svg'),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.04),
                    child: const Text('Battery Alarm'),
                  ),
                  SvgPicture.asset('assets/icons/small_ arrow _ next.svg'),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: foreGround,
                padding: EdgeInsets.all(screenWidth * 0.05),
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.0125),
          Padding(
            padding: EdgeInsets.only(
                right: screenWidth * 0.05, left: screenWidth * 0.05),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DeviceInfoScreen()),
                );
              },
              icon: SvgPicture.asset('assets/icons/Device Information.svg'),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.04),
                    child: const Text('Device Information'),
                  ),
                  SvgPicture.asset('assets/icons/small_ arrow _ next.svg'),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: foreGround,
                padding: EdgeInsets.all(screenWidth * 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

// String formatChargeTimeRemaining(int chargeTimeRemaining) {
//   if (chargeTimeRemaining == -1) {
//     return "";
//   }
//
//   int hours = (chargeTimeRemaining / 1000 / 60 / 60).truncate();
//   int minutes = ((chargeTimeRemaining / 1000 / 60) % 60).truncate();
//
//   if (hours > 0) {
//     return "${hours}h : ${minutes}m";
//   } else {
//     return "$minutes m";
//   }
// }
//   bool isProcessing = false;
//
//   Future<void> backgroundAppToggle(bool value) async {
//     if (isProcessing) return;
//
//     isProcessing = true;
//
//     final service = FlutterBackgroundService();
//
//     if (value) {
//       print('adadadasd');
//       bool serviceStarted = await service.startService();
//       if (serviceStarted == true) {
//         print('adadadasd');
//
//         // battery.onBatteryStateChanged.listen((BatteryState state) async {
//         //   print('adadadasd');
//         //   final status =
//         //   state == BatteryState.charging ? 'Charging' : 'Discharging';
//         //   final timestamp = DateTime.now();
//         //   final batteryLevel = await battery.batteryLevel;
//         //
//         //   if (state != lastState) {
//         //     lastState = state;
//         //
//         //     if (state == BatteryState.charging) {
//         //       plugInTime = timestamp;
//         //       plugInPercentage = batteryLevel;
//         //       chargeStartTime = timestamp;
//         //
//         //     } else if (state == BatteryState.discharging && plugInTime != null) {
//         //       final plugOutTime = timestamp;
//         //       final plugOutPercentage = batteryLevel;
//         //       final chargeTime = plugOutTime.difference(chargeStartTime);
//         //
//         //       //asign data to BatteryHistory Class to add in data base
//         //
//         //       final historyEntry = BatteryHistory(
//         //         chargeTime: chargeTime,
//         //         status: status,
//         //         percentage: plugOutPercentage,
//         //         timestamp: timestamp,
//         //         plugInTimestamp: plugInTime,
//         //         plugOutTimestamp: plugOutTime,
//         //         plugInPercentage: plugInPercentage,
//         //         totalPercentage: totalPercentage,
//         //       );
//         //
//         //       // charging_history_provider.dart  function to add entry in data base
//         //       final historyProvider =
//         //       Provider.of<ChargingHistoryProvider>(context, listen: false);
//         //       await historyProvider.addHistoryEntry(historyEntry);
//         //
//         //       plugInTime = null;
//         //     }
//         //   } else if (state == BatteryState.charging) {
//         //     totalPercentage += batteryLevel - lastPercentage;
//         //   }
//         //
//         //   lastPercentage = batteryLevel;
//         // });
//       }
//     } else {
//       FlutterBackgroundService().invoke('stopService');
//     }
//
//     // Update the state
//     setState(() {
//       isBackgroundServiceRunningNotifier.value = value;
//     });
//
//     isProcessing = false;
//   }

  void _showPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown,
          title: Text('Background Running',style: TextStyle(color: Colors.white),),
          content: Container(
            height: 80,
            alignment: Alignment.center,
            // decoration: BoxDecoration(
            //   border: Border.all(color: Colors.redAccent)
            // ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 50,
                      child: Center(
                        child: Text(
                          'Background Running',
                          style: TextStyle(color:textColor),
                        ),
                      ),
                    ),
                    Expanded(
                      child: controller.backgroundRunnin()
                    ),
                  ],
                ),

              ],
            ),
          ),);
      },
    );
  }

//   Widget PopUp() {
//     return Column(
//       children: [
//         Text(
//           'Background Running',
//           style: TextStyle(color: textColor),
//         ),
//         const Spacer(),
//         Obx(() {
//           return Align(
//             alignment: Alignment.centerRight,
//             child: ValueListenableBuilder<bool>(
//                 valueListenable: isBackgroundServiceRunningNotifier,
//                 builder: (context, bool isRunning, _) {
//                   return Switch(
//                     onChanged: (bool newValue) {
//                       // backgroundRunningValue = newValue;
//
//                     },
//                     value: newValue,
//                     activeColor: themeColor,
//                     activeTrackColor: textColor,
//                     inactiveThumbColor: linesColor,
//                     inactiveTrackColor: textColor,
//                   );
//                 }),
//           );
//         }),
//       ],
//     );
//   }
}

// final ValueNotifier<bool> isBackgroundServiceRunningNotifier = ValueNotifier<
//     bool>(false);

