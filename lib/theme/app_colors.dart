import 'package:flutter/material.dart';

class AppColors {
  // Background Gradient
  static const Color backgroundTop = Color(0xFF0F2027); // Deep Night Blue
  static const Color backgroundBottom = Color(0xFF2C5364); // Steel Blue Grey

  // Accents
  static const Color primaryAccent = Color(0xFF00E5FF); // Electric Cyan
  static const Color success = Color(0xFF69F0AE); // Bright Mint Green
  static const Color error = Color(0xFFFF5252); // Soft Red

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure White
  static const Color textSecondary = Color(
    0xB3FFFFFF,
  ); // White with 70% Opacity (approx 0xB3)

  // Glass Effect
  static const Color glassFill = Color(0x1AFFFFFF); // White with 10% opacity
  static const Color glassBorder = Color(0x1AFFFFFF); // White with 10% opacity
  static const Color glassShadow = Color(0x1A000000); // Black with 10% opacity

  // Gradients
  static const LinearGradient mainBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundBottom],
  );
}
