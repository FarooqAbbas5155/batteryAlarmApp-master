import 'package:battery_alarm/views/Ringtones/ringtones.dart';
import 'package:battery_alarm/views/controller/home_controller.dart';
import 'package:battery_alarm/widgets/colors.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:volume_controller/volume_controller.dart';

import '../main.dart';
import 'ChargingHistory/charging_history_provider.dart';
import 'Ringtones/screen_flash_type.dart';
import 'Ringtones/screen_vibration_type.dart';
import 'helper.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool chargeHistorySwitch = false;
  bool isProcessing = false;
  bool ringOnSilentSwitch = false;
  bool notificationSwitch = false;
  final double _currentValue = 100;
  late SharedPreferences prefs;
  final Battery battery = Battery();
  double _volumeListenerValue = 0;
  double _setVolumeValue = 0;

  // String ringerStatus = "";


  // int lastPercentage = 0;
  // DateTime? plugInTime;
  // int plugInPercentage = 0;
  // int totalPercentage = 0;
  //
  // DateTime chargeStartTime = DateTime.now();
  //

  @override
  void initState() {
    // Initialize with current volume
    _checkBackgroundServiceStatus();
    super.initState();
    VolumeController().listener((volume) {
      setState(() {
        _volumeListenerValue = volume;
        _setVolumeValue =
            volume; // Update the slider value to reflect the system's volume
      });
    });

    // Fetch the initial volume level from the system and set it
    VolumeController().getVolume().then((volume) {
      setState(() {
        _setVolumeValue = volume; // Update the slider value
      });
    });

    loadSettings();
    battery.onBatteryStateChanged.listen((BatteryState state) {
      if (state == BatteryState.full && notificationSwitch == true) {
        requestNotificationPermissions();
        sendBatteryFullNotification();
      }
    });
  }

  _checkBackgroundServiceStatus() async {
    bool serviceStatus = await isBackgroundServiceRunning();

    isBackgroundServiceRunningNotifier.value = serviceStatus;
  }

  Future<void> requestNotificationPermissions() async {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'your_channel_id',
          channelName: 'Your Channel Name',
          channelDescription: 'Description of your channel',
          importance: NotificationImportance.High,
        ),
      ],
    );

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  void sendBatteryFullNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'alerts',
        title: 'Battery Full',
        body: 'Your battery is fully charged.',
      ),
    );
  }

  void saveVolume(double value) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setDouble('volumeValue', value);
  }

  Future<double> getVolumeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // If the key doesn't exist, return a default value (e.g., 50)
    return prefs.getDouble('volumeValue') ?? 50.0;
  }

  void toggleRingOnSilent(bool value) async {
    setState(() {
      ringOnSilentSwitch = value;
    });
    prefs.setBool('ringOnSilentSwitch', value);

    if (ringOnSilentSwitch) {
      VolumeController().maxVolume();
    } else {
      // Handle when ringOnSilentSwitch is false
    }
  }

  void chargeHistoryToggle(bool value) {
    setState(() {
      chargeHistorySwitch = value;
    });
    prefs.setBool('chargeHistorySwitch', value);
  }


  void chargeNotificationToggle(bool value) {
    setState(() {
      notificationSwitch = value;
    });
    prefs.setBool('notificationSwitch', value);
  }

  Future<void> loadSettings() async {
    prefs = await SharedPreferences.getInstance();
    chargeHistorySwitch = prefs.getBool('chargeHistorySwitch') ?? false;
    // backgroundAppSwitch = prefs.getBool('backgroundAppSwitch') ?? false;
    notificationSwitch = prefs.getBool('notificationSwitch') ?? false;
    double savedValue = prefs.getDouble('volumeValue') ?? 100;

    _setVolumeValue = savedValue;

    setState(() {});
  }

  @override
  void dispose() {
    VolumeController().removeListener();
    super.dispose();
  }

  var controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    final topMargin = screenHeight * 0.02; // Margin from the top
    final leftMargin = screenWidth * 0.02; // Margin from the top
    final rightMargin = screenWidth * 0.02; // Margin from the right
    final upMargin = screenHeight * 0.01;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: backGround,
          title: Text(
            'Setting',
            style: TextStyle(color: textColor),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: topMargin),
              ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      color: foreGround,
                      child: Column(
                        children: [
                          SizedBox(
                            height: upMargin,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: leftMargin,
                              ),
                              SizedBox(
                                width: leftMargin,
                              ),
                              ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                      textColor, BlendMode.srcIn),
                                  child: SvgPicture.asset(
                                      'assets/icons/ic_baseline-history.svg')),
                              SizedBox(
                                width: leftMargin,
                              ),
                              Text(
                                'Show Charging History',
                                style: TextStyle(color: textColor),
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Obx(() {
                                  return Switch(
                                    onChanged: (bool newValue) {
                                      controller.charging.value = newValue;
                                    },
                                    value: controller.charging.value,
                                    activeColor: themeColor,
                                    activeTrackColor: textColor,
                                    inactiveThumbColor: linesColor,
                                    inactiveTrackColor: textColor,
                                  );
                                }),
                              ),
                            ],
                          ),
                          RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                              width: 1,
                              height: 300,
                              color: linesColor,
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: leftMargin,
                              ),
                              SizedBox(
                                width: leftMargin,
                              ),
                              ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                      textColor, BlendMode.srcIn),
                                  child: SvgPicture.asset(
                                      'assets/icons/Device Information.svg')),
                              SizedBox(
                                width: leftMargin,
                              ),
                              Text(
                                'Full Charge Notification',
                                style: TextStyle(color: textColor),
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Switch(
                                  onChanged: chargeNotificationToggle,
                                  value: notificationSwitch,
                                  activeColor: themeColor,
                                  activeTrackColor: textColor,
                                  inactiveThumbColor: linesColor,
                                  inactiveTrackColor: textColor,
                                ),
                              ),
                            ],
                          ),
                          RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                              width: 1,
                              height: 300,
                              color: linesColor,
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: leftMargin,
                              ),
                              SizedBox(
                                width: leftMargin,
                              ),
                              SvgPicture.asset(
                                  'assets/icons/Temperature Unit.svg'),
                              SizedBox(
                                width: leftMargin,
                              ),
                              Text(
                                'Temperature Unit',
                                style: TextStyle(color: textColor),
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Obx(() {
                                  return Switch(
                                    onChanged: (bool newValue) {
                                      controller.temperature.value = newValue;
                                    },
                                    value: controller.temperature.value,
                                    activeColor: themeColor,
                                    activeTrackColor: textColor,
                                    inactiveThumbColor: linesColor,
                                    inactiveTrackColor: textColor,
                                  );
                                }),
                              ),
                            ],
                          ),
                          RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                              width: 1,
                              height: 300,
                              color: linesColor,
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: leftMargin,
                              ),
                              SizedBox(
                                width: leftMargin,
                              ),
                              SvgPicture.asset(
                                'assets/icons/Battery Alarm.svg',
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: leftMargin,
                              ),
                              Text(
                                'Background Running',
                                style: TextStyle(color: textColor),
                              ),
                              const Spacer(),
                              // Align(
                              //   alignment: Alignment.centerRight,
                              //   child: ValueListenableBuilder<bool>(
                              //       valueListenable: isBackgroundServiceRunningNotifier,
                              //       builder: (context, bool isRunning, _) {
                              //         controller.backgroundRunning.value = isRunning;
                              //
                              //         return Switch(
                              //           onChanged: controller.backgroundAppToggle,
                              //           value: controller.backgroundRunning.value,
                              //           activeColor: themeColor,
                              //           activeTrackColor: textColor,
                              //           inactiveThumbColor: linesColor,
                              //           inactiveTrackColor: textColor,
                              //         );
                              //       }),
                              // ),
                              controller.backgroundRunnin()
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
              ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      color: foreGround,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: leftMargin,
                                right: rightMargin,
                                top: topMargin,
                                bottom: topMargin),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const Ringtones()));
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: leftMargin,
                                  ),
                                  SvgPicture.asset(
                                      'assets/icons/Ring on Silent.svg'),
                                  SizedBox(
                                    width: leftMargin,
                                  ),
                                  Text(
                                    'Ringtone',
                                    style: TextStyle(color: textColor),
                                  ),
                                  const Spacer(),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: SvgPicture.asset(
                                          'assets/icons/right circle.svg')),
                                ],
                              ),
                            ),
                          ),
                          RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                              width: 1,
                              height: 300,
                              color: linesColor,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: leftMargin,
                                right: rightMargin,
                                top: topMargin),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: leftMargin,
                                ),
                                SvgPicture.asset('assets/icons/Volume.svg'),
                                SizedBox(
                                  width: leftMargin,
                                ),
                                Text(
                                  'Volume',
                                  style: TextStyle(color: textColor),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: upMargin, bottom: topMargin),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Obx(() {
                                    return Slider(
                                      min: 0.0,
                                      max: 100.0,
                                      divisions: 100,
                                      onChanged: (double value) {
                                        saveVolume(
                                            value); // Save the changed volume immediately
                                        setState(() {
                                          _setVolumeValue = value;
                                          VolumeController().setVolume(
                                              _setVolumeValue / 100.0);
                                          controller.setVolumeValue.value =
                                              value;
                                        });
                                      },
                                      value: controller.setVolumeValue.value,
                                      // Set the slider value to the initial volume level
                                      activeColor:
                                      themeColor,
                                      // Set the active color
                                      inactiveColor:
                                      linesColor, // Set the inactive color
                                    );
                                  }),
                                ),
                                Obx(() {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Text(
                                      '${controller.setVolumeValue.value
                                          .toInt()}%',
                                      // Display the slider value here
                                      style: TextStyle(
                                        color: linesColor,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                              width: 1,
                              height: 300,
                              color: linesColor,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: leftMargin,
                                right: rightMargin,
                                top: topMargin,
                                bottom: topMargin),
                            child: GestureDetector(
                              onTap: () {
                             Get.to(ScreenVibrationType());
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: leftMargin,
                                  ),
                                  SvgPicture.asset(
                                      'assets/icons/material-symbols_vibration.svg'),
                                  SizedBox(
                                    width: leftMargin,
                                  ),
                                  Text(
                                    'Vibration Type',
                                    style: TextStyle(color: textColor),
                                  ),
                                  const Spacer(),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: SvgPicture.asset(
                                          'assets/icons/right circle.svg')),
                                ],
                              ),
                            ),
                          ),
                          RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                              width: 1,
                              height: 300,
                              color: linesColor,
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: leftMargin,
                              ),
                              SizedBox(
                                width: leftMargin,
                              ),
                              SvgPicture.asset(
                                  'assets/icons/Ring on Silent.svg'),
                              SizedBox(
                                width: leftMargin,
                              ),
                              Text(
                                'Ring On Silent',
                                style: TextStyle(color: textColor),
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Obx(() {
                                  return Switch(
                                    onChanged: (bool newValue) {
                                      controller.lowBatterySwitch.value =
                                          newValue;
                                    },
                                    value: controller.lowBatterySwitch.value,
                                    activeColor: themeColor,
                                    activeTrackColor: textColor,
                                    inactiveThumbColor: linesColor,
                                    inactiveTrackColor: textColor,
                                  );
                                }),
                              ),
                            ],
                          ),
                          RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                              width: 1,
                              height: 300,
                              color: linesColor,
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: leftMargin,
                              ),
                              SizedBox(
                                width: leftMargin,
                              ),
                              SvgPicture.asset(
                                  'assets/icons/Vibrate on Silent.svg'),
                              SizedBox(
                                width: leftMargin,
                              ),
                              Text(
                                'Vibrate On Silent',
                                style: TextStyle(color: textColor),
                              ),
                              const Spacer(),
                              Obx(() {
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Switch(
                                    onChanged: (bool newValue){
                                      controller.vibrationSwitch.value = newValue;
                                    },
                                    value: controller.vibrationSwitch.value,
                                    activeColor: themeColor,
                                    activeTrackColor: textColor,
                                    inactiveThumbColor: linesColor,
                                    inactiveTrackColor: textColor,
                                  ),
                                );
                              }),
                            ],
                          ),
                          RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                              width: 1,
                              height: 300,
                              color: linesColor,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: leftMargin,
                                right: rightMargin,
                                top: topMargin,
                                bottom: topMargin),
                            child: GestureDetector(
                              onTap: () {
                               Get.to(ScreenFlashType());
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: leftMargin,
                                  ),
                                  SvgPicture.asset(
                                      'assets/icons/Flashing Type.svg'),
                                  SizedBox(
                                    width: leftMargin,
                                  ),
                                  Text(
                                    'Flashing Type',
                                    style: TextStyle(color: textColor),
                                  ),
                                  const Spacer(),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: SvgPicture.asset(
                                          'assets/icons/right circle.svg')),
                                ],
                              ),
                            ),
                          ),

                          // ElevatedButton(
                          //   onPressed: () => _getCurrentSoundMode(),
                          //   child: Text('Get current sound mode'),
                          // ),
                          // Text("$ringerStatus")
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ));
  }
}
