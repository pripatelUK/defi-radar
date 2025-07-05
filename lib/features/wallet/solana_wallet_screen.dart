import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter/core/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:privy_flutter/privy_flutter.dart';

// Displays wallet details and provides actions for a Solana wallet.
class SolanaWalletScreen extends StatefulWidget {
  final EmbeddedSolanaWallet solanaWallet;

  const SolanaWalletScreen({super.key, required this.solanaWallet});

  @override
  State<SolanaWalletScreen> createState() => _SolanaWalletScreenState();
}

class _SolanaWalletScreenState extends State<SolanaWalletScreen> {
  // Controller for the message input TextField.
  final TextEditingController _messageController = TextEditingController();
  // Stores the latest signature generated.
  String? _latestSignature;

  // Updates the UI when the message input changes, to enable/disable the sign button.
  void _onMessageChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onMessageChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
    _messageController.dispose();
    super.dispose();
  }

  // Copies the latest signature to the clipboard and shows a SnackBar.
  void _copySignatureToClipboard() {
    if (_latestSignature != null && _latestSignature!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _latestSignature!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signature copied to clipboard!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
          ),
        ),
      );
    }
  }

  // Signs the message entered by the user using the Solana wallet.
  Future<void> _signSolanaMessage() async {
    // solanaWallet is non-nullable from widget.solanaWallet
    final messageToSign = _messageController.text.trim();

    // Check if message is empty.
    if (messageToSign.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a message to sign."),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
          ),
        ),
      );
      return;
    }

    // Solana's signMessage expects a Base64 encoded string.
    final String base64Message = base64Encode(utf8.encode(messageToSign));
    final result = await widget.solanaWallet.provider.signMessage(base64Message);

    // Handle the result (success or failure) from the signMessage call.
    result.fold(
      onSuccess: (signature) {
        setState(() {
          _latestSignature = signature;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("SOL Signature: $signature"),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
            ),
          ),
        );
      },
      onFailure: (error) {
        setState(() {
          _latestSignature = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error signing SOL message: ${error.message}"),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
            ),
          ),
        );
      },
    );
  }

  @override
  // Builds the UI for the Solana Wallet screen.
  Widget build(BuildContext context) {
    const String walletType = 'Solana';
    final String address = widget.solanaWallet.address;
    final String? recoveryMethod = widget.solanaWallet.recoveryMethod;
    final int hdWalletIndex = widget.solanaWallet.hdWalletIndex;
    final String? chainId = widget.solanaWallet.chainId;

    return Scaffold(
      appBar: AppBar(
        title: Text('$walletType Wallet Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.mainSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Wallet Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.largeSpacing),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.secondarySpacing),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.cardRadius),
                            ),
                            child: Icon(
                              Icons.currency_bitcoin,
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
                                  '$walletType Wallet',
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: AppSpacing.tightSpacing),
                                Text(
                                  'Manage your wallet and sign messages',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.mainSpacing),

              // Wallet Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Text(
                            'Wallet Details',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      
                      // Wallet details
                      _buildDetailItem(context, 'Address', address),
                      if (chainId != null && chainId.isNotEmpty)
                        _buildDetailItem(context, 'Chain ID', chainId),
                      if (recoveryMethod != null && recoveryMethod.isNotEmpty)
                        _buildDetailItem(context, 'Recovery Method', recoveryMethod),
                      _buildDetailItem(
                        context,
                        'HD Wallet Index',
                        hdWalletIndex.toString(),
                      ),
                      
                      const SizedBox(height: AppSpacing.mainSpacing),
                      
                      // Copy Address Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Wallet Address'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: address));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Address copied to clipboard!'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.mainSpacing,
                              vertical: AppSpacing.secondarySpacing,
                            ),
                            side: BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.mainSpacing),

              // Message Signing Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Text(
                            'Message Signing',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      
                      TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          labelText: 'Message to Sign',
                          hintText: 'Enter the message here',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                        ),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Sign Message'),
                          onPressed: _messageController.text.trim().isEmpty
                              ? null
                              : _signSolanaMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Latest Signature Card
              if (_latestSignature != null) ...[
                const SizedBox(height: AppSpacing.mainSpacing),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.verified,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.tightSpacing),
                            Text(
                              'Latest Signature',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.mainSpacing),
                        
                        GestureDetector(
                          onTap: _copySignatureToClipboard,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.secondarySpacing),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
                              border: Border.all(color: AppColors.onSurfaceVariant.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    _latestSignature!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.tightSpacing),
                                Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.extraLargeSpacing),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build a display item for wallet details (label and value).
  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.tightSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
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
