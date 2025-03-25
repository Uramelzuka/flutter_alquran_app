import 'package:flutter/material.dart';
import 'package:flutter_alquran_app/core/components/spaces.dart';
import 'package:flutter_alquran_app/core/constants/colors.dart';
import 'package:flutter_alquran_app/data/datasources/db_local_datasource.dart';
import 'package:flutter_alquran_app/data/models/bookmark_model.dart';
import 'package:flutter_alquran_app/presentations/quran/ayat_page.dart';
import 'package:flutter_alquran_app/presentations/sholat/sholat_page.dart';
import 'package:hijriyah_indonesia/hijriyah_indonesia.dart';
import 'package:adhan/adhan.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:quran_flutter/quran_flutter.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  String locationNow = "Jakarta, Indonesia";
  PrayerTimes? prayerTimes;
  String nextPrayerName = "Tidak diketahui";

  String? nextPrayerTime;
  Duration countdownDuration = Duration.zero;
  Timer? countdownTimer;
  String? now;
  Verse? lastVerse;
  Verse? lastVerseTranslation;

  BookmarkModel? lastRead;

  void _getBookmark() async {
    final bookmark = await DbLocalDatasource().getBookmark();
    setState(() {
      lastRead = bookmark;

      lastVerse = Quran.getVerse(
        surahNumber: lastRead?.suratNumber ?? 1,
        verseNumber: lastRead?.ayatNumber ?? 1,
      );

      lastVerseTranslation = Quran.getVerse(
        surahNumber: lastRead?.suratNumber ?? 1,
        verseNumber: lastRead?.ayatNumber ?? 1,
        language: QuranLanguage.indonesian,
      );
    });
  }

  void _startCountdown() async {
    countdownTimer?.cancel(); // Pastikan timer sebelumnya dihentikan
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        if (countdownDuration.inSeconds > 0) {
          countdownDuration -= Duration(seconds: 1);
        } else {
          _calculatePrayerTimes(); // Jika waktu habis, hitung ulang waktu sholat
        }
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  void _calculatePrayerTimes() async {
    List latLng = await DbLocalDatasource().getLatLng();
    double? lat;
    double? lng;

    if (latLng.isNotEmpty) {
      lat = latLng[0];
      lng = latLng[1];
    } else {
      lat = -7.797068;
      lng = 110.370529;
    }

    // Lokasi (ganti dengan koordinat lokasi pengguna)
    final myCoordinates = Coordinates(lat!, lng!); // Contoh Jakarta
    final params = CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;

    final date = DateComponents.from(DateTime.now());
    final prayerTimes = PrayerTimes(myCoordinates, date, params);

    // Dapatkan waktu sholat dalam urutan yang benar
    final times = {
      'Fajr': prayerTimes.fajr,
      'Dhuhr': prayerTimes.dhuhr,
      'Asr': prayerTimes.asr,
      'Maghrib': prayerTimes.maghrib,
      'Isha': prayerTimes.isha,
    };

    // Ambil waktu saat ini
    DateTime now = DateTime.now();
    String? upcomingPrayer;
    DateTime? upcomingTime;

    for (var entry in times.entries) {
      if (entry.value.isAfter(now)) {
        upcomingPrayer = entry.key;
        upcomingTime = entry.value;
        break;
      }
    }

    // Jika sudah lewat Isya, maka tampilkan Subuh hari berikutnya
    if (upcomingPrayer == null) {
      upcomingPrayer = "Fajr";
      upcomingTime =
          PrayerTimes(
            myCoordinates,
            DateComponents.from(DateTime.now().add(Duration(days: 1))),
            params,
          ).fajr;
    }
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      // myCoordinates = Coordinates(double.parse(lat), double.parse(lng));
      Placemark place = placemarks[0];
      locationNow = "${place.subAdministrativeArea}, ${place.country}";
    }
    setState(() {
      nextPrayerName = upcomingPrayer!;
      nextPrayerTime = DateFormat.Hm().format(upcomingTime!);
      countdownDuration = upcomingTime.difference(now);
    });

    _startCountdown();

    // geocoding  from lat lng
  }

  @override
  void initState() {
    now = DateFormat('dd MMMM yyyy').format(DateTime.now());
    _calculatePrayerTimes();
    // Verse verse = Quran.getVerse(surahNumber: 1, verseNumber: 5);
    // print(verse.text);

    _getBookmark();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var QH = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SpaceHeight(42),
          Container(
            padding: const EdgeInsets.all(16),
            height: QH * 0.32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(
                  DateTime.now().hour >= 4 && DateTime.now().hour <= 16
                      ? 'assets/images/duhur.png'
                      : 'assets/images/banner.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationNow,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      now ?? '-',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      Hijriyah.fromDate(
                        DateTime.now().toLocal(),
                      ).toFormat("dd MMMM yyyy"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '${nextPrayerName} | ${nextPrayerTime}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      '- ${_formatDuration(countdownDuration)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SholatPageScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Lihat Semua",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SpaceHeight(16),
          lastRead == null
              ? Center(
                child: Text(
                  "Belum ada Bookmark Ayat",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Bacaan terakhir ${lastRead?.suratName ?? ''} : ${lastRead?.ayatNumber ?? ''}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      if (lastRead != null) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AyatPage.ofSurah(
                                  Quran.getSurah(lastRead!.suratNumber),
                                  lastReading: true,
                                  bookmark: lastRead,
                                ),
                          ),
                        );
                        _getBookmark();
                      } else {
                        print("Belum ada Bookmark Ayat");
                      }
                    },
                    child: Text(
                      "Lanjutkan baca",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
          SpaceHeight(24),
          lastRead == null
              ? SizedBox()
              : Card(
                color: Colors.transparent,
                child: ListTile(
                  title: Text(
                    lastVerse!.text,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                      fontFamily: "Uthmanic",
                    ),
                  ),
                  subtitle: Text(
                    lastVerseTranslation!.text,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          // ListView.builder(
          //   padding: EdgeInsets.zero,
          //   itemBuilder: (context, index) {
          //     return Card(
          //       color: Colors.transparent,
          //       child: ListTile(
          //         title: Text(
          //           "Ayat",
          //           style: TextStyle(
          //             fontSize: 22,
          //             fontWeight: FontWeight.w400,
          //             color: AppColors.white,
          //           ),
          //         ),
          //         subtitle: Text(
          //           "Terjemahan",
          //           style: TextStyle(
          //             fontSize: 16,
          //             fontWeight: FontWeight.w400,
          //             color: AppColors.white,
          //           ),
          //         ),
          //       ),
          //     );
          //   },
          //   itemCount: 10,
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          // ),
          SpaceHeight(24.0),
        ],
      ),
    );
  }
}
