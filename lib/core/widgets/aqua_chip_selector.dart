import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AquaChipOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const AquaChipOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

class AquaChipSelector<T> extends StatelessWidget {
  final List<AquaChipOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  const AquaChipSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: AppDimensions.spaceSm,
      runSpacing: AppDimensions.spaceSm,
      children: options.map((option) {
        final isSelected = option.value == selectedValue;
        final chipColor = isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceLight);
        final textColor = isSelected
            ? Colors.white
            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

        return InkWell(
          onTap: () => onSelected(option.value),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          child: Container(
            constraints: const BoxConstraints(minHeight: AppDimensions.minTouchTarget),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: chipColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  Icon(
                    option.icon,
                    size: 16,
                    color: textColor,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
