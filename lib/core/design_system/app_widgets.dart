import 'package:flutter/material.dart';
import 'design_system.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: child,
      ),
    ],
  );
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.enabled = true,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (label != null) ...[
        Text(
          label!,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
      TextField(
        controller: controller,
        autofocus: autofocus,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        enabled: enabled,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          errorText: errorText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
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
            borderSide: const BorderSide(
              color: AppColors.orbitPrimary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          hintStyle: const TextStyle(color: AppColors.textMuted),
        ),
      ),
    ],
  );
}

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDestructive = false,
    this.icon,
    this.fullWidth = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isDestructive;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: isDestructive
                ? AppColors.error
                : AppColors.textPrimary,
            minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
            side: BorderSide(
              color: isDestructive
                  ? AppColors.error
                  : AppColors.orbitPrimary.withValues(alpha: 0.3),
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: isDestructive
                ? AppColors.error
                : AppColors.orbitPrimary,
            foregroundColor: AppColors.orbitOnPrimary,
            minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          );

    final buttonChild = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: isDestructive
          ? AppColors.error
          : AppColors.orbitPrimary,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.xxs),
        ],
        Text(label),
      ],
    ),
  );
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.size = AppSpacing.touchMin,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color ?? AppColors.textPrimary),
      iconSize: size * 0.5,
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: EdgeInsets.zero,
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
