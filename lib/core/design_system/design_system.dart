// =============================================================================
// CORE/DESIGN_SYSTEM - Design System & UI Primitives
// =============================================================================
// Reusable UI primitives, tokens, spacing, typography, color rules,
// common buttons/fields/cards/surfaces, loading/empty/error/retry states.
//
// ARCHITECTURE: Core module - cross-cutting concern
// DEPENDENCY RULE: Core should NOT depend on feature modules
// =============================================================================

import 'package:flutter/material.dart';

// ============================================================================
// Design Tokens
// ============================================================================

/// Design system tokens containing all design values.
class DesignTokens {
  DesignTokens._();

  // -------------------------------------------------------------------------
  // Colors
  // -------------------------------------------------------------------------

  /// Primary brand colors.
  static const Color primary = Color(0xFF0066CC);
  static const Color primaryLight = Color(0xFF4D94FF);
  static const Color primaryDark = Color(0xFF004C99);

  /// Secondary brand colors.
  static const Color secondary = Color(0xFF00A86B);
  static const Color secondaryLight = Color(0xFF4DDB9E);
  static const Color secondaryDark = Color(0xFF007A4D);

  /// Neutral colors.
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0);

  /// Text colors.
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Semantic colors.
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);

  /// Border colors.
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocused = Color(0xFF0066CC);

  // -------------------------------------------------------------------------
  // Spacing
  // -------------------------------------------------------------------------

  /// Spacing scale based on 4px grid.
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  /// Common padding combinations.
  static const EdgeInsets paddingAll8 = EdgeInsets.all(spacing8);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(spacing16);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(spacing24);
  static const EdgeInsets paddingHorizontal16 = EdgeInsets.symmetric(
    horizontal: spacing16,
  );
  static const EdgeInsets paddingVertical16 = EdgeInsets.symmetric(
    vertical: spacing16,
  );

  /// Screen padding.
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: spacing16,
    vertical: spacing24,
  );

  // -------------------------------------------------------------------------
  // Border Radius
  // -------------------------------------------------------------------------

  /// Border radius scale.
  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;
  static const double radiusFull = 9999.0;

  /// Common border radius.
  static const BorderRadius borderRadius4 = BorderRadius.all(
    Radius.circular(radius4),
  );
  static const BorderRadius borderRadius8 = BorderRadius.all(
    Radius.circular(radius8),
  );
  static const BorderRadius borderRadius12 = BorderRadius.all(
    Radius.circular(radius12),
  );
  static const BorderRadius borderRadius16 = BorderRadius.all(
    Radius.circular(radius16),
  );

  // -------------------------------------------------------------------------
  // Shadows
  // -------------------------------------------------------------------------

  /// Elevation shadows.
  static List<BoxShadow> get shadowSmall => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLarge => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // -------------------------------------------------------------------------
  // Durations
  // -------------------------------------------------------------------------

  /// Animation durations.
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // -------------------------------------------------------------------------
  // Sizes
  // -------------------------------------------------------------------------

  /// Common sizes.
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double inputHeight = 48.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
}

// ============================================================================
// Typography
// ============================================================================

/// Text styles following the design system.
class AppTypography {
  AppTypography._();

  /// Headings.
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: DesignTokens.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: DesignTokens.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: DesignTokens.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: DesignTokens.textPrimary,
  );

  /// Body text.
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: DesignTokens.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: DesignTokens.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: DesignTokens.textSecondary,
  );

  /// Labels.
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: DesignTokens.textPrimary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: DesignTokens.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: DesignTokens.textTertiary,
  );

  /// Button text.
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// Caption.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: DesignTokens.textTertiary,
  );

  /// Error text.
  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: DesignTokens.error,
  );
}

// ============================================================================
// Buttons
// ============================================================================

/// Primary button with filled style.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.size = AppButtonSize.medium,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final height = switch (size) {
      AppButtonSize.small => DesignTokens.buttonHeightSmall,
      AppButtonSize.medium => DesignTokens.buttonHeight,
      AppButtonSize.large => 56.0,
    };

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primary,
          foregroundColor: DesignTokens.textOnPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: DesignTokens.borderRadius8,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: size == AppButtonSize.small ? 16 : 24,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    DesignTokens.textOnPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: AppTypography.button),
                ],
              ),
      ),
    );
  }
}

enum AppButtonSize { small, medium, large }

/// Secondary/outline button.
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    required this.label,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: DesignTokens.buttonHeight,
    width: isFullWidth ? double.infinity : null,
    child: OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignTokens.primary,
        side: const BorderSide(color: DesignTokens.primary),
        shape: const RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadius8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(DesignTokens.primary),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: AppTypography.button.copyWith(
                    color: DesignTokens.primary,
                  ),
                ),
              ],
            ),
    ),
  );
}

/// Text button.
class AppTextButton extends StatelessWidget {
  const AppTextButton({
    required this.label,
    super.key,
    this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: DesignTokens.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 4)],
        Text(label),
      ],
    ),
  );
}

// ============================================================================
// Text Fields
// ============================================================================

/// App text field.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.focusNode,
  });
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (label != null) ...[
        Text(label!, style: AppTypography.label),
        const SizedBox(height: 8),
      ],
      TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        maxLines: maxLines,
        maxLength: maxLength,
        enabled: enabled,
        style: AppTypography.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.body.copyWith(
            color: DesignTokens.textTertiary,
          ),
          errorText: errorText,
          errorStyle: AppTypography.error,
          counterText: '',
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: enabled
              ? DesignTokens.surface
              : DesignTokens.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: const OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius8,
            borderSide: BorderSide(color: DesignTokens.border),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius8,
            borderSide: BorderSide(color: DesignTokens.border),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius8,
            borderSide: BorderSide(color: DesignTokens.primary, width: 2),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius8,
            borderSide: BorderSide(color: DesignTokens.error),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: DesignTokens.borderRadius8,
            borderSide: BorderSide(color: DesignTokens.error, width: 2),
          ),
        ),
      ),
    ],
  );
}

// ============================================================================
// Cards & Containers
// ============================================================================

/// App card container.
class AppCard extends StatelessWidget {
  const AppCard({required this.child, super.key, this.padding, this.onTap});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: DesignTokens.borderRadius12,
        boxShadow: DesignTokens.shadowSmall,
      ),
      padding: padding ?? DesignTokens.paddingAll16,
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: DesignTokens.borderRadius12,
        child: card,
      );
    }

    return card;
  }
}

// ============================================================================
// Loading, Empty, Error States
// ============================================================================

/// Loading indicator.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.size = 40, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(color ?? DesignTokens.primary),
      strokeWidth: 3,
    ),
  );
}

/// Full screen loading indicator.
class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLoadingIndicator(),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message!, style: AppTypography.body),
        ],
      ],
    ),
  );
}

/// Empty state widget.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    super.key,
    this.description,
    this.icon,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final String? description;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: DesignTokens.screenPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 64, color: DesignTokens.textTertiary),
            const SizedBox(height: 16),
          ],
          Text(title, style: AppTypography.h4, textAlign: TextAlign.center),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: AppTypography.body.copyWith(
                color: DesignTokens.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            AppButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    ),
  );
}

/// Error state widget.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
  });
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: DesignTokens.screenPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: DesignTokens.error),
          const SizedBox(height: 16),
          const Text(
            'Oops! Something went wrong',
            style: AppTypography.h4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.body.copyWith(
              color: DesignTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            AppOutlinedButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    ),
  );
}

/// Retry state with error and retry action.
class AppRetryState extends StatelessWidget {
  const AppRetryState({
    required this.message,
    required this.onRetry,
    super.key,
  });
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppErrorState(
    message: message,
    actionLabel: 'Try Again',
    onAction: onRetry,
  );
}

// ============================================================================
// Divider & Spacing
// ============================================================================

/// Vertical spacing widget.
class AppSpacing extends StatelessWidget {
  const AppSpacing(this.size, {super.key});
  const AppSpacing.xs({super.key}) : size = DesignTokens.spacing4;
  const AppSpacing.sm({super.key}) : size = DesignTokens.spacing8;
  const AppSpacing.md({super.key}) : size = DesignTokens.spacing16;
  const AppSpacing.lg({super.key}) : size = DesignTokens.spacing24;
  const AppSpacing.xl({super.key}) : size = DesignTokens.spacing32;
  const AppSpacing.xxl({super.key}) : size = DesignTokens.spacing48;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}

/// Horizontal spacing widget.
class AppHSpace extends StatelessWidget {
  const AppHSpace.xs({super.key}) : size = DesignTokens.spacing4;
  const AppHSpace.sm({super.key}) : size = DesignTokens.spacing8;
  const AppHSpace.md({super.key}) : size = DesignTokens.spacing16;
  const AppHSpace.lg({super.key}) : size = DesignTokens.spacing24;
  const AppHSpace.xl({super.key}) : size = DesignTokens.spacing32;

  const AppHSpace(this.size, {super.key});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size);
}

/// App divider.
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.height, this.color});
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Container(height: height ?? 1, color: color ?? DesignTokens.border);
}

// ============================================================================
// Avatar
// ============================================================================

/// User avatar widget.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = DesignTokens.avatarSizeMedium,
    this.onTap,
  });
  final String? imageUrl;
  final String? name;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: DesignTokens.primary,
        shape: BoxShape.circle,
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null && name != null
          ? Center(
              child: Text(
                name!.isNotEmpty ? name![0].toUpperCase() : '?',
                style: TextStyle(
                  color: DesignTokens.textOnPrimary,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : imageUrl == null
          ? Icon(
              Icons.person,
              size: size * 0.5,
              color: DesignTokens.textOnPrimary,
            )
          : null,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: avatar,
      );
    }

    return avatar;
  }
}

// ============================================================================
// App Theme
// ============================================================================

/// Creates the app theme data.
ThemeData createAppTheme({bool isDark = false}) {
  final colorScheme = ColorScheme(
    brightness: isDark ? Brightness.dark : Brightness.light,
    primary: DesignTokens.primary,
    onPrimary: DesignTokens.textOnPrimary,
    secondary: DesignTokens.secondary,
    onSecondary: DesignTokens.textOnPrimary,
    error: DesignTokens.error,
    onError: DesignTokens.textOnPrimary,
    surface: DesignTokens.surface,
    onSurface: DesignTokens.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: DesignTokens.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: DesignTokens.surface,
      foregroundColor: DesignTokens.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignTokens.primary,
        foregroundColor: DesignTokens.textOnPrimary,
        minimumSize: const Size(0, DesignTokens.buttonHeight),
        shape: const RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadius8,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignTokens.primary,
        minimumSize: const Size(0, DesignTokens.buttonHeight),
        shape: const RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadius8,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: DesignTokens.primary),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: DesignTokens.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: DesignTokens.borderRadius8,
        borderSide: BorderSide(color: DesignTokens.border),
      ),
    ),
    cardTheme: const CardThemeData(
      color: DesignTokens.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: DesignTokens.borderRadius12),
    ),
    dividerTheme: const DividerThemeData(
      color: DesignTokens.border,
      thickness: 1,
    ),
  );
}
