import 'package:flutter/material.dart';
import 'package:flutter_starter/core/app_colors.dart';
import 'package:flutter_starter/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:privy_flutter/privy_flutter.dart';

/// Widget that displays all Ethereum wallets for a Privy user
class EthereumWalletsWidget extends StatelessWidget {
  final PrivyUser user;

  const EthereumWalletsWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.embeddedEthereumWallets.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...user.embeddedEthereumWallets.map(
          (wallet) => _buildWalletTile(context, wallet),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.largeSpacing),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.secondarySpacing),
          Text(
            "No Ethereum wallets",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.tightSpacing),
          Text(
            "Create an Ethereum wallet to get started",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletTile(BuildContext context, EmbeddedEthereumWallet wallet) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.secondarySpacing),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
          onTap: () {
            GoRouter.of(context).pushNamed(
              AppRouter.ethWalletRoute,
              extra: wallet,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.mainSpacing),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
              border: Border.all(
                color: AppColors.onSurfaceVariant.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.tightSpacing),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.smallRadius),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.secondarySpacing),
                    Expanded(
                      child: Text(
                        "Ethereum Wallet",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.secondarySpacing),
                
                _buildWalletDetail("Address", _formatAddress(wallet.address)),
                
                if (wallet.chainId != null)
                  _buildWalletDetail("Chain ID", wallet.chainId!),
                
                if (wallet.recoveryMethod != null)
                  _buildWalletDetail("Recovery Method", wallet.recoveryMethod!),
                
                _buildWalletDetail("HD Wallet Index", wallet.hdWalletIndex.toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.tightSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.secondarySpacing),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddress(String address) {
    if (address.length > 14) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 8)}';
    }
    return address;
  }
}
