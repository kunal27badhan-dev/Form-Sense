import 'package:flutter/material.dart';

class AppUiConstants {
  static const double screenPadding = 16;
  static const double sectionGap = 14;
  static const double cardRadius = 18;
  static const double cardBlur = 14;

  static const Color backgroundColor = Color(0xFF0E141B);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentCyan = Color(0xFF26A69A);
  static const Color softText = Color(0xFFB6C2CF);

  static const List<String> dietTypes = ['veg', 'non_veg'];
  static const List<String> dietaryRestrictions = [
    'none',
    'lactose_intolerance',
    'nut_allergy',
    'gluten_intolerance',
    'egg_allergy',
    'soy_allergy',
    'shellfish_allergy',
  ];
  static const List<String> goals = ['muscle', 'fat_loss', 'maintenance'];
  static const List<String> fitnessLevels = [
    'beginner',
    'intermediate',
    'advanced',
  ];
  static const List<String> activityLevels = ['low', 'moderate', 'high'];
  static const List<String> dietQualityLevels = ['poor', 'average', 'good'];
}
