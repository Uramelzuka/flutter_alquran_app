import 'dart:io';

import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm/model/notification_settings.dart';
import 'package:alarm/model/volume_settings.dart';

AlarmSettings buildAlarmSettings({
  required bool staircaseFade,
  required double volume,
  required Duration? fadeDuration,
  required DateTime selectedDateTime,
  required bool loopAudio,
  required bool vibrate,
  required String assetAudio,
  required String adhan,
  required String locationNow,
}) {
  final id = DateTime.now().millisecondsSinceEpoch % 10000 + 1;

  final VolumeSettings volumeSettings;
  if (staircaseFade) {
    volumeSettings = VolumeSettings.staircaseFade(
      volume: volume,
      fadeSteps: [
        VolumeFadeStep(Duration.zero, 0),
        VolumeFadeStep(const Duration(seconds: 15), 0.03),
        VolumeFadeStep(const Duration(seconds: 20), 0.5),
        VolumeFadeStep(const Duration(seconds: 30), 1),
      ],
    );
  } else if (fadeDuration != null) {
    volumeSettings = VolumeSettings.fade(
      volume: volume,
      fadeDuration: fadeDuration,
    );
  } else {
    volumeSettings = VolumeSettings.fixed(volume: volume);
  }

  final alarmSettings = AlarmSettings(
    id: id,
    dateTime: selectedDateTime,
    loopAudio: loopAudio,
    vibrate: vibrate,
    assetAudioPath: assetAudio,
    warningNotificationOnKill: Platform.isIOS,
    volumeSettings: volumeSettings,
    allowAlarmOverlap: true,
    notificationSettings: NotificationSettings(
      title: 'Adzan $adhan',
      body: 'Masuk Waktu Sholat $adhan untuk $locationNow',
      stopButton: 'Tutup',
      icon: 'notification_icon',
    ),
  );
  return alarmSettings;
}
