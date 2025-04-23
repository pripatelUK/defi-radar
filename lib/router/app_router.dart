import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/authenticated/authenticated_screen.dart';
import '../features/email_authentication/email_authentication_screen.dart';
import '../features/wallet/wallet_screen.dart';

class AppRouter {
  // Private constructor to prevent direct instantiation
  AppRouter._();

  // Static instance for singleton access
  static final AppRouter _instance = AppRouter._();

  // Factory constructor to return the singleton instance
  factory AppRouter() => _instance;

  // Route name constants
  static const String authenticatedRoute = 'authenticated';
  static const String walletRoute = 'wallet';
  static const String emailAuthRoute = 'email-auth';

  // Route path constants
  static const String authenticatedPath = '/profile';
  static const String walletPath = '/wallet';
  static const String emailAuthPath = '/email-auth';

  // GoRouter configuration
  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: emailAuthPath,
    routes: [
      // Main routes
      GoRoute(
        path: authenticatedPath,
        name: authenticatedRoute,
        builder: (context, state) => const AuthenticatedScreen(),
      ),
      GoRoute(
        path: walletPath,
        name: walletRoute,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: emailAuthPath,
        name: emailAuthRoute,
        builder: (context, state) => const EmailAuthenticationScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('No route defined for ${state.uri.path}'),
      ),
    ),
  );
}
