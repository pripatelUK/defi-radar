import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_starter/router/app_router.dart';
import 'package:flutter_starter/core/app_colors.dart';

Future<void> main() async {

  // Load environment variables before running the app
  await dotenv.load(fileName: '.env');
  
  runApp(const MyPrivyStarterApp());
}

class MyPrivyStarterApp extends StatelessWidget {
  const MyPrivyStarterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Privy Starter Repo",
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter().router,
      theme: ThemeData(
        // Use Material 3 design system
        useMaterial3: true,
        
        // Color scheme based on Zuma's design system
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.light(
          // Primary colors
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryLight,
          // Surface colors
          surface: AppColors.surface,
          surfaceVariant: AppColors.surfaceVariant,
          background: AppColors.background,
          // Text colors
          onPrimary: AppColors.onPrimary,
          onSurface: AppColors.onSurface,
          onBackground: AppColors.onBackground,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          // Semantic colors
          error: AppColors.error,
        ),
        
        // AppBar theme - matching Zuma's style
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.onBackground,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.onBackground,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        // Card theme - matching Zuma's card styling
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 2,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.cardRadius),
          ),
        ),
        
        // Button themes - matching Zuma's button styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 2,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.mainSpacing,
              vertical: AppSpacing.secondarySpacing,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Typography - matching Zuma's text styles
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: AppColors.onBackground,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: AppColors.onBackground,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            color: AppColors.onBackground,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: AppColors.onBackground,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: TextStyle(
            color: AppColors.onBackground,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          bodySmall: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
