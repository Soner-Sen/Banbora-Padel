import 'package:flutter/material.dart';

abstract final class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double touchMin = 48;
  static const double buttonHeight = 56;

  // Aliases for backwards compatibility
  static const double spacing4 = xxs;
  static const double spacing8 = xs;
  static const double spacing12 = sm;
  static const double spacing16 = md;
  static const double spacing20 = lg;
  static const double spacing24 = xl;
  static const double spacing32 = xxl;
}

abstract final class AppRadius {
  AppRadius._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 999;

  // Aliases
  static const double borderRadius8 = sm;
  static const double borderRadius10 = md;
  static const double borderRadius14 = md;
  static const double borderRadius18 = lg;
  static const double borderRadius24 = xl;
}

abstract final class AppColors {
  AppColors._();

  static const Color canvas = Color(0xFF0B1220);
  static const Color surface = Color(0xFF101A2E);
  static const Color elevated = Color(0xFF16233A);
  static const Color surfaceVariant = elevated;

  static const Color courtBase = Color(0xFF0F6D64);
  static const Color courtLine = Color(0xFFDCE7F5);
  static const Color courtNet = Color(0xFF94A3B8);

  static const Color orbitPrimary = Color(0xFF19C2B3);
  static const Color orbitPrimaryPressed = Color(0xFF12A89B);
  static const Color orbitOnPrimary = Color(0xFF0B1220);

  static const Color accentAmber = Color(0xFFE7B84B);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFDCE7F5);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textTertiary = textMuted;

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  static const Color teamA = orbitPrimary;
  static const Color teamB = accentAmber;

  // Aliases for backwards compatibility
  static const Color primary = orbitPrimary;
  static const Color secondary = accentAmber;
  static const Color onPrimary = orbitOnPrimary;
  static const Color textOnPrimary = orbitOnPrimary;
}

abstract final class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration scoreFeedback = Duration(milliseconds: 100);
}

abstract final class AppElevation {
  AppElevation._();

  static const double none = 0;
  static const double low = 2;
  static const double medium = 4;
  static const double high = 8;
}

class DesignTokens {
  const DesignTokens._();

  // Spacing
  static const double spacing4 = AppSpacing.spacing4;
  static const double spacing8 = AppSpacing.spacing8;
  static const double spacing12 = AppSpacing.spacing12;
  static const double spacing16 = AppSpacing.spacing16;
  static const double spacing20 = AppSpacing.spacing20;
  static const double spacing24 = AppSpacing.spacing24;
  static const double spacing32 = AppSpacing.spacing32;
  static const double spacing48 = 48;
  static const double spacing = spacing16;

  // Radius
  static const double borderRadius8 = AppRadius.borderRadius8;
  static const double borderRadius10 = AppRadius.borderRadius10;
  static const double borderRadius14 = AppRadius.borderRadius14;
  static const double borderRadius18 = AppRadius.borderRadius18;
  static const double borderRadius24 = AppRadius.borderRadius24;

  // Colors
  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.secondary;
  static const Color onPrimary = AppColors.onPrimary;
  static const Color textOnPrimary = AppColors.textOnPrimary;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textTertiary = AppColors.textTertiary;
  static const Color surface = AppColors.surface;
  static const Color elevated = AppColors.elevated;
  static const Color surfaceVariant = AppColors.surfaceVariant;
  static const Color error = AppColors.error;
  static const Color info = AppColors.info;
  static const Color warning = AppColors.warning;
  static const Color success = AppColors.success;

  // Orbit colors
  static const Color orbitPrimary = AppColors.orbitPrimary;
  static const Color orbitPrimaryPressed = AppColors.orbitPrimaryPressed;
  static const Color orbitOnPrimary = AppColors.orbitOnPrimary;

  // Text colors
  static const Color textMuted = AppColors.textMuted;

  // Team colors
  static const Color teamA = AppColors.teamA;
  static const Color teamB = AppColors.teamB;

  // Court colors
  static const Color courtBase = AppColors.courtBase;
  static const Color courtLine = AppColors.courtLine;
  static const Color courtNet = AppColors.courtNet;

  // Elevation
  static const double elevationNone = AppElevation.none;
  static const double elevationLow = AppElevation.low;
  static const double elevationMedium = AppElevation.medium;
  static const double elevationHigh = AppElevation.high;
}
