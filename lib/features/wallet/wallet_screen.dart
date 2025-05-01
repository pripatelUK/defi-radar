import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:privy_flutter/privy_flutter.dart';

class WalletScreen extends StatelessWidget {
  final EmbeddedEthereumWallet? ethereumWallet;
  final EmbeddedSolanaWallet? solanaWallet;

  const WalletScreen({
    super.key,
    this.ethereumWallet,
    this.solanaWallet,
  }); 

  @override
  Widget build(BuildContext context) {
    // Determine wallet type and details from constructor arguments
    final bool isEthereum = ethereumWallet != null;
    final walletDetails = isEthereum ? ethereumWallet! : solanaWallet!;
    final String walletType = isEthereum ? 'Ethereum' : 'Solana';
    final String address = walletDetails.address;
    final String? recoveryMethod = walletDetails.recoveryMethod;
    final int hdWalletIndex = walletDetails.hdWalletIndex;
    final String? chainId = walletDetails.chainId;

    return Scaffold(
      appBar: AppBar(
        title: Text('$walletType Wallet Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Use canPop to avoid issues if this is the first screen
          onPressed: () => context.canPop() ? context.pop() : context.go('/profile'), 
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 28), 
                    const SizedBox(width: 12),
                    Text(
                      '$walletType Wallet',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(),
                const SizedBox(height: 20),
                
                _buildDetailItem(context, 'Address', address),
                
                // Display chainId if available
                if (chainId != null && chainId.isNotEmpty)
                  _buildDetailItem(context, 'Chain ID', chainId),
                
                if (recoveryMethod != null && recoveryMethod.isNotEmpty)
                    _buildDetailItem(context, 'Recovery Method', recoveryMethod),
                
                // Always show HD index as it's non-nullable
                _buildDetailItem(context, 'HD Wallet Index', hdWalletIndex.toString()),
                
                const SizedBox(height: 24),
                Center(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.copy),
                    label: const Text('Copy Address'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: address));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address copied to clipboard!')), 
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value, 
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
