import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

class AquaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final Color? borderColor;
  final VoidCallback? onTap;

  const AquaCard({
    super.key,
    required this.child,
    this.padding,
    this.gradient,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBorder = borderColor ?? theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.8);

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.spaceMd),
      decoration: BoxDecoration(
        color: gradient == null ? theme.cardTheme.color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: defaultBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: AppDimensions.elevationMedium,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: content,
        ),
      );
    }

    return content;
  }
}
