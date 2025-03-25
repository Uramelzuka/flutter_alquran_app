import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm/model/notification_settings.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alquran_app/core/constants/colors.dart';
import 'package:flutter_alquran_app/presentations/home/home_page.dart';
import 'package:flutter_alquran_app/presentations/home/widgets/nav_page.dart';
import 'package:flutter_alquran_app/presentations/quran/quran_page.dart';
import 'package:flutter_alquran_app/presentations/sholat/sholat_page.dart';

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomePageScreen(),
    const SholatPageScreen(),
    const QuranPageScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // final alarmSettings = AlarmSettings(
  //   id: 42,
  //   dateTime: DateTime.now().add(const Duration(seconds: 10)),
  //   assetAudioPath: 'assets/audios/mecca.mp3',
  //   loopAudio: true,
  //   vibrate: true,
  //   warningNotificationOnKill: Platform.isIOS,
  //   androidFullScreenIntent: true,
  //   volumeSettings: VolumeSettings.fixed(volume: 0.8, volumeEnforced: true),
  //   notificationSettings: const NotificationSettings(
  //     title: 'Adzan',
  //     body: 'Adzan Waktu Sholat',
  //     stopButton: 'Tutup',
  //     icon: 'notification_icon',
  //   ),
  // );

  @override
  void initState() {
    // Alarm.set(alarmSettings: alarmSettings).then((value) {
    //   print("Alarm Set ${value}");
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 16,
          top: 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -2),
              blurRadius: 30,
              blurStyle: BlurStyle.outer,
              color: AppColors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavItem(
              iconPath: 'assets/icons/ramadan.png',
              label: "Hari ini",
              isActive: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
              },
            ),
            NavItem(
              iconPath: 'assets/icons/mosque.png',
              label: "Sholat",
              isActive: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
              },
            ),
            NavItem(
              iconPath: 'assets/icons/quran.png',
              label: "Al-Qur'an",
              isActive: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
              },
            ),
          ],
        ),
      ),
    );
  }
}
