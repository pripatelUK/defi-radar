import 'package:flutter/material.dart';
import 'package:flutter_starter/core/app_colors.dart';
import 'package:privy_flutter/privy_flutter.dart';

/// Widget that displays all linked accounts for a Privy user
class LinkedAccountsWidget extends StatelessWidget {
  final PrivyUser user;

  const LinkedAccountsWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    if (user.linkedAccounts.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...user.linkedAccounts.map((account) => _buildAccountTile(context, account)),
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
            Icons.link_off,
            size: 48,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.secondarySpacing),
          Text(
            "No linked accounts",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.tightSpacing),
          Text(
            "Connect external accounts to enhance your profile",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(BuildContext context, LinkedAccounts account) {
    if (account is EmailAccount) {
      return _buildAccountItem(
        context,
        icon: Icons.email,
        title: "Email Account",
        subtitle: account.emailAddress,
      );
    } else if (account is EmbeddedEthereumWalletAccount || 
               account is EmbeddedSolanaWalletAccount) {
      // Skip wallet accounts as they'll be shown in their own section
      return const SizedBox.shrink();
    } else {
      // Generic account tile for other account types
      return _buildAccountItem(
        context,
        icon: Icons.account_circle,
        title: "${account.type.toUpperCase()} Account",
        subtitle: null,
      );
    }
  }

  Widget _buildAccountItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.tightSpacing),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.tightSpacing),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.smallRadius),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.secondarySpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
