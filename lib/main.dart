import 'dart:io' show Platform;

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alquran_app/core/constants/colors.dart';
import 'package:flutter_alquran_app/core/services/build_alarm_setting.dart';
import 'package:flutter_alquran_app/core/utils/permission.dart';
import 'package:flutter_alquran_app/core/utils/permission_utils.dart';
import 'package:flutter_alquran_app/presentations/home/main_page.dart';
import 'package:hijriyah_indonesia/hijriyah_indonesia.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'package:adhan/adhan.dart';
import 'package:geocoding/geocoding.dart';

import 'data/datasources/db_local_datasource.dart';

String arabic = 'ar';
String indonesia = 'id';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Quran.initialize();
  await Alarm.init();
  AlarmPermissions.checkNotificationPermission();
  if (Alarm.android) {
    AlarmPermissions.checkAndroidScheduleExactAlarmPermission();
  }
  Hijriyah.setLocal(indonesia);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = false;
  var myCoordinates = Coordinates(-7.7421697, 110.3751855);
  late bool creating;
  late DateTime selectedDateTime;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late Duration? fadeDuration;
  late bool staircaseFade;
  late String assetAudio;
  String locationNow = 'Kota Jakarta, Indonesia';

  @override
  void initState() {
    // selectedDateTime = DateTime.now().add(const Duration(hours: 12));
    // selectedDateTime = selectedDateTime.copyWith(second: 0, microsecond: 0);
    loopAudio = true;
    vibrate = true;
    volume = 0.5;
    fadeDuration = null;
    staircaseFade = false;
    assetAudio = 'assets/audios/mecca.mp3';
    loadLocation().then((_) {
      _setPrayerAlarms();
    });
    super.initState();
  }

  Future<void> _getLocation(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark placemark = placemarks[0];
      String city = placemark.locality ?? 'Unkwon';
      setState(() {
        locationNow = '$city, Indonesia';
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  refreshLocation() async {
    await requestLocationPermission();
    final location = await determinePosition();
    myCoordinates = Coordinates(location.latitude, location.longitude);
    String latLang = '${myCoordinates.latitude},${myCoordinates.longitude}';
    await DbLocalDatasource().saveLatLng(location.latitude, location.longitude);
  }

  Future<void> loadLocation() async {
    await requestLocationPermission();
    final latLang = await DbLocalDatasource().getLatLng();

    if (latLang.isEmpty) {
      await refreshLocation();
    } else {
      double lat = latLang[0];
      double lng = latLang[1];

      myCoordinates = Coordinates(lat, lng);
      await _getLocation(lat, lng);
    }
  }

  Future<void> _setPrayerAlarms() async {
    final params = CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes.today(myCoordinates, params);

    List<DateTime> prayerTimesList = [
      prayerTimes.fajr,
      prayerTimes.dhuhr,
      prayerTimes.asr,
      prayerTimes.maghrib,
      prayerTimes.isha,
    ];

    List<String> prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    DateTime now = DateTime.now();
    await Alarm.stopAll();

    for (int i = 0; i < prayerTimesList.length; i++) {
      DateTime prayerTime = prayerTimesList[i];

      if (prayerTime.isBefore(now)) {
        prayerTime = prayerTime.add(const Duration(days: 1));
      }
      Alarm.set(
        alarmSettings: buildAlarmSettings(
          staircaseFade: staircaseFade,
          volume: volume!,
          fadeDuration: fadeDuration,
          selectedDateTime: prayerTime,
          loopAudio: loopAudio,
          vibrate: vibrate,
          assetAudio: assetAudio,
          adhan: prayerNames[i],
          locationNow: locationNow,
        ),
      ).then((res) {
        // log('Alarm untuk ${prayerNames[i]} diatur pada $prayerTime');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const MainPageScreen(),
    );
  }
}
