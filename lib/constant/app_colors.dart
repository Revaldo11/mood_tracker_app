import 'package:flutter/material.dart';

class MoodColors {
  static const sad = Color(0xFF4A5578);
  static const meh = Color(0xFF8B7098);
  static const neutral = Color(0xFFC9A87A);
  static const good = Color(0xFF7FA88F);
  static const happy = Color(0xFFE8B94A);

  static const List<Color> spectrum = [sad, meh, neutral, good, happy];
}

class AppColors {
  static const paper = Color(0xFFFAF6EF);
  static const paperDim = Color(0xFFF0EAE0);
  static const ink = Color(0xFF2B2A2E);
  static const inkSoft = Color(0xFF6B6870);
  static const night = Color(0xFF1C1B22);
  static const nightDim = Color(0xFF26242E);
  static const mist = Color(0xFFF2EFEA);
  static const line = Color(0xFFE4DDD0);
  static const lineDark = Color(0x99393744);

  static const accent = Color(0xFFE8734A);
  static const accentPressed = Color(0xFFC85A34);
  static const success = MoodColors.good;
  static const error = Color(0xFFC24545);
  static const focusGlow = Color(0x4DE8734A);
}
