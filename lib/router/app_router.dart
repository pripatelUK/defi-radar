import 'package:flutter/material.dart';
// import 'package:flutter_starter/core/privy_manager.dart'; // Removed unused import
import 'package:flutter_starter/features/authenticated/authenticated_screen.dart';
import 'package:flutter_starter/features/email_authentication/email_authentication_screen.dart';
import 'package:flutter_starter/features/wallet/eth_wallet_screen.dart';
import 'package:flutter_starter/features/wallet/solana_wallet_screen.dart';
import 'package:flutter_starter/core/bottom_navbar.dart';
import 'package:go_router/go_router.dart';
import 'package:privy_flutter/privy_flutter.dart';

class AppRouter {
  // Private constructor to prevent direct instantiation
  AppRouter._();

  // Static instance for singleton access
  static final AppRouter _instance = AppRouter._();

  // Factory constructor to return the singleton instance
  factory AppRouter() => _instance;

  // Route name constants
  static const String homeRoute = 'home';
  static const String authenticatedRoute = 'authenticated';
  static const String emailAuthRoute = 'email-auth';
  static const String ethWalletRoute = 'eth-wallet';
  static const String solanaWalletRoute = 'solana-wallet';
  static const String mainNavRoute = 'main-nav';

  // Route path constants
  static const String homePath = '/';
  static const String emailAuthPath = '/email-auth';
  static const String authenticatedPath = '/profile';
  static const String ethWalletPath = '/eth-wallet';
  static const String solanaWalletPath = '/solana-wallet';
  static const String mainNavPath = '/main';

  // GoRouter configuration
  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: mainNavPath, // Start with bottom navigation
    routes: [
      // Main navigation with bottom tabs (primary route)
      GoRoute(
        path: mainNavPath,
        name: mainNavRoute,
        builder: (context, state) => const BottomNavBar(),
      ),
      // Redirect home path to main navigation
      GoRoute(
        path: homePath,
        name: homeRoute,
        redirect: (context, state) => mainNavPath,
      ),
      GoRoute(
        path: authenticatedPath,
        name: authenticatedRoute,
        builder: (context, state) {
          // final user = state.extra as PrivyUser?;
          return AuthenticatedScreen();
        },
      ),
      GoRoute(
        path: emailAuthPath,
        name: emailAuthRoute,
        builder: (context, state) => const EmailAuthenticationScreen(),
      ),
      GoRoute(
        path: ethWalletPath,
        name: ethWalletRoute,
        builder: (context, state) {
          final wallet = state.extra as EmbeddedEthereumWallet;
          return EthWalletScreen(ethereumWallet: wallet);
        },
      ),
      GoRoute(
        path: solanaWalletPath,
        name: solanaWalletRoute,
        builder: (context, state) {
          final wallet = state.extra as EmbeddedSolanaWallet;
          return SolanaWalletScreen(solanaWallet: wallet);
        },
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(child: Text('No route defined for ${state.uri.path}')),
        ),
  );
}
