import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // =========================
  // BRAND COLORS
  // =========================

  static const ocean = Color(0xFF1A5FA8);
  static const navy = Color(0xFF0C2340);
  static const teal = Color(0xFF0D9E8A);
  static const cyan = Color(0xFF38BDF8);

  // =========================
  // SURFACE & BACKGROUND
  // =========================

  static const background = Color(0xFFF4F7FB);
  static const paleBlue = Color(0xFFE8F0FB);
  static const white = Colors.white;

  // =========================
  // TEXT
  // =========================

  static const muted = Color(0xFF5B7A9D);

  // =========================
  // SEMANTIC COLORS
  // =========================

  static const success = Color(0xFF0D9E8A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC4C4C);
  static const info = Color(0xFF2563EB);

  // =========================
  // BORDER
  // =========================

  static const border = Color(0xFFD8E3F0);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );

    final textTheme = GoogleFonts.interTextTheme(
      base.textTheme,
    ).apply(
      bodyColor: AppColors.navy,
      displayColor: AppColors.navy,
    );

    return base.copyWith(
      // =========================
      // GENERAL
      // =========================
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,

      // =========================
      // COLOR SCHEME
      // =========================
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ocean,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.ocean,
        onPrimary: Colors.white,
        secondary: AppColors.teal,
        onSecondary: Colors.white,
        surface: AppColors.white,
        onSurface: AppColors.navy,
        error: AppColors.danger,
        onError: Colors.white,
      ),

      // =========================
      // APP BAR
      // =========================
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.navy,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),

      // =========================
      // INPUT
      // =========================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        hintStyle: const TextStyle(
          color: AppColors.muted,
          fontSize: 13,
        ),

        labelStyle: const TextStyle(
          color: AppColors.muted,
          fontSize: 13,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.ocean,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.danger,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.danger,
            width: 1.5,
          ),
        ),
      ),

      // =========================
      // ELEVATED BUTTON
      // =========================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: AppColors.ocean,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.muted,

          elevation: 0,

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // =========================
      // OUTLINED BUTTON
      // =========================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          foregroundColor: AppColors.ocean,

          side: const BorderSide(
            color: AppColors.ocean,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // =========================
      // TEXT BUTTON
      // =========================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ocean,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // =========================
      // CARD
      // =========================
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppColors.border,
            width: 0.6,
          ),
        ),
      ),

      // =========================
      // DIVIDER
      // =========================
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // =========================
      // CHIP
      // =========================
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.paleBlue,
        selectedColor: AppColors.ocean,
        disabledColor: AppColors.background,

        labelStyle: const TextStyle(
          color: AppColors.navy,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),

        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        side: const BorderSide(
          color: AppColors.border,
        ),
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
        height: 68,

        indicatorColor: AppColors.paleBlue,

        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: AppColors.ocean,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              );
            }

            return const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          },
        ),

        iconTheme: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: AppColors.ocean,
                size: 23,
              );
            }

            return const IconThemeData(
              color: AppColors.muted,
              size: 22,
            );
          },
        ),
      ),

      // =========================
      // DIALOG
      // =========================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),

        titleTextStyle: const TextStyle(
          color: AppColors.navy,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),

        contentTextStyle: const TextStyle(
          color: AppColors.muted,
          fontSize: 13,
          height: 1.5,
        ),
      ),

      // =========================
      // BOTTOM SHEET
      // =========================
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
      ),

      // =========================
      // SNACKBAR
      // =========================
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        insetPadding: const EdgeInsets.all(16),
      ),

      // =========================
      // PROGRESS INDICATOR
      // =========================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.ocean,
        linearTrackColor: AppColors.paleBlue,
      ),

      // =========================
      // RADIO
      // =========================
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.ocean;
            }

            return AppColors.muted;
          },
        ),
      ),

      // =========================
      // CHECKBOX
      // =========================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.ocean;
            }

            return Colors.transparent;
          },
        ),
        checkColor: WidgetStateProperty.all(
          Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}