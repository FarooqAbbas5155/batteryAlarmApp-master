import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';

import '../../widgets/colors.dart';
import '../helper.dart';

class HomeController extends GetxController{
  RxBool temperature = false.obs;
  RxBool charging = false.obs;
  RxBool backgroundRunning = false.obs;
  RxDouble setVolumeValue = 0.0.obs;
  RxBool lowBatterySwitch = false.obs;
  RxBool vibrationSwitch = false.obs;
  RxBool flashlight = false.obs;
  RxString smallVibrate = "small".obs;
  RxString largeVibrate = "large".obs;
  RxString mediumVibrate = "medium".obs;
  RxString selctedVibrate = "small".obs;

  bool popup = false;
  RxBool isProcessing = false.obs;
  Future<void> backgroundAppToggle(bool value) async {
    if (isProcessing.value) return;

    //isProcessing.value = true;

    final service = FlutterBackgroundService();

    if (value) {
      print('adadadasd');
      bool serviceStarted = await service.startService();
      if (serviceStarted == true) {
        print('adadadasd');

        // battery.onBatteryStateChanged.listen((BatteryState state) async {
        //   print('adadadasd');
        //   final status =
        //   state == BatteryState.charging ? 'Charging' : 'Discharging';
        //   final timestamp = DateTime.now();
        //   final batteryLevel = await battery.batteryLevel;
        //
        //   if (state != lastState) {
        //     lastState = state;
        //
        //     if (state == BatteryState.charging) {
        //       plugInTime = timestamp;
        //       plugInPercentage = batteryLevel;
        //       chargeStartTime = timestamp;
        //
        //     } else if (state == BatteryState.discharging && plugInTime != null) {
        //       final plugOutTime = timestamp;
        //       final plugOutPercentage = batteryLevel;
        //       final chargeTime = plugOutTime.difference(chargeStartTime);
        //
        //       //asign data to BatteryHistory Class to add in data base
        //
        //       final historyEntry = BatteryHistory(
        //         chargeTime: chargeTime,
        //         status: status,
        //         percentage: plugOutPercentage,
        //         timestamp: timestamp,
        //         plugInTimestamp: plugInTime,
        //         plugOutTimestamp: plugOutTime,
        //         plugInPercentage: plugInPercentage,
        //         totalPercentage: totalPercentage,
        //       );
        //
        //       // charging_history_provider.dart  function to add entry in data base
        //       final historyProvider =
        //       Provider.of<ChargingHistoryProvider>(context, listen: false);
        //       await historyProvider.addHistoryEntry(historyEntry);
        //
        //       plugInTime = null;
        //     }
        //   } else if (state == BatteryState.charging) {
        //     totalPercentage += batteryLevel - lastPercentage;
        //   }
        //
        //   lastPercentage = batteryLevel;
        // });
      }
    } else {
      FlutterBackgroundService().invoke('stopService');
    }

    // Update the state
    // setState(() {
      isBackgroundServiceRunningNotifier.value = value;
    // });

    isProcessing.value = false;
  }
  Widget backgroundRunnin(){
    return Align(
      alignment: Alignment.centerRight,
      child: ValueListenableBuilder<bool>(
        valueListenable: isBackgroundServiceRunningNotifier,
        builder: (context, bool isRunning, _) {
          backgroundRunning.value = isRunning;
          return Switch(
            onChanged: backgroundAppToggle,
            value: backgroundRunning.value,
            activeColor: themeColor,
            activeTrackColor: textColor,
            inactiveThumbColor: linesColor,
            inactiveTrackColor: textColor,
          );
        },
      ),
    );
  }
}