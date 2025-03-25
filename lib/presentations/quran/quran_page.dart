import 'package:flutter/material.dart';
import 'package:flutter_alquran_app/core/components/spaces.dart';
import 'package:flutter_alquran_app/core/constants/colors.dart';
import 'package:flutter_alquran_app/data/datasources/db_local_datasource.dart';
import 'package:flutter_alquran_app/data/models/bookmark_model.dart';
import 'package:flutter_alquran_app/presentations/quran/ayat_page.dart';
import 'package:quran_flutter/quran_flutter.dart';

class QuranPageScreen extends StatefulWidget {
  const QuranPageScreen({super.key});

  @override
  State<QuranPageScreen> createState() => _QuranPageScreenState();
}

class _QuranPageScreenState extends State<QuranPageScreen> {
  List<Surah> surahs = [];

  BookmarkModel? bookmarkModel;

  void loadData() async {
    final bookmark = await DbLocalDatasource().getBookmark();
    if (bookmark != null) {
      setState(() {
        bookmarkModel = bookmark;
      });
    }
  }

  @override
  void initState() {
    surahs = Quran.getSurahAsList();
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Al-Qur\'an', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          bookmarkModel == null
              ? SizedBox()
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.book, color: Colors.white, size: 24),
                        ),
                        SpaceWidth(4.0),
                        Expanded(
                          child: Text(
                            '${bookmarkModel!.suratName}  ${bookmarkModel!.suratNumber}:${bookmarkModel!.ayatNumber}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AyatPage.ofSurah(
                                Quran.getSurah(bookmarkModel!.ayatNumber),
                                lastReading: true,
                                bookmark: bookmarkModel,
                              ),
                        ),
                      );
                      loadData();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        "Lanjutkan",
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          SpaceHeight(14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "Daftar Surah",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ),
          SpaceHeight(16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: surahs.length,
            itemBuilder: (context, index) {
              final surah = surahs[index];
              return InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AyatPage.ofSurah(surah),
                    ),
                  );
                  loadData();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${surah.number}',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SpaceWidth(24.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surah.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              surah.meaning,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      "${surah.verseCount} Ayat",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SpaceHeight(16.0);
            },
          ),
        ],
      ),
    );
  }
}
