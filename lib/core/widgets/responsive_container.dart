import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;

  const ResponsiveContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxMobileWidth,
        ),
        child: child,
      ),
    );
  }
}
