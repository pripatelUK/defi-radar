import 'package:flutter/material.dart';
import 'package:flutter_starter/core/privy_manager.dart';
import 'package:flutter_starter/core/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:privy_flutter/privy_flutter.dart';

import 'package:flutter_starter/features/authenticated/widgets/ethereum_wallets_widget.dart';
import 'package:flutter_starter/features/authenticated/widgets/linked_accounts_widget.dart';
import 'package:flutter_starter/features/authenticated/widgets/solana_wallets_widget.dart';
import 'package:flutter_starter/features/authenticated/widgets/user_profile_widget.dart';
import 'package:flutter_starter/router/app_router.dart';

class AuthenticatedScreen extends StatefulWidget {
  const AuthenticatedScreen({super.key});

  @override
  State<AuthenticatedScreen> createState() => _AuthenticatedScreenState();
}

class _AuthenticatedScreenState extends State<AuthenticatedScreen> {
  final _privyManager = privyManager;
  late PrivyUser _user;

  // Track loading states
  bool _isCreatingEthereumWallet = false;
  bool _isCreatingSolanaWallet = false;

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
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
        ),
      ),
    );
  }

  // Create Ethereum wallet
  Future<void> _createEthereumWallet() async {
    setState(() {
      _isCreatingEthereumWallet = true;
    });

    try {
      final result = await _user.createEthereumWallet(allowAdditional: true);

      result.fold(
        onSuccess: (wallet) {
          _showMessage("Ethereum wallet created: ${wallet.address}");
          // Refresh user to update the wallet list
          setState(() {
            _isCreatingEthereumWallet = false;
          });
        },
        onFailure: (error) {
          setState(() {
            _isCreatingEthereumWallet = false;
          });
          _showMessage(
            "Error creating wallet: ${error.message}",
            isError: true,
          );
        },
      );
    } catch (e) {
      setState(() {
        _isCreatingEthereumWallet = false;
      });
      _showMessage("Unexpected error: $e", isError: true);
    }
  }

  // Create Solana wallet
  Future<void> _createSolanaWallet() async {
    setState(() {
      _isCreatingSolanaWallet = true;
    });

    try {
      final result = await _user.createSolanaWallet();

      result.fold(
        onSuccess: (wallet) {
          _showMessage("Solana wallet created: ${wallet.address}");
          // Refresh user to update the wallet list
          setState(() {
            _isCreatingSolanaWallet = false;
          });
        },
        onFailure: (error) {
          setState(() {
            _isCreatingSolanaWallet = false;
          });
          _showMessage(
            "Error creating wallet: ${error.message}",
            isError: true,
          );
        },
      );
    } catch (e) {
      setState(() {
        _isCreatingSolanaWallet = false;
      });
      _showMessage("Unexpected error: $e", isError: true);
    }
  }

  // Logout
  Future<void> _logout() async {
    try {
      await _privyManager.privy.logout();

      if (mounted) {
        // Navigate back to main navigation after logout
        context.go(AppRouter.mainNavPath);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.mainSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome message
              _buildWelcomeCard(),
              
              const SizedBox(height: AppSpacing.mainSpacing),

              // User Profile Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Text(
                            'Profile Information',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      UserProfileWidget(user: _user),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.mainSpacing),

              // Linked Accounts
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.link,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Text(
                            'Linked Accounts',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      LinkedAccountsWidget(user: _user),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.mainSpacing),

              // Ethereum Wallets
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Text(
                            'Ethereum Wallets',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      EthereumWalletsWidget(user: _user),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.mainSpacing),

              // Solana Wallets
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.currency_bitcoin,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Text(
                            'Solana Wallets',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      SolanaWalletsWidget(user: _user),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.extraLargeSpacing),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.largeSpacing),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.secondarySpacing),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.cardRadius),
              ),
              child: Icon(
                Icons.verified_user,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.mainSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.tightSpacing),
                  Text(
                    'You are successfully authenticated. Manage your wallets and accounts below.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Ethereum wallet creation button
        FloatingActionButton.extended(
          heroTag: "createEthereum",
          onPressed: (_isCreatingEthereumWallet || _isCreatingSolanaWallet)
              ? null
              : _createEthereumWallet,
          backgroundColor: (_isCreatingEthereumWallet || _isCreatingSolanaWallet)
              ? AppColors.onSurfaceVariant
              : AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          icon: _isCreatingEthereumWallet
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add),
          label: const Text('Create ETH Wallet'),
        ),
        const SizedBox(height: AppSpacing.tightSpacing),
        
        // Solana wallet creation button
        FloatingActionButton.extended(
          heroTag: "createSolana",
          onPressed: (_isCreatingSolanaWallet || _isCreatingEthereumWallet)
              ? null
              : _createSolanaWallet,
          backgroundColor: (_isCreatingSolanaWallet || _isCreatingEthereumWallet)
              ? AppColors.onSurfaceVariant
              : AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          icon: _isCreatingSolanaWallet
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add),
          label: const Text('Create SOL Wallet'),
        ),
      ],
    );
  }
}
