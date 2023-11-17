import 'dart:developer';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:battery_alarm/Model/ringtones_model.dart';
import 'package:battery_alarm/views/Ringtones/batteryalarm_provider.dart';
import 'package:battery_alarm/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Ringtones extends StatefulWidget {
  const Ringtones({super.key});

  @override
  State<Ringtones> createState() => _RingtonesState();
}

class _RingtonesState extends State<Ringtones> {
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  Future<void> playSound(String assetPath) async {
    try {
      await assetsAudioPlayer.open(
        Audio(assetPath),
      );
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    BatteryAlarmprovider pro = Provider.of<BatteryAlarmprovider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backGround,
        title: const Align(
            alignment: Alignment.topLeft,
            child: Text("Ringtones")),
      ),
      body: Column(
        children: [
           const Text('Select your favourite ringtone'),
          Center(
            child: ListView.builder(
              itemCount: ringtonesList.length,
              itemBuilder: (BuildContext context, int index) {
                String name = ringtonesList[index].name;
                String path = ringtonesList[index].filePath;
                log("name: $name");

                return ListTile(
                  title: Text(
                    name,
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () async {
                    await playSound(path);
                    pro.toggleCheckbox(index);
                    pro.selectedRingtone(path);
                    //play sound
                  },
                  trailing: Checkbox(
                      fillColor: MaterialStateProperty.all<Color>(Colors.blue),
                      activeColor: Colors.white,
                      checkColor: Colors.white,
                      value: pro.selectedIndex == index,
                      onChanged: (value) {
                        pro.toggleCheckbox(index);
                        pro.selectedRingtone(path);
                      }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
