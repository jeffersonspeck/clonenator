// lib/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/models.dart';

class AppTheme {
  // Palette
  static const Color bg = Color(0xFF0F1117);
  static const Color surface = Color(0xFF1A1D27);
  static const Color surfaceElevated = Color(0xFF232736);
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentSoft = Color(0xFF3D3875);
  static const Color yes = Color(0xFF2ECC71);
  static const Color no = Color(0xFFE74C3C);
  static const Color probYes = Color(0xFF27AE60);
  static const Color probNo = Color(0xFFC0392B);
  static const Color unknown = Color(0xFF95A5A6);
  static const Color textPrimary = Color(0xFFF0F0F8);
  static const Color textSecondary = Color(0xFF8A8FA8);
  static const Color border = Color(0xFF2D3148);
  static const Color nodeActive = Color(0xFF6C63FF);
  static const Color nodeEliminated = Color(0xFF3A3A4A);
  static const Color nodePending = Color(0xFF2D3148);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          surface: surface,
          primary: accent,
          onPrimary: Colors.white,
          secondary: Color(0xFF63CFFF),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
