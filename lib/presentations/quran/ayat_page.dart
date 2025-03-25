import 'package:flutter/material.dart';
import 'package:flutter_alquran_app/core/constants/colors.dart';
import 'package:flutter_alquran_app/core/extensions/build_context_ext.dart';
import 'package:flutter_alquran_app/data/datasources/db_local_datasource.dart';
import 'package:flutter_alquran_app/data/models/bookmark_model.dart';
import 'package:flutter_alquran_app/presentations/quran/widgets/ayat_widget.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AyatPage extends StatefulWidget {
  final Surah? surah;
  final Juz? juz;
  final QuranPage? page;
  final bool lastReading;
  final BookmarkModel? bookmarkModel;

  const AyatPage({
    super.key,
    this.surah,
    this.juz,
    this.page,
    this.lastReading = false,
    this.bookmarkModel,
  });

  factory AyatPage.ofSurah(
    Surah surah, {
    bool lastReading = false,
    BookmarkModel? bookmark,
  }) =>
      AyatPage(surah: surah, lastReading: lastReading, bookmarkModel: bookmark);

  @override
  State<AyatPage> createState() => _AyatPageState();
}

class _AyatPageState extends State<AyatPage> {
  Surah? surah;
  Juz? juz;
  QuranPage? page;
  final List<dynamic> surahVersList = [];
  QuranLanguage translationLanguage = QuranLanguage.indonesian;
  Map<int, Map<int, Verse>> translatedVerses = {};
  ItemScrollController itemScrollController = ItemScrollController();
  int lastReadIndex = 0;

  Future<void> scrollToLastRead() async {
    // final lastRead = await DbLocalDatasource().getBookmark();
    lastReadIndex =
        widget.bookmarkModel != null ? widget.bookmarkModel!.ayatNumber : 0;
    itemScrollController.scrollTo(
      index: widget.lastReading ? lastReadIndex : 0,
      duration: Duration(seconds: 2),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void initState() {
    surah = widget.surah;
    juz = widget.juz;
    page = widget.page;
    translatedVerses = Quran.getQuranVerses(language: translationLanguage);
    surahVersList.add(widget.surah);
    surahVersList.addAll(Quran.getSurahVersesAsList(widget.surah!.number));

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      scrollToLastRead();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(
          'Surah ${surah!.nameEnglish}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: ScrollablePositionedList.builder(
        itemScrollController: itemScrollController,
        itemBuilder: (context, index) {
          dynamic item = surahVersList[index];
          if (item is Surah) {
            return const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              child: Text(
                Quran.bismillah,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Uthmanic',
                ),
              ),
            );
          } else if (item is Verse) {
            return GestureDetector(
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Simpan Bacaan Terakhir"),
                      content: Text(
                        "Apakah Anda ingin menyimpan bacaan terakhir di Surah ${surah!.nameEnglish}, Ayat ${item.verseNumber}?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Tutup dialog
                          },
                          child: Text("Batal"),
                        ),
                        TextButton(
                          onPressed: () async {
                            BookmarkModel model = BookmarkModel(
                              surah!.nameEnglish,
                              surah!.number,
                              item.verseNumber,
                            );
                            await DbLocalDatasource().saveBookmark(model);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Bacaan terakhir disimpan!",
                                  style: TextStyle(color: AppColors.primary),
                                ),
                                backgroundColor: Colors.white,
                              ),
                            );
                          },
                          child: Text("Simpan"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: AyatWidget(
                verse: item,
                translationLanguage: translationLanguage,
                translatedVerses: translatedVerses,
              ),
            );
          } else {
            return Container();
          }
        },
        itemCount: surahVersList.length,
      ),
    );
  }
}
