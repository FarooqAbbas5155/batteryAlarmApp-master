import 'package:battery_alarm/Model/ringtones_model.dart';
import 'package:flutter/material.dart';

class BatteryAlarmprovider extends ChangeNotifier {
  bool isChecked = false;
  int? selectedIndex;
  String? selectedRingtonePath;

  void toggleCheckbox(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  selectedRingtone(String path) {
    selectedRingtonePath = path;
    notifyListeners();
  }
}
