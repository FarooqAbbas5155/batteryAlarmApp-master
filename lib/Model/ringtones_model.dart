class Ringtone {
  final String name;
  final String filePath;
  bool isSelected;

  Ringtone(
      {required this.name, required this.filePath, required this.isSelected});
}

List<Ringtone> ringtonesList = [
  Ringtone(
      isSelected: false,
      name: 'Iphone bell',
      filePath: 'assets/ringtones/iphone_bell.mp3'),
  Ringtone(
      isSelected: false,
      name: 'mixkit classic alarm',
      filePath: 'assets/ringtones/mixkit-classic-alarm-995.wav'),
  Ringtone(
      isSelected: false,
      name: 'iphone up',
      filePath: 'assets/ringtones/notification-for-iphone-up.mp3'),
  Ringtone(
      isSelected: false,
      name: 'palomita',
      filePath: 'assets/ringtones/palomita-for-iphone-iphone.mp3'),
  Ringtone(
      isSelected: false,
      name: 'Redmi note',
      filePath: 'assets/ringtones/Redmi-note-6-ring.mp3'),
  Ringtone(
      isSelected: false,
      name: 'New Call',
      filePath: 'assets/ringtones/sb-89_new_call_2021.mp3'),
  // Add entries for the other ringtones
];
