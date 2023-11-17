import 'dart:async';
import 'package:battery_alarm/views/controller/home_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/colors.dart';

class ScreenFlashType extends StatefulWidget {
  @override
  State<ScreenFlashType> createState() => _ScreenFlashTypeState();
}

class _ScreenFlashTypeState extends State<ScreenFlashType> {
  HomeController controller = Get.put(HomeController());
      //with WidgetsBindingObserver
      // late List<CameraDescription> cameras;
  // CameraController? _controller; // Make _controller nullable
  //
  // Color _bgColor = Colors.white;
  //
  // late Timer _blinkTimer;
  // bool _isFlashOn = false;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance!.addObserver(this);
  //   initializeCamera();
  //
  //   // Set up a timer for blinking effect
  //   _blinkTimer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     toggleFlashlights();
  //   });
  // }
  //
  // Future<void> initializeCamera() async {
  //   try {
  //     cameras = await availableCameras();
  //
  //     if (cameras.isNotEmpty) {
  //       _controller = CameraController(cameras[0], ResolutionPreset.low);
  //       await _controller?.initialize(); // Use null-aware operator
  //     }
  //   } catch (e) {
  //     print("Error initializing camera: $e");
  //   }
  // }
  //
  // Future<void> toggleFlashlights() async {
  //   if (_controller != null && _controller!.value.isInitialized) {
  //     if (_isFlashOn) {
  //       await _controller?.setFlashMode(FlashMode.off); // Use null-aware operator
  //       setState(() {
  //         _bgColor = Colors.white;
  //       });
  //     } else {
  //       await _controller?.setFlashMode(FlashMode.torch); // Use null-aware operator
  //       setState(() {
  //         _bgColor = Colors.greenAccent;
  //       });
  //     }
  //     _isFlashOn = !_isFlashOn;
  //   }
  // }
  //
  // void disposeFlashlight() {
  //   _controller?.dispose();
  //   _blinkTimer.cancel();
  //   setState(() {
  //     _bgColor = Colors.white;
  //     _isFlashOn = false;
  //   });
  // }
  //
  // @override
  // void dispose() {
  //   WidgetsBinding.instance!.removeObserver(this);
  //   disposeFlashlight(); // Dispose flashlight when the widget is disposed
  //   super.dispose();
  // }
  //
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     initializeCamera(); // Re-initialize camera when the app is resumed
  //   } else if (state == AppLifecycleState.paused) {
  //     disposeFlashlight(); // Dispose camera when the app is paused
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backGround,
        title: Text(
          'Flash Type',
          style: TextStyle(color: textColor),
        ),
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
            height: 305,
            child: Card(
              color: foreGround,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Vibration Type:',
                      style: TextStyle(fontSize: 16,color: textColor),
                    ),
                    SizedBox(height: 10),
                    buildRadio("Short", "Short time"),
                    buildRadio("Long", "Medium"),
                  ],
                ),
              ),
            ).paddingAll(20)
        ),
      ),
    );
  }
  void flashtype(String newValue)async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("flashType", newValue);
  }
  Widget buildRadio(String value, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,style: TextStyle(color: textColor),),
        Obx(() {
          return Radio(
            value: value,
            groupValue: controller.selctedVibrate.value,
            activeColor: Colors.red,
            onChanged: (value) {
              flashtype(value!);
              controller.selctedVibrate.value = value!;
              setState(() {

              });

            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // To reduce tap target size
            visualDensity: VisualDensity.compact, // To reduce the overall size
            // Set the unselected color (background color when not selected)
            fillColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.red; // Selected color
                }
                return Colors.white; // Unselected color
              },
            ),
          );

        }),
      ],
    ).paddingAll(18);
  }

    }
