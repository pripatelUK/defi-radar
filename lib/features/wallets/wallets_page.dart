import 'package:flutter/material.dart';
import 'package:flutter_starter/core/app_colors.dart';
import 'package:flutter_starter/core/privy_manager.dart';
import 'package:privy_flutter/privy_flutter.dart';

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  PrivyUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Access the user property directly from Privy
      final user = privyManager.privy.user;
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallets'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.mainSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.largeSpacing),
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      Text(
                        'Your Wallets',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.tightSpacing),
                      Text(
                        'Manage your crypto wallets and view your portfolio',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.mainSpacing),

              // Ethereum Wallets Section
              if (_user?.embeddedEthereumWallets.isNotEmpty ?? false) ...[
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
                              'Ethereum Wallets',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.mainSpacing),
                        ..._user!.embeddedEthereumWallets.map(
                          (wallet) => _buildWalletTile(
                            context,
                            'Ethereum',
                            wallet.address,
                            Icons.currency_bitcoin,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.mainSpacing),
              ],

              // Solana Wallets Section
              if (_user?.embeddedSolanaWallets.isNotEmpty ?? false) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.toll,
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
                        ..._user!.embeddedSolanaWallets.map(
                          (wallet) => _buildWalletTile(
                            context,
                            'Solana',
                            wallet.address,
                            Icons.toll,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.mainSpacing),
              ],

              // Create Wallet Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Text(
                            'Create New Wallet',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      Text(
                        'Create additional wallets for different blockchains',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _createEthereumWallet,
                              icon: const Icon(Icons.currency_bitcoin),
                              label: const Text('Ethereum'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.secondarySpacing),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _createSolanaWallet,
                              icon: const Icon(Icons.toll),
                              label: const Text('Solana'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletTile(BuildContext context, String type, String address, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.tightSpacing),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.tightSpacing),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          '$type Wallet',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Text(
          '${address.substring(0, 6)}...${address.substring(address.length - 4)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to wallet details
          _showWalletDetails(context, type, address);
        },
      ),
    );
  }

  void _showWalletDetails(BuildContext context, String type, String address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$type Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.tightSpacing),
            SelectableText(
              address,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _createEthereumWallet() async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please authenticate first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final result = await _user!.createEthereumWallet(allowAdditional: true);
      
      result.fold(
        onSuccess: (wallet) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ethereum wallet created: ${wallet.address}'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadUserData(); // Refresh user data
        },
        onFailure: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating Ethereum wallet: ${error.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating Ethereum wallet: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _createSolanaWallet() async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please authenticate first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final result = await _user!.createSolanaWallet();
      
      result.fold(
        onSuccess: (wallet) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Solana wallet created: ${wallet.address}'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadUserData(); // Refresh user data
        },
        onFailure: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating Solana wallet: ${error.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating Solana wallet: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
} 