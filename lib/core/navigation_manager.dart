import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_starter/router/app_router.dart';

/// NavigationManager handles all app navigation logic
class NavigationManager {
  // Singleton pattern
  static final NavigationManager _instance = NavigationManager._internal();
  factory NavigationManager() => _instance;
  NavigationManager._internal();

  /// Navigate to main navigation screen with bottom tabs
  void navigateToMainNavigation(BuildContext context) {
    if (!_isValidContext(context)) return;
    
    final router = GoRouter.of(context);
    final currentPath = router.routeInformationProvider.value.uri.path;

    // Only navigate if not already on the main navigation path
    if (currentPath != AppRouter.mainNavPath) {
      debugPrint('Navigating to main navigation screen');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.go(AppRouter.mainNavPath);
      });
    } else {
      debugPrint('Already on main navigation path, skipping navigation');
    }
  }

  /// Navigate to authenticated screen (legacy method, now redirects to main nav)
  void navigateToAuthenticatedScreen(BuildContext context) {
    navigateToMainNavigation(context);
  }
  
  /// Check if context is valid for navigation
  bool _isValidContext(BuildContext? context) {
    if (context == null) return false;
    
    try {
      return context.mounted;
    } catch (e) {
      return false;
    }
  }
}

// Global instance for easy access
final navigationManager = NavigationManager();
