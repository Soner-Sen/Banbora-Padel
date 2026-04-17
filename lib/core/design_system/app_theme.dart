import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_system.dart';

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.canvas,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.orbitPrimary,
    onPrimary: AppColors.orbitOnPrimary,
    secondary: AppColors.accentAmber,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.textPrimary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.canvas,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: AppElevation.none,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.orbitPrimary,
      foregroundColor: AppColors.orbitOnPrimary,
      minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
      side: BorderSide(
        color: AppColors.orbitPrimary.withValues(alpha: 0.3),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.orbitPrimary,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.elevated,
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
      borderSide: const BorderSide(color: AppColors.orbitPrimary, width: 2),
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
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.elevated,
    contentTextStyle: const TextStyle(
      color: AppColors.textPrimary,
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
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  ),
  displayMedium: TextStyle(
    fontSize: 28,
    height: 1.29,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  ),
  headlineLarge: TextStyle(
    fontSize: 26,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  ),
  headlineMedium: TextStyle(
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w700,
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
    height: 1.3,
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
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w400,
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

const TextStyle scoreTextStyle = TextStyle(
  fontSize: 36,
  fontWeight: FontWeight.w700,
  fontFeatures: [FontFeature.tabularFigures()],
  color: AppColors.textPrimary,
);

const TextStyle scoreLabelStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: AppColors.textSecondary,
);
