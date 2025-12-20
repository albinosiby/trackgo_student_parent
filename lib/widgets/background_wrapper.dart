import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.mainBackgroundGradient,
      ),
      child: child,
    );
  }
}
