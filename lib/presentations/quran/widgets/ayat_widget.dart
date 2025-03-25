import 'package:flutter/material.dart';
import 'package:flutter_alquran_app/core/constants/colors.dart';
import 'package:quran_flutter/enums/quran_language.dart';
import 'package:quran_flutter/models/verse.dart';

class AyatWidget extends StatelessWidget {
  final Verse verse;
  final QuranLanguage translationLanguage;
  final Map<int, Map<int, Verse>> translatedVerses;
  const AyatWidget({
    super.key,
    required this.verse,
    required this.translationLanguage,
    required this.translatedVerses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.card,
            child: Text(
              verse.verseNumber.toString(),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              verse.text,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
                fontFamily: 'Uthmanic',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment:
                translationLanguage.isRTL
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
            child: Text(
              translatedVerses[verse.surahNumber]![verse.verseNumber]!.text,
              textAlign:
                  translationLanguage.isRTL ? TextAlign.right : TextAlign.left,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
