import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_system.dart';

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.canvas,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.teamB,
    onSecondary: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.onPrimary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.canvas,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shadowColor: AppColors.primary.withValues(alpha: 0.05),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
      side: const BorderSide(
        color: AppColors.primary,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.canvas, // "Inset" look - sits in canvas background
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 16),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.bottomSheet)),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.textPrimary,
    contentTextStyle: const TextStyle(
      color: AppColors.surface,
      fontSize: 14,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    behavior: SnackBarBehavior.floating,
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.elevated,
    thickness: 1,
    space: 0,
  ),
  textTheme: _buildTextTheme(),
);

TextTheme _buildTextTheme() => const TextTheme(
  displayLarge: TextStyle(
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  ),
  displayMedium: TextStyle(
    fontSize: 28,
    height: 1.29,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  ),
  headlineLarge: TextStyle(
    fontSize: 28,
    height: 1.30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  ),
  headlineMedium: TextStyle(
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  ),
  headlineSmall: TextStyle(
    fontSize: 22,
    height: 1.27,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  ),
  titleLarge: TextStyle(
    fontSize: 20,
    height: 1.30,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  ),
  titleMedium: TextStyle(
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  ),
  titleSmall: TextStyle(
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  ),
  bodyLarge: TextStyle(
    fontSize: 16,
    height: 1.50,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  ),
  bodySmall: TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  ),
  labelLarge: TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  ),
  labelMedium: TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  ),
  labelSmall: TextStyle(
    fontSize: 11,
    height: 1.45,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  ),
);

// Score display styles - larger for sunlight readability
const TextStyle scoreTextStyle = TextStyle(
  fontSize: 48,
  fontWeight: FontWeight.w700,
  fontFeatures: [FontFeature.tabularFigures()],
  color: AppColors.textPrimary,
);

const TextStyle scoreLabelStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: AppColors.textSecondary,
);
