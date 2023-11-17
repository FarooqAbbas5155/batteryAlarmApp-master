// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

import 'package:battery_alarm/widgets/colors.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  _DeviceInfoScreenState createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  Battery battery = Battery();
  int batteryLevel = 0;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  bool isAndroid = false;

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
    initPlatformState();
  }

  Widget _buildDeviceInfoRow(String label, String value) {
    // String displayValue = isAndroid ? _deviceData[label] : value;
    // displayValue = displayValue ?? "N/A"; // Display "N/A" if the value is null

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, right: 10, left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: linesColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
            ),
          ),
        ],
      ),
    );
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

  Future<void> _getBatteryLevel() async {
    int batteryStatus = await battery.batteryLevel;
    setState(() {
      batteryLevel = batteryStatus;
    });
    log("battery percentage $batteryLevel");
  }

  @override
  Widget build(BuildContext context) {
    double batteryPercentage = batteryLevel / 100.0;
    log("battery percentage $batteryPercentage");

    Color progressColor = batteryPercentage < 0.2 ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backGround,
        title: const Text("Device Information"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              color: foreGround,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceEvenly, // Center the circular progress indicators
                        children: [
                          CircularPercentIndicator(
                            radius: 45.0,
                            lineWidth: 8.0,
                            animation: true,
                            animationDuration: 1000,
                            percent: batteryPercentage,
                            circularStrokeCap: CircularStrokeCap.round,
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '$batteryLevel%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            progressColor:
                                progressColor, // Set the progress color based on battery level
                          ),
                          CircularPercentIndicator(
                            radius: 45.0,
                            lineWidth: 8.0,
                            animation: true,
                            animationDuration: 1000,
                            percent: batteryPercentage,
                            circularStrokeCap: CircularStrokeCap.round,
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '$batteryLevel%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            progressColor:
                                progressColor, // Set the progress color based on battery level
                          ),
                          CircularPercentIndicator(
                            radius: 45.0,
                            lineWidth: 8.0,
                            animation: true,
                            animationDuration: 1000,
                            percent: batteryPercentage,
                            circularStrokeCap: CircularStrokeCap.round,
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '$batteryLevel%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            progressColor:
                                progressColor, // Set the progress color based on battery level
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly, // Center the labels
                        children: [
                          Text(
                            'RAM',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Storage',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Battery',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly, // Center the labels
                        children: [
                          Text(
                            '/3.7 GB',
                            style: TextStyle(
                              color: linesColor,
                            ),
                          ),
                          Text(
                            '25.6/52 GB',
                            style: TextStyle(
                              color: linesColor,
                            ),
                          ),
                          Text(
                            '$batteryLevel/100',
                            style: TextStyle(
                              color: linesColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Card(
                  color: foreGround,
                  child: Column(
                    children: [
                      _buildDeviceInfoRow(
                          'Manufactorer', _deviceData["manufacturer"] ?? "N/A"),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, right: 15, left: 15),
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Container(
                            width: 1,
                            height: 350, // Adjust the height
                            color: linesColor,
                          ),
                        ),
                      ), // Fetch the device name using the 'name' key
                      _buildDeviceInfoRow(
                          'Device Model', _deviceData['model'] ?? "N/A"),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, right: 15, left: 15),
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Container(
                            width: 1,
                            height: 350, // Adjust the height
                            color: linesColor,
                          ),
                        ),
                      ), // Fetch the device model using the 'model' key
                      _buildDeviceInfoRow(
                          'Operating System',
                          _deviceData['host'] ??
                              "N/A"), // Fetch the OS version using the 'systemVersion' key
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
