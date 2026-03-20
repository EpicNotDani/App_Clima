import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Weather-domain color palette ──────────────────────────────────────────
  static const Color skyBlue = Color(0xFF1565C0);
  static const Color deepNight = Color(0xFF0A1628);
  static const Color stormGrey = Color(0xFF37474F);
  static const Color sunriseGold = Color(0xFFFFB74D);
  static const Color clearAqua = Color(0xFF81D4FA);
  static const Color rainPurple = Color(0xFF4527A0);
  static const Color snowWhite = Color(0xFFE3F2FD);

  // Glass surface tokens
  static const Color glassSurface = Color(0x1FFFFFFF); // 12% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white
  static const Color glassDeep = Color(0x0DFFFFFF); // 5% white

  // Semantic
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFA726);
  static const Color errorRed = Color(0xFFEF5350);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xBFFFFFFF); // 75%
  static const Color textMuted = Color(0x80FFFFFF); // 50%

  // ── Weather condition gradients ────────────────────────────────────────────
  static const List<Color> clearDayGradient = [
    Color(0xFF1976D2),
    Color(0xFF42A5F5),
    Color(0xFF64B5F6),
  ];

  static const List<Color> clearNightGradient = [
    Color(0xFF0A1628),
    Color(0xFF0D2137),
    Color(0xFF1A2F4A),
  ];

  static const List<Color> cloudyGradient = [
    Color(0xFF455A64),
    Color(0xFF607D8B),
    Color(0xFF78909C),
  ];

  static const List<Color> rainyGradient = [
    Color(0xFF1A237E),
    Color(0xFF283593),
    Color(0xFF3949AB),
  ];

  static const List<Color> stormyGradient = [
    Color(0xFF212121),
    Color(0xFF37474F),
    Color(0xFF455A64),
  ];

  static const List<Color> sunriseGradient = [
    Color(0xFF4A148C),
    Color(0xFFE65100),
    Color(0xFFFFB74D),
  ];

  static const List<Color> snowGradient = [
    Color(0xFF546E7A),
    Color(0xFF78909C),
    Color(0xFFB0BEC5),
  ];

  static const List<Color> fogGradient = [
    Color(0xFF607D8B),
    Color(0xFF78909C),
    Color(0xFF90A4AE),
  ];

  // ── Light Theme (fallback) ─────────────────────────────────────────────────
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  // ── Dark Theme (primary) ───────────────────────────────────────────────────
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark
        ? const ColorScheme.dark(
            primary: skyBlue,
            primaryContainer: Color(0xFF0D47A1),
            secondary: sunriseGold,
            secondaryContainer: Color(0xFFE65100),
            surface: Color(0xFF0A1628),
            error: errorRed,
            onPrimary: textPrimary,
            onSecondary: textPrimary,
            onSurface: textPrimary,
            onError: textPrimary,
            outline: glassBorder,
            outlineVariant: glassDeep,
          )
        : const ColorScheme.light(
            primary: skyBlue,
            primaryContainer: Color(0xFFBBDEFB),
            secondary: sunriseGold,
            surface: Color(0xFFF5F9FF),
            error: errorRed,
          );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.w300,
          color: textPrimary,
          letterSpacing: -2,
        ),
        displayMedium: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w300,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 1.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.3,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: glassSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: glassBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: glassSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: clearAqua, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: skyBlue,
        foregroundColor: textPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: textPrimary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      dividerTheme: const DividerThemeData(color: glassBorder, thickness: 1),
    );
  }
}