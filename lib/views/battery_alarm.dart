import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:battery_alarm/views/Ringtones/batteryalarm_provider.dart';
import 'package:battery_alarm/views/controller/home_controller.dart';
import 'package:battery_alarm/widgets/colors.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';
import 'package:volume_controller/volume_controller.dart';

class BatteryAlarm extends StatefulWidget {
  const BatteryAlarm({Key? key}) : super(key: key);

  @override
  State<BatteryAlarm> createState() => _BatteryAlarmState();
}

class _BatteryAlarmState extends State<BatteryAlarm> with WidgetsBindingObserver {
  double _currentValue = 100;
  double _currentLowValue = 0;
  late bool fullBatterySwitch = false;
  bool soundSwitch = false;
  bool vibrationSwitch = false;
  bool flashlightSwitch = false;
  String selctedVibrate = "small";
  final assetsAudioPlayer = AssetsAudioPlayer();
  final Battery _battery = Battery();
  late SharedPreferences prefs;
  double _volumeListenerValue = 0;

  late List<CameraDescription> cameras;
  CameraController? _controller;
  Color _bgColor = Colors.white;
  late Timer _blinkTimer;
  // bool _isFlashOn = false;

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras.isNotEmpty) {
        _controller = CameraController(cameras[0], ResolutionPreset.low);
        await _controller?.initialize();
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }
  void _toggleFlashlightWithDelay() {
    Future.delayed(Duration(seconds: 1), () {
      if (flashlightSwitch) {
        if (flashlightSwitch) {
          TorchLight.disableTorch();
        } else {
          TorchLight.enableTorch();
        }
        flashlightSwitch = !flashlightSwitch;
        _toggleFlashlightWithDelay();
      }
    });
  }
  Future<void> toggleFlashlights(bool light) async {
    if (_controller != null && _controller!.value.isInitialized) {
      if (flashlightSwitch == false) {
        await _controller?.setFlashMode(FlashMode.off);
        setState(() {
         light = false;
        });
      } else {
        _toggleFlashlightWithDelay();
        await _controller?.setFlashMode(FlashMode.torch);
        setState(() {
          light = true;
        });
      }
    }
  }

  Future<void> disposeFlashlight() async {
    _controller?.dispose();
    _blinkTimer.cancel();
    setState(() {
      flashlightSwitch = false;
      flashlightSwitch = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    disposeFlashlight();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initializeCamera();
    } else if (state == AppLifecycleState.paused) {
      disposeFlashlight();
    }
  }

  var controller = Get.put(HomeController());

  @override
  void initState() {
    _getCurrentSoundMode();
    super.initState();
    VolumeController().listener((volume) {
      setState(() => _volumeListenerValue = volume);
    });

    loadSettings();
    monitorBatteryLevel();
    WidgetsBinding.instance!.addObserver(this);
    initializeCamera();

    _blinkTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      // toggleFlashlights();
    });
  }

  bool _isNotificationShown = false;
  bool isLowBatteryNotificationShown = false;

  void monitorBatteryLevel() {
    _battery.onBatteryStateChanged.listen((BatteryState state) async {
      final batteryLevel = await _battery.batteryLevel;
      if (fullBatterySwitch) {
        if (batteryLevel.toInt() == _currentValue.toInt()) {
          if (!_isNotificationShown) {
            await showBatteryAlarmNotification(
                message: "'Battery level reached to ${_currentValue.toInt().round()}% ");
            _isNotificationShown = true;
            prefs.setBool('isNotificationShown', false);
          } else {
            _isNotificationShown = false;
          }
        }
      }

      if (controller.lowBatterySwitch.value) {
        if (batteryLevel.toInt() == _currentLowValue.toInt()) {
          if (!isLowBatteryNotificationShown) {
            await showBatteryAlarmNotification();
            isLowBatteryNotificationShown = true;
            prefs.setBool('isLowBatteryNotificationShown', false);
          } else {
            isLowBatteryNotificationShown = false;
          }
        }
      }
    });
    setState(() {});
  }

  RingerModeStatus ringerStatus = RingerModeStatus.unknown;
  Future<void> _getCurrentSoundMode() async {
    ringerStatus = RingerModeStatus.unknown;

    Future.delayed(const Duration(seconds: 1), () async {
      try {
        ringerStatus = await SoundMode.ringerModeStatus;
        if (ringerStatus == "silent") {}
      } catch (err) {
        ringerStatus = RingerModeStatus.unknown;
      }

      setState(() {
        ringerStatus = ringerStatus;
      });
    });
  }

  Future<void> showBatteryAlarmNotification({String? message}) async {
    if (ringerStatus == "normal") {
      playAlarmSound(context);
    }
    if (ringerStatus == "silent") {
      playAlarmSound(context);
    }
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'basic_channel',
        title: 'Battery Alarm',
        body: message ?? 'Battery level reached your selected level!',
      ),
    );
  }

  void playAlarmSound(BuildContext context) {
    BatteryAlarmprovider pro = Provider.of<BatteryAlarmprovider>(context, listen: false);
    AssetsAudioPlayer player = AssetsAudioPlayer.newPlayer();

    AssetsAudioPlayer.newPlayer().open(
      Audio(pro.selectedRingtonePath!),
      autoStart: true,
      showNotification: true,
      loopMode: LoopMode.single,
    );
    player.playlistAudioFinished.listen((finished) {
      // Stop the flashlight when the alarm sound finishes
      toggleFlashlights(false);
      player.dispose(); // Dispose the player after the sound finishes
    });
    if (vibrationSwitch == true) {
      if (selctedVibrate == "small") {
        Vibration.vibrate(duration: 1000);
      } else if (selctedVibrate == "medium") {
        Vibration.vibrate(pattern: [500, 1000, 500, 2000, 500, 3000, 500, 500]);
      } else if (selctedVibrate == "large") {
        Vibration.vibrate(
          pattern: [500, 1000, 500, 2000, 500, 3000, 500, 500],
          intensities: [0, 128, 0, 255, 0, 64, 0, 255],
        );
      }
    } else {
      Vibration.vibrate(duration: 0);
    }
  }

  void toggleSwitch(bool value) {
    setState(() {
      fullBatterySwitch = value;
    });
    prefs.setBool('fullBatterySwitch', value);
  }

  void lowToggleSwitch(bool value) {
    setState(() {
      controller.lowBatterySwitch.value = value;
    });
    prefs.setBool('lowBatterySwitch', value);
  }

  void ToggleSwitchSound(bool value) async {
    setState(() {
      soundSwitch = value;
    });
    prefs.setBool('soundSwitch', value);

    if (value) {
      VolumeController().maxVolume();
    } else {
      VolumeController().muteVolume();
    }
  }

  void ToggleSwitchVibration(bool value) {
    setState(() {
      vibrationSwitch = value;
    });
    prefs.setBool('vibrationSwitch', value);
  }

  Future<void> triggerAlarm() async {
    if (vibrationSwitch) {
      Vibration.vibrate(
        pattern: [500, 1000, 500, 2000, 500, 3000, 500, 500],
        intensities: [0, 128, 0, 255, 0, 64, 0, 255],
      );
    }
  }

  // void ToggleSwitchFlashlight(bool value) {
  //   setState(() {
  //     flashlightSwitch = value;
  //   });
  //   prefs.setBool('flashlightSwitch', value);
  //   toggleFlashlights();
  // }

  void toggleFlashlight(bool value) {
    if (value) {
      TorchLight.enableTorch();
    } else {
      TorchLight.disableTorch();
    }
  }

  void saveTorch(bool flashlightSwitch) async {
    prefs = await SharedPreferences.getInstance();
    await prefs?.setBool('flashlightSwitch', flashlightSwitch);
  }

  void saveVibrationSwitch(bool vibrationswitch) async {
    prefs = await SharedPreferences.getInstance();
    await prefs?.setBool('vibrationSwitch', vibrationswitch);
  }

  Future<void> loadSettings() async {
    prefs = await SharedPreferences.getInstance();
    fullBatterySwitch = prefs.getBool('fullBatterySwitch') ?? false;
    controller.lowBatterySwitch.value = prefs.getBool('lowBatterySwitch') ?? false;
    soundSwitch = prefs.getBool('soundSwitch') ?? false;
    vibrationSwitch = prefs.getBool('vibrationSwitch') ?? false;
    flashlightSwitch = prefs.getBool('flashlightSwitch') ?? false;
    selctedVibrate = prefs.getString("selctedVibrate") ?? "small";

    _currentValue = (prefs.getDouble('currentValue') ?? 100.0);
    _currentLowValue = (prefs.getDouble('currentLowValue') ?? 0.0);
    _isNotificationShown = (prefs.getBool('isNotificationShown') ?? false);
    isLowBatteryNotificationShown = (prefs.getBool('isLowBatteryNotificationShown') ?? false);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print(selctedVibrate);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backGround,
        title: Text(
          'Battery Alarm',
          style: TextStyle(
            color: textColor,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: foreGround,
            child: Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.only(top: 15.0, right: 15, left: 15),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                          'assets/icons/full_battery_alarm_icon.svg'),
                      const SizedBox(width: 10),
                      Text(
                        'Full Battery Alarm',
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Switch(
                          onChanged: toggleSwitch,
                          value: fullBatterySwitch,
                          activeColor: themeColor,
                          activeTrackColor: textColor,
                          inactiveThumbColor: linesColor,
                          inactiveTrackColor: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Row(
                    children: [
                      Text(
                        'Ring Alarm At',
                        style: TextStyle(
                          color: linesColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Slider(
                          value: _currentValue,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          onChanged: (double value) {
                            setState(() {
                              _currentValue = value;
                            });
                            prefs.setDouble('currentValue', _currentValue);
                          },
                          activeColor: themeColor,
                          // Set the active color
                          inactiveColor: linesColor, // Set the inactive color
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 35.0),
                      child: Text(
                        '${_currentValue.toInt()}%',
                        // Display the slider value here
                        style: TextStyle(
                          color: linesColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Card(
            color: foreGround,
            child: Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.only(top: 15.0, right: 15, left: 15),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/low_battery_alarm.svg'),
                      const SizedBox(width: 10),
                      Text(
                        'low Battery Alarm',
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Obx(() {
                          return Switch(
                            onChanged: lowToggleSwitch,
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
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Row(
                    children: [
                      Text(
                        'Ring Alarm At',
                        style: TextStyle(
                          color: linesColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Slider(
                          value: _currentLowValue,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          onChanged: (double value) {
                            setState(() {
                              _currentLowValue = value;
                            });
                          },
                          activeColor: themeColor,
                          // Set the active color
                          inactiveColor: linesColor, // Set the inactive color
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 35.0),
                      child: Text(
                        '${_currentLowValue.toInt()}%',
                        // Display the slider value here
                        style: TextStyle(
                          color: linesColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Card(
            color: foreGround,
            child: Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.only(top: 15.0, right: 15, left: 15),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/Sound.svg'),
                      const SizedBox(width: 10),
                      Text(
                        'Sound',
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Switch(
                          onChanged: (val) {
                            showBatteryAlarmNotification();
                          },
                          value: soundSwitch,
                          activeColor: themeColor,
                          activeTrackColor: textColor,
                          inactiveThumbColor: linesColor,
                          inactiveTrackColor: textColor,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                RotatedBox(
                  quarterTurns: 3,
                  child: Container(
                    width: 1,
                    height: 350, // Adjust the height
                    color: linesColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 15, left: 15),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/Vibrate on Silent.svg'),
                      const SizedBox(width: 10),
                      Text(
                        'Vibration',
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Switch(
                          onChanged: ToggleSwitchVibration,
                          value: vibrationSwitch,
                          activeColor: themeColor,
                          activeTrackColor: textColor,
                          inactiveThumbColor: linesColor,
                          inactiveTrackColor: textColor,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                RotatedBox(
                  quarterTurns: 3,
                  child: Container(
                    width: 1,
                    height: 350, // Adjust the height
                    color: linesColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 15, left: 15),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/Flashlight.svg'),
                      const SizedBox(width: 10),
                      Text(
                        'Flashlight',
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Switch(
                          onChanged:(bool newValue){
                            // ToggleSwitchFlashlight(newValue);
                            saveTorch(newValue);
                            flashlightSwitch = newValue;

                              //toggleFlashlights();

                            // controller.flashlight.value= flashlightSwitch;
                            print(flashlightSwitch);
                            setState(() {

                            });
                          },
                          value: flashlightSwitch,
                          activeColor: themeColor,
                          activeTrackColor: textColor,
                          inactiveThumbColor: linesColor,
                          inactiveTrackColor: textColor,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
