import 'package:flutter/material.dart';
import 'package:flutter_alquran_app/core/components/spaces.dart';
import 'package:flutter_alquran_app/core/constants/colors.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_alquran_app/core/utils/permission_utils.dart';
import 'package:flutter_alquran_app/data/datasources/db_local_datasource.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class SholatPageScreen extends StatefulWidget {
  const SholatPageScreen({super.key});

  @override
  State<SholatPageScreen> createState() => _SholatPageScreenState();
}

class _SholatPageScreenState extends State<SholatPageScreen> {
  var myCoordinates = Coordinates(-7.7421697, 110.3751855);
  var params = CalculationMethod.singapore.getParameters();

  String? imsak;
  String? fajr;
  String? sunrise;
  String? dhuhr;
  String? asr;
  String? maghrib;
  String? isha;

  DateTime selectedDate = DateTime.now();
  String locationNow = "Kota Jakarta, Indonesia";

  @override
  void initState() {
    params.madhab = Madhab.shafi;
    // params.adjustments.fajr = 2;
    // params.adjustments.sunrise = 2;
    // params.adjustments.dhuhr = 3;
    // params.adjustments.asr = 3;
    // params.adjustments.maghrib = 4;
    // params.adjustments.isha = 2;

    loadLocation();
    super.initState();
  }

  void calculatePrayerTimes(DateTime date) {
    DateComponents dateComponents = DateComponents(
      date.year,
      date.month,
      date.day,
    );
    final prayerTimes = PrayerTimes(myCoordinates, dateComponents, params);

    setState(() {
      imsak = DateFormat.jm().format(
        prayerTimes.fajr.subtract(Duration(minutes: 10)),
      );
      fajr = DateFormat.jm().format(prayerTimes.fajr);
      sunrise = DateFormat.jm().format(prayerTimes.sunrise);
      dhuhr = DateFormat.jm().format(prayerTimes.dhuhr);
      asr = DateFormat.jm().format(prayerTimes.asr);
      maghrib = DateFormat.jm().format(prayerTimes.maghrib);
      isha = DateFormat.jm().format(prayerTimes.isha);
      selectedDate = date;
    });
  }

  void onChangeDate(int days) {
    DateTime newDate = selectedDate.add(Duration(days: days));
    calculatePrayerTimes(newDate);
  }

  void refreshLocation() async {
    await requestLocationPermission();
    final location = await determinePosition();
    // String latLng = '${location.latitude},${location.longitude}';
    myCoordinates = Coordinates(location.latitude, location.longitude);
    List<Placemark> placemarks = await placemarkFromCoordinates(
      location.latitude,
      location.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      locationNow = "${place.subAdministrativeArea}, ${place.country}";
      final prayerTimes = PrayerTimes.today(myCoordinates, params);

      imsak = DateFormat.jm().format(
        prayerTimes.fajr.subtract(Duration(minutes: 10)),
      );
      fajr = DateFormat.jm().format(prayerTimes.fajr);
      sunrise = DateFormat.jm().format(prayerTimes.sunrise);
      dhuhr = DateFormat.jm().format(prayerTimes.dhuhr);
      asr = DateFormat.jm().format(prayerTimes.asr);
      maghrib = DateFormat.jm().format(prayerTimes.maghrib);
      isha = DateFormat.jm().format(prayerTimes.isha);
      setState(() {});
    }
    await DbLocalDatasource().saveLatLng(location.latitude, location.longitude);
  }

  void loadLocation() async {
    await requestLocationPermission();
    final latLng = await DbLocalDatasource().getLatLng();
    if (latLng.isEmpty) {
      refreshLocation();
    } else {
      double lat = latLng[0];
      double lng = latLng[1];

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        myCoordinates = Coordinates(lat, lng);
        Placemark place = placemarks[0];
        locationNow = "${place.subAdministrativeArea}, ${place.country}";

        final prayerTimes = PrayerTimes.today(myCoordinates, params);

        imsak = DateFormat.jm().format(
          prayerTimes.fajr.subtract(Duration(minutes: 10)),
        );
        fajr = DateFormat.jm().format(prayerTimes.fajr);
        sunrise = DateFormat.jm().format(prayerTimes.sunrise);
        dhuhr = DateFormat.jm().format(prayerTimes.dhuhr);
        asr = DateFormat.jm().format(prayerTimes.asr);
        maghrib = DateFormat.jm().format(prayerTimes.maghrib);
        isha = DateFormat.jm().format(prayerTimes.isha);

        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Sholat', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () async {
              DateTime? pickDate = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2050),
                initialDate: selectedDate,
              );
              if (pickDate != null) {
                selectedDate = pickDate;
                calculatePrayerTimes(pickDate);
              }
            },
            icon: const Icon(Icons.calendar_month, color: Colors.white),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  locationNow,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              SpaceWidth(10),
              IconButton(
                onPressed: () {
                  refreshLocation();
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ),
          SpaceHeight(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  onChangeDate(-1);
                },
                icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 32),
              ),
              Text(
                DateFormat('dd MMMM yyyy').format(selectedDate),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: () {
                  onChangeDate(1);
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SpaceHeight(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Imsak",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  imsak ?? "-",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          const SpaceHeight(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Terbit",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  sunrise ?? "-",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          const SpaceHeight(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Subuh",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  fajr ?? "-",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          const SpaceHeight(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Dzuhur",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  dhuhr ?? "-",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          const SpaceHeight(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ashar",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  asr ?? "-",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          const SpaceHeight(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Magrib",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  maghrib ?? "-",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          const SpaceHeight(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Isya",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  isha ?? "-",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
