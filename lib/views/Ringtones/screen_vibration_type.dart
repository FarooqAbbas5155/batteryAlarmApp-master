import 'package:battery_alarm/views/controller/home_controller.dart';
import 'package:battery_alarm/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenVibrationType extends StatefulWidget {
  @override
  State<ScreenVibrationType> createState() => _ScreenVibrationTypeState();
}

class _ScreenVibrationTypeState extends State<ScreenVibrationType> {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backGround,
        title: Text(
          'Vibrate Type',
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
                  buildRadio("small", "Short time"),
                  buildRadio("medium", "Medium"),
                  buildRadio("large", "Long time"),
                ],
              ),
            ),
          ).paddingAll(20)
        ),
      ),
    );
  }

  void vibrationValue(String newValue)async{
   final prefs = await SharedPreferences.getInstance();
   prefs.setString("selctedVibrate", newValue);
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
              vibrationValue(value!);
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
