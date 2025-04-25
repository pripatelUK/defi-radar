import 'package:flutter/material.dart';
import 'package:flutter_starter/core/privy_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:privy_flutter/privy_flutter.dart';

import 'package:flutter_starter/router/app_router.dart';
import 'package:flutter_starter/features/authenticated/widgets/ethereum_wallets_widget.dart';
import 'package:flutter_starter/features/authenticated/widgets/linked_accounts_widget.dart';
import 'package:flutter_starter/features/authenticated/widgets/solana_wallets_widget.dart';
import 'package:flutter_starter/features/authenticated/widgets/user_profile_widget.dart';

class AuthenticatedScreen extends StatefulWidget {
  const AuthenticatedScreen({super.key});

  @override
  State<AuthenticatedScreen> createState() => _AuthenticatedScreenState();
}

class _AuthenticatedScreenState extends State<AuthenticatedScreen> {
  final _privyManager = privyManager;
  late PrivyUser _user;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  // Get the current authenticated user
  void _fetchUser() {
    _user = _privyManager.privy.user!;
  }

  // Show snackbar message
  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Handle back navigation with logout
  Future<void> _handleBackNavigation() async {
    try {
      await _privyManager.privy.logout();

      if (mounted) {
        // Navigate back to home after logout
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        _showMessage("Logout error: $e", isError: true);
      }
    }
  }

  // Logout
  Future<void> _logout() async {
    try {
      await _privyManager.privy.logout();

      if (mounted) {
        // Navigate back to home after logout
        context.go('/');
      }
    } catch (e) {
      _showMessage("Logout error: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackNavigation,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Profile Information
              UserProfileWidget(user: _user),
              const Divider(),
              const SizedBox(height: 16),

              // Linked Accounts
              LinkedAccountsWidget(user: _user),

              const SizedBox(height: 16),

              // Ethereum Wallets
              GestureDetector(
                onTap: () => context.go(AppRouter.walletPath),
                child: EthereumWalletsWidget(user: _user),
              ),

              const SizedBox(height: 24),

              // Solana Wallets
              GestureDetector(
                onTap: () => context.go(AppRouter.walletPath),
                child: SolanaWalletsWidget(user: _user),
              ),

              const SizedBox(height: 24),

              // Logout Button
              ElevatedButton(onPressed: _logout, child: const Text('Logout')),
            ],
          ),
        ),
      ),
    );
  }
}
