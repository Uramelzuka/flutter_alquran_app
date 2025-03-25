import 'package:flutter_alquran_app/data/models/bookmark_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DbLocalDatasource {
  Future<void> saveBookmark(BookmarkModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('surat', model.suratName);
    await prefs.setInt('suratNumber', model.suratNumber);
    await prefs.setInt('ayatNumber', model.ayatNumber);
  }

  Future<BookmarkModel?> getBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final surat = prefs.getString('surat');
    final suratNumber = prefs.getInt('suratNumber');
    final ayatNumber = prefs.getInt('ayatNumber');
    if (surat != null && suratNumber != null && ayatNumber != null) {
      return BookmarkModel(surat, suratNumber, ayatNumber);
    }
    return null;
  }

  Future<void> saveLatLng(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lat', lat);
    await prefs.setDouble('lng', lng);
  }

  Future<List<double>> getLatLng() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('lat');
    final lng = prefs.getDouble('lng');
    if (lat != null && lng != null) {
      return [lat, lng];
    }
    return [];
  }
}
