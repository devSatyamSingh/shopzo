import 'package:flutter/material.dart';

class ColorConstant {
  ColorConstant._();

  /// ---------------- BRAND COLORS ----------------
  static const Color primaryColor = Color(0xFF4F46E5); // "Shop"
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFFEEF0FF);

  static const Color orangeColor = Color(0xFFF97316); // "zo" accent
  static const Color orangeDark = Color(0xFFC2410C);
  static const Color orangeLight = Color(0xFFFFF1E6);

  /// ---------------- NEUTRAL / TEXT ----------------
  static const Color headlineTextColor = Color(0xFF111827);
  static const Color bodyTextColor = Color(0xFF374151);
  static const Color labelTextColor = Color(0xFF6B7280);
  static const Color placeholderColor = Color(0xFF9CA3AF);

  /// ---------------- BASE ----------------
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);
  static const Color scaffoldBgColor = Color(0xFFF9FAFB);
  static const Color cardBgColor = Color(0xFFFFFFFF);
  static const Color fieldFillColor = Color(0xFFF3F4F6);

  /// ---------------- BORDERS / DIVIDERS ----------------
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color dividerColor = Color(0xFFE5E7EB);

  /// ---------------- STATUS COLORS ----------------
  static const Color successColor = Color(0xFF16A34A);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);

  /// ---------------- MISC ----------------
  static const Color ratingStarColor = Color(0xFFFBBF24);
  static const Color discountBadgeColor = Color(0xFFEF4444);
  static const Color wishlistColor = Color(0xFFEF4444);

  /// ---------------- GRADIENTS ----------------
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Brand gradient — used on splash / hero banners (Shop -> zo colors)
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primaryColor, orangeColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [orangeColor, orangeDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
