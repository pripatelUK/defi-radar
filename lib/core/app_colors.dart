import 'package:flutter/material.dart';

/// App color constants based on Zuma's design system
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF1976D2); // Colors.blue.shade700
  static const Color primaryLight = Color(0xFF42A5F5); // Colors.blue.shade400
  static const Color primaryDark = Color(0xFF1565C0); // Colors.blue.shade800

  // Category Colors (from Zuma's categorization system)
  static const Color aiBlue = Color(0xFF1976D2); // Colors.blue.shade700
  static const Color blockchainOrange = Color(0xFFE65100); // Colors.orange.shade700
  static const Color artPurple = Color(0xFF6A1B9A); // Colors.purple.shade700
  static const Color climateGreen = Color(0xFF388E3C); // Colors.green.shade700

  // Surface Colors
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color background = Colors.white;

  // Text Colors
  static const Color onPrimary = Colors.white;
  static const Color onSurface = Colors.black87;
  static const Color onBackground = Colors.black87;
  static const Color onSurfaceVariant = Colors.black54;

  // Semantic Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Card and Component Colors
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x1A000000); // Colors.black.withOpacity(0.1)
}

/// App spacing constants based on Zuma's design system
class AppSpacing {
  AppSpacing._();

  static const double mainSpacing = 16.0;
  static const double secondarySpacing = 12.0;
  static const double tightSpacing = 8.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
}

/// App radius constants based on Zuma's design system
class AppRadius {
  AppRadius._();

  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;
  static const double smallRadius = 4.0;
}

/// App shadow constants based on Zuma's design system
class AppShadows {
  AppShadows._();

  static const BoxShadow cardShadow = BoxShadow(
    color: AppColors.cardShadow,
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const List<BoxShadow> cardShadows = [cardShadow];
} 