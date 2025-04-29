import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_starter/config/env_config.dart';
import 'package:flutter_starter/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:privy_flutter/privy_flutter.dart';

/// A singleton class to manage the Privy initialization and instance
class PrivyManager {
  // Private constructor
  PrivyManager._();

  // Singleton instance
  static final PrivyManager _instance = PrivyManager._();

  // Factory constructor to return the singleton instance
  factory PrivyManager() => _instance;

  // Reference to the Privy SDK instance
  Privy? _privySdk;
  
  // Authentication state listener
  StreamSubscription<AuthState>? _authSubscription;

  /// Getter to access the initialized Privy instance
  /// Throws an exception if accessed before initialization
   Privy get privy {
    if (_instance._privySdk == null) {
      throw Exception(
        'PrivyManager has not been initialized. Call initialize() first.',
      );
    }
    return _instance._privySdk!;
  }

  /// Whether the Privy SDK has been initialized
  bool get isInitialized => _privySdk != null;
  
  /// Initialize Privy with the credentials from env config
  void initializePrivy() {
    try {
      final privyConfig = PrivyConfig(
        appId: EnvConfig.privyAppId,
        appClientId: EnvConfig.privyClientId,
        logLevel: PrivyLogLevel.debug,
      );

      _privySdk = Privy.init(config: privyConfig);
      debugPrint('Privy SDK initialized');
    } catch (e, stack) {
      debugPrint('Privy initialization failed: $e\n$stack');
      rethrow;
    }
  }
  
  /// Set up auth state listener that handles navigation when the user is authenticated
  void setupAuthListenerAndNavigate(BuildContext context) {
    if (!isInitialized) return;
    
    // Store navigation references to avoid context usage in the callback
    final navigator = Navigator.of(context);
    final goRouter = GoRouter.of(context);
    
    // Cancel any existing subscription
    _authSubscription?.cancel();
    
    // Subscribe to auth state changes
    _authSubscription = privy.authStateStream.listen((state) {
      debugPrint('Auth state changed: $state');
      
      if (state is Authenticated) {
        debugPrint('User authenticated: ${state.user.id}');
        // Navigate to authenticated screen on login
        _navigateToAuthScreen(navigator, goRouter);
      }
    });
  }
  
  /// Helper to navigate to authenticated screen
  void _navigateToAuthScreen(NavigatorState navigator, GoRouter router) {
    final currentPath = router.routeInformationProvider.value.uri.path;
    
    // Only navigate if not already on the authenticated path
    if (currentPath != AppRouter.authenticatedPath) {
      debugPrint('Navigating to authenticated screen');
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.go(AppRouter.authenticatedPath);
      });
    } else {
      debugPrint('Already on authenticated path, skipping navigation');
    }
  }
}

/// Convenient singleton accessor for Privy Manger instance
PrivyManager get privyManager => PrivyManager();
