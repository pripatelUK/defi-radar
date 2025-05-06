import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:privy_flutter/privy_flutter.dart';
import 'package:convert/convert.dart'; // Re-added for hex encoding

class WalletScreen extends StatefulWidget {
  final EmbeddedEthereumWallet? ethereumWallet;
  final EmbeddedSolanaWallet? solanaWallet;

  const WalletScreen({super.key, this.ethereumWallet, this.solanaWallet});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // Controller for the message input field
  final TextEditingController _messageController = TextEditingController();
  // State variable to hold the latest signature
  String? _latestSignature;

  // Listener function to trigger rebuilds
  void _onMessageChanged() {
    setState(() {}); // Trigger rebuild to update button state
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

  // Helper function to copy signature
  void _copySignatureToClipboard() {
    if (_latestSignature != null && _latestSignature!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _latestSignature!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signature copied to clipboard!')),
      );
    }
  }

  // Method to sign an Ethereum message
  Future<void> _signEthereumMessage() async {
    final ethereumWallet = widget.ethereumWallet;
    final messageToSign =
        _messageController.text.trim(); // Get message from controller

    if (ethereumWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No Ethereum wallet found."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if message is empty
    if (messageToSign.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a message to sign."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Encode the user's message
    final messageBytes = utf8.encode(messageToSign);
    // Hex encode the message bytes for personal_sign
    final String hexMessage = '0x${hex.encode(messageBytes)}';

    // Create the RPC request object for personal_sign
    final rpcRequest = EthereumRpcRequest(
      method: "personal_sign",
      params: [hexMessage, ethereumWallet.address],
    );

    // Call request method on the provider
    final result = await ethereumWallet.provider.request(rpcRequest);

    // Handle the Result<EthereumRpcResponse>
    result.fold(
      onSuccess: (response) {
        final signature = response.data.toString();
        // Update state with the new signature
        setState(() {
          _latestSignature = signature;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ETH Signature: $signature"),
            backgroundColor: Colors.green,
          ),
        );
      },
      onFailure: (error) {
        // Clear previous signature on error
        setState(() {
          _latestSignature = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error signing ETH message: ${error.message}"),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  // Method to sign a Solana message
  Future<void> _signSolanaMessage() async {
    final solanaWallet = widget.solanaWallet;
    final messageToSign =
        _messageController.text.trim(); // Get message from controller

    if (solanaWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No Solana wallet found."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if message is empty
    if (messageToSign.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a message to sign."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Convert the user's message to Base64 encoded message for Solana
    final String base64Message = base64Encode(utf8.encode(messageToSign));

    // Call the signMessage function, which returns a `Result<String>`
    final result = await solanaWallet.provider.signMessage(base64Message);

    // Handle the result using `.fold()`
    result.fold(
      onSuccess: (signature) {
        // Update state with the new signature
        setState(() {
          _latestSignature = signature;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("SOL Signature: $signature"),
            backgroundColor: Colors.green,
          ),
        );
      },
      onFailure: (error) {
        // Clear previous signature on error
        setState(() {
          _latestSignature = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error signing SOL message: ${error.message}"),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine wallet type and details from widget properties
    final bool isEthereum = widget.ethereumWallet != null;
    final walletDetails =
        isEthereum ? widget.ethereumWallet! : widget.solanaWallet!;
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
          onPressed:
              () => context.canPop() ? context.pop() : context.go('/profile'),
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
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
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
                _buildDetailItem(
                  context,
                  'HD Wallet Index',
                  hdWalletIndex.toString(),
                ),
                const SizedBox(height: 24),
                // Message Input Field
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message to Sign',
                    hintText: 'Enter the message here',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: Icon(Icons.copy),
                      label: const Text('Copy Wallet Address'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: address));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Address copied to clipboard!'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: Icon(Icons.edit),
                      label: const Text('Sign Message'),
                      // Disable button if message is empty
                      onPressed:
                          _messageController.text.trim().isEmpty
                              ? null
                              : (isEthereum
                                  ? _signEthereumMessage
                                  : _signSolanaMessage),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Display Latest Signature Section
                if (_latestSignature != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Latest Signature:',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _copySignatureToClipboard,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                  _latestSignature!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'monospace',
                                  ), // Monospace for signature
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.copy,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
