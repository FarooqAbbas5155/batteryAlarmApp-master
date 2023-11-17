import 'dart:async';

import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../widgets/colors.dart';

class BatteryInfo extends StatefulWidget {
  const BatteryInfo({super.key});

  @override
  State<BatteryInfo> createState() => _BatteryInfoState();
}

class _BatteryInfoState extends State<BatteryInfo> {
  int batteryTemperature = 0;
  String batteryHealth = "";
  int batteryVoltage = 0;
  int batteryCapacity = 0;
  final BatteryInfoPlugin _batteryInfo = BatteryInfoPlugin();
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  bool isAndroid = false;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  Battery battery = Battery();

  @override
  void initState() {
    super.initState();
    _initBatteryInfo();
    _initBatteryChargingState();
    initPlatformState();
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
  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        isAndroid = true;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        isAndroid = false;
      } else {
        deviceData = <String, dynamic>{'Error:': 'Unsupported platform'};
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'displaySizeInches':
      ((build.displayMetrics.sizeInches * 10).roundToDouble() / 10),
      'displayWidthPixels': build.displayMetrics.widthPx,
      'displayWidthInches': build.displayMetrics.widthInches,
      'displayHeightPixels': build.displayMetrics.heightPx,
      'displayHeightInches': build.displayMetrics.heightInches,
      'displayXDpi': build.displayMetrics.xDpi,
      'displayYDpi': build.displayMetrics.yDpi,
      'serialNumber': build.serialNumber,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
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

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topMargin = screenHeight * 0.02; // Margin from the top
    final leftMargin = screenWidth * 0.02; // Margin from the top
    final rightMargin = screenWidth * 0.02; // Margin from the right
    final upMargin = screenHeight * 0.01;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: topMargin),
          Row(
            children: [
              SizedBox(width: leftMargin),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                    color: foreGround,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status Charging',
                          style: TextStyle(
                           color: linesColor,
                           )
                          ),
                          SizedBox(height: upMargin),
                          Text(
                            isCharging == true ? 'Charging' : 'No Charging',
                            style: TextStyle(
                              color: isCharging == true ? textColor : themeColor,
                            ),
                          )

                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                    color: foreGround,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Technology',
                              style: TextStyle(
                                color: linesColor,
                              )
                          ),
                          SizedBox(height: upMargin),
                          Text(_deviceData['brand'] ?? 'Unknown',
                              style: TextStyle(
                                color: textColor,
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: rightMargin),
            ],
          ),
          Row(
            children: [
              SizedBox(width: leftMargin),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                    color: foreGround,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Health',
                              style: TextStyle(
                                color: linesColor,
                              )
                          ),
                          SizedBox(height: upMargin),
                          Text(batteryHealth,
                              style: TextStyle(
                                color: textColor,
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                    color: foreGround,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Temperature',
                              style: TextStyle(
                                color: linesColor,
                              )
                          ),
                          SizedBox(height: upMargin),
                          Text('$batteryTemperature C',
                              style: TextStyle(
                                color: textColor,
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: rightMargin),
            ],
          ),
          Row(
        children: [
          SizedBox(width: leftMargin),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Card(
                color: foreGround,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Voltage',
                          style: TextStyle(
                            color: linesColor,
                          )
                      ),
                      SizedBox(height: upMargin),
                      Text('$batteryVoltage v',
                          style: TextStyle(
                            color: textColor,
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Card(
                color: foreGround,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Charger',
                          style: TextStyle(
                            color: linesColor,
                          )
                      ),
                      SizedBox(height: upMargin),
                      StreamBuilder<AndroidBatteryInfo?>(
                        stream: BatteryInfoPlugin().androidBatteryInfoStream,
                        builder: (context, snapshot) {

                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text('Checking...');
                              }
                              else if (snapshot.hasError) {
                                return const Text('Error');
                              }
                              else {
                                return Text( isCharging == true ? 'Wired' : 'Not Charging',
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                );
                              }
                        },
                      )
                      // StreamBuilder<String>(
                      //   stream: getChargerTypeStream(),
                      //   builder: (context, snapshot) {
                      //     if (snapshot.connectionState == ConnectionState.waiting) {
                      //       return const Text('Checking...');
                      //     }
                      //     else if (snapshot.hasError) {
                      //       return const Text('Error');
                      //     }
                      //     else {
                      //       return Text(snapshot.data ?? 'Unknown',
                      //         style: TextStyle(
                      //           color: textColor,
                      //         ),
                      //       );
                      //     }
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: rightMargin),
        ],
      ),
          Row(
            children: [
              SizedBox(width: leftMargin),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                    color: foreGround,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Model',
                              style: TextStyle(
                                color: linesColor,
                              )
                          ),
                          SizedBox(height: upMargin),
                          Text(_deviceData['localizedModel'] ?? 'Unknown',
                              style: TextStyle(
                                color: textColor,
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                    color: foreGround,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Capacity',
                              style: TextStyle(
                                color: linesColor,
                              )
                          ),
                          SizedBox(height: upMargin),
                          Text('$batteryCapacity mAH',
                              style: TextStyle(
                                color: textColor,
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: rightMargin),
            ],
          ),
          Row(
            children: [
              SizedBox(width: leftMargin),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                    color: foreGround,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Android Version',
                              style: TextStyle(
                                color: linesColor,
                              )
                          ),
                          SizedBox(height: upMargin),
                          Text(_deviceData['version.release'] ?? 'Unknown',
                              style: TextStyle(
                                color: textColor,
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                    color: foreGround,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Build ID',
                              style: TextStyle(
                                color: linesColor,
                              )
                          ),
                          SizedBox(height: upMargin),
                          Text(_deviceData['version.incremental'] ?? 'Unknown',
                              style: TextStyle(
                                color: textColor,
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: rightMargin),
            ],
          ),
        ],
      ),
    );
  }

}
