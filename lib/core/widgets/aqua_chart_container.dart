import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import 'aqua_card.dart';

class AquaChartContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget chartWidget;
  final Widget? trailingHeader;
  final List<Widget>? legendItems;

  const AquaChartContainer({
    super.key,
    required this.title,
    this.subtitle,
    required this.chartWidget,
    this.trailingHeader,
    this.legendItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final header = trailingHeader;
    final legends = legendItems;

    return AquaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              ?header,
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: chartWidget,
          ),
          if (legends != null && legends.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: legends,
            ),
          ],
        ],
      ),
    );
  }
}
