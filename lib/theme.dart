// lib/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/models.dart';

class AppTheme {
  // Palette
  static const Color bg = Color(0xFF151719);
  static const Color surface = Color(0xFF202326);
  static const Color surfaceElevated = Color(0xFF2A2E32);
  static const Color accent = Color(0xFF4DB6AC);
  static const Color accentSoft = Color(0xFF244B48);
  static const Color yes = Color(0xFF7CCB7A);
  static const Color no = Color(0xFFE56B5F);
  static const Color probYes = Color(0xFFB8D66F);
  static const Color probNo = Color(0xFFE39A55);
  static const Color unknown = Color(0xFF9DA7AF);
  static const Color textPrimary = Color(0xFFF4F1EA);
  static const Color textSecondary = Color(0xFFAEB4B8);
  static const Color border = Color(0xFF3A4045);
  static const Color nodeActive = Color(0xFF4DB6AC);
  static const Color nodeEliminated = Color(0xFF363331);
  static const Color nodePending = Color(0xFF30363A);
  static const Color paper = Color(0xFFE9DFCA);
  static const Color ink = Color(0xFF262421);
  static const Color brass = Color(0xFFD2A24C);
  static const Color coral = Color(0xFFE56B5F);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          surface: surface,
          primary: accent,
          onPrimary: Colors.white,
          secondary: brass,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: border),
          ),
        ),
      );

  static TextStyle get displayFont => GoogleFonts.spaceMono(
        color: textPrimary,
        fontWeight: FontWeight.bold,
      );

  static Color answerColor(UserAnswer a) {
    switch (a) {
      case UserAnswer.yes:
        return yes;
      case UserAnswer.no:
        return no;
      case UserAnswer.probablyYes:
        return probYes;
      case UserAnswer.probablyNo:
        return probNo;
      case UserAnswer.unknown:
        return unknown;
    }
  }

  static String answerLabel(UserAnswer a) {
    switch (a) {
      case UserAnswer.yes:
        return 'Sim';
      case UserAnswer.no:
        return 'Não';
      case UserAnswer.probablyYes:
        return 'Provavelmente sim';
      case UserAnswer.probablyNo:
        return 'Provavelmente não';
      case UserAnswer.unknown:
        return 'Não sei';
    }
  }

  static String answerEmoji(UserAnswer a) {
    switch (a) {
      case UserAnswer.yes:
        return '✅';
      case UserAnswer.no:
        return '❌';
      case UserAnswer.probablyYes:
        return '🟡';
      case UserAnswer.probablyNo:
        return '🟠';
      case UserAnswer.unknown:
        return '❓';
    }
  }
}
