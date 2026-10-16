import 'package:flutter/material.dart';

class MoodColors {
  static const sad = Color(0xFF5B6F7A);
  static const meh = Color(0xFF8D7BA6);
  static const neutral = Color(0xFFC8A36A);
  static const good = Color(0xFF4CAF63);
  static const happy = Color(0xFFF4C95D);

  static const List<Color> spectrum = [sad, meh, neutral, good, happy];
}

class AppColors {
  static const paper = Color(0xFFF9FCF7);
  static const paperDim = Color(0xFFF0F7EE);
  static const ink = Color(0xFF17231D);
  static const inkSoft = Color(0xFF718075);
  static const night = Color(0xFF142019);
  static const nightDim = Color(0xFF1D2B22);
  static const mist = Color(0xFFF4FAF2);
  static const line = Color(0xFFDDE9DC);
  static const lineDark = Color(0x99607064);

  static const accent = Color(0xFF4CAF63);
  static const accentPressed = Color(0xFF368A4A);
  static const success = MoodColors.good;
  static const error = Color(0xFFC84B4B);
  static const focusGlow = Color(0x4D4CAF63);
}
