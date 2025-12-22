import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF6A0DAD);
  static const Color lightBlue = Color(0xFFADD8E6);

  static const Color purple50 = Color(0xFFF3E5F5);
  static const Color purple100 = Color(0xFFE1BEE7);
  static const Color purple600 = Color(0xFF8B5CF6);
  static const Color purple700 = Color(0xFF7E22CE);

  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);

  static LinearGradient get backgroundGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple50, Color(0xFFE0F2FE)],
  );

  static LinearGradient get buttonGradient => const LinearGradient(
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0),
    colors: [primaryPurple, purple600],
  );

  static LinearGradient get purpleCardGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple100, purple50],
  );

  static LinearGradient get blueCardGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue100, blue50],
  );
}