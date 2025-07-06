import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:privy_flutter/privy_flutter.dart';
import 'package:flutter_starter/core/models/employee.dart';
import 'package:flutter_starter/core/privy_manager.dart';
import 'package:convert/convert.dart';

/// Service for blockchain operations related to payroll processing
class BlockchainService {
  // Contract addresses
  static const String _disperseContractAddress = '0xd152f549545093347a162dce210e7293f1452150';
  static const String _usdcTokenAddress = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48';
  static const String _rpcUrl = 'https://virtual.mainnet.rpc.tenderly.co/0c0f39b1-4fd9-4613-b243-3ac22ee83f6d';
  
  // Web3 client
  late final Web3Client _web3Client;
  
  // Contract instances
  late final DeployedContract _disperseContract;
  late final DeployedContract _usdcContract;
  
  // Contract functions
  late final ContractFunction _disperseTokenFunction;
  late final ContractFunction _balanceOfFunction;
  late final ContractFunction _allowanceFunction;
  
  // Singleton instance
  static final BlockchainService _instance = BlockchainService._internal();
  factory BlockchainService() => _instance;
  BlockchainService._internal();
  
  /// Initialize the blockchain service
  Future<void> initialize() async {
    try {
      // Initialize Web3 client
      _web3Client = Web3Client(_rpcUrl, http.Client());
      
      // Load contract ABIs
      final disperseAbi = await _loadDisperseAbi();
      final usdcAbi = await _loadUsdcAbi();
      
      // Create contract instances
      _disperseContract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(disperseAbi), 'Disperse'),
        EthereumAddress.fromHex(_disperseContractAddress),
      );
      
      _usdcContract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(usdcAbi), 'USDC'),
        EthereumAddress.fromHex(_usdcTokenAddress),
      );
      
      // Get contract functions
      _disperseTokenFunction = _disperseContract.function('disperseToken');
      _balanceOfFunction = _usdcContract.function('balanceOf');
      _allowanceFunction = _usdcContract.function('allowance');
      
      debugPrint('BlockchainService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing BlockchainService: $e');
      rethrow;
    }
  }
  
  /// Load disperse contract ABI from assets
  Future<List<dynamic>> _loadDisperseAbi() async {
    try {
      final String abiString = await rootBundle.loadString('lib/core/abi.json');
      return jsonDecode(abiString) as List<dynamic>;
    } catch (e) {
      debugPrint('Error loading disperse ABI: $e');
      rethrow;
    }
  }
  
  /// Load USDC contract ABI (minimal for our needs)
  Future<List<dynamic>> _loadUsdcAbi() async {
    // Minimal USDC ABI for balance, allowance, and approve functions
    return [
      {
        "constant": true,
        "inputs": [{"name": "owner", "type": "address"}],
        "name": "balanceOf",
        "outputs": [{"name": "", "type": "uint256"}],
        "type": "function"
      },
      {
        "constant": true,
        "inputs": [
          {"name": "owner", "type": "address"},
          {"name": "spender", "type": "address"}
        ],
        "name": "allowance",
        "outputs": [{"name": "", "type": "uint256"}],
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {"name": "spender", "type": "address"},
          {"name": "amount", "type": "uint256"}
        ],
        "name": "approve",
        "outputs": [{"name": "", "type": "bool"}],
        "type": "function"
      }
    ];
  }
  
  /// Get USDC balance for an address
  Future<BigInt> getUsdcBalance(String address) async {
    try {
      final result = await _web3Client.call(
        contract: _usdcContract,
        function: _balanceOfFunction,
        params: [EthereumAddress.fromHex(address)],
      );
      return result.first as BigInt;
    } catch (e) {
      debugPrint('Error getting USDC balance: $e');
      rethrow;
    }
  }
  
  /// Get USDC allowance for disperse contract
  Future<BigInt> getUsdcAllowance(String ownerAddress) async {
    try {
      final result = await _web3Client.call(
        contract: _usdcContract,
        function: _allowanceFunction,
        params: [
          EthereumAddress.fromHex(ownerAddress),
          EthereumAddress.fromHex(_disperseContractAddress),
        ],
      );
      return result.first as BigInt;
    } catch (e) {
      debugPrint('Error getting USDC allowance: $e');
      rethrow;
    }
  }
  
  /// Validate payroll batch before processing
  Future<PayrollValidationResult> validatePayrollBatch(
    PayrollBatch batch,
    String userWalletAddress,
  ) async {
    try {
      final errors = <String>[];
      
      // Check user's USDC balance
      final userBalance = await getUsdcBalance(userWalletAddress);
      if (userBalance < batch.totalAmountInWei) {
        errors.add('Insufficient USDC balance. Required: ${batch.totalAmountFormatted}, Available: \$${(userBalance / BigInt.from(1000000))}');
      }
      
      // Check USDC allowance
      final allowance = await getUsdcAllowance(userWalletAddress);
      if (allowance < batch.totalAmountInWei) {
        errors.add('Insufficient USDC allowance for disperse contract. Please approve the required amount.');
      }
      
      // Validate recipient addresses
      for (final employee in batch.employees) {
        if (!_isValidEthereumAddress(employee.walletAddress)) {
          errors.add('Invalid wallet address for ${employee.name}: ${employee.walletAddress}');
        }
      }
      
      // Estimate gas costs
      final gasEstimate = await _estimateDisperseGas(batch, userWalletAddress);
      
      return PayrollValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        estimatedGasLimit: gasEstimate,
        totalAmountRequired: batch.totalAmountInWei,
        userBalance: userBalance,
        currentAllowance: allowance,
      );
    } catch (e) {
      debugPrint('Error validating payroll batch: $e');
      return PayrollValidationResult(
        isValid: false,
        errors: ['Validation failed: ${e.toString()}'],
        estimatedGasLimit: BigInt.zero,
        totalAmountRequired: BigInt.zero,
        userBalance: BigInt.zero,
        currentAllowance: BigInt.zero,
      );
    }
  }
  
  /// Estimate gas for disperse transaction
  Future<BigInt> _estimateDisperseGas(PayrollBatch batch, String userWalletAddress) async {
    try {
      final gasEstimate = await _web3Client.estimateGas(
        sender: EthereumAddress.fromHex(userWalletAddress),
        to: EthereumAddress.fromHex(_disperseContractAddress),
        data: _disperseTokenFunction.encodeCall([
          EthereumAddress.fromHex(_usdcTokenAddress),
          batch.recipientAddresses.map((addr) => EthereumAddress.fromHex(addr)).toList(),
          batch.amountsInWei,
        ]),
      );
      return gasEstimate;
    } catch (e) {
      debugPrint('Error estimating gas: $e');
      // Return a reasonable default if estimation fails
      return BigInt.from(300000);
    }
  }
  
  /// Process payroll batch using Privy SDK
  Future<PayrollTransactionResult> processPayrollBatch(PayrollBatch batch) async {
    try {
      // Get user's wallet from Privy
      final user = privyManager.privy.user;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final ethereumWallets = user.embeddedEthereumWallets;
      if (ethereumWallets.isEmpty) {
        throw Exception('No Ethereum wallet found');
      }
      
      final wallet = ethereumWallets.first;
      
      // Validate batch
      final validation = await validatePayrollBatch(batch, wallet.address);
      if (!validation.isValid) {
        throw Exception('Validation failed: ${validation.errors.join(', ')}');
      }
      
      // Build transaction payload for Privy
      final txPayload = await _buildPrivyTransactionPayload(batch, wallet.address);
      
      // Sign transaction using Privy
      final signRequest = EthereumRpcRequest(
        method: "eth_signTransaction",
        params: [txPayload],
      );
      
      final signResult = await wallet.provider.request(signRequest);
      
      // Use a Completer to handle the async fold result
      final completer = Completer<PayrollTransactionResult>();
      
      signResult.fold(
        onSuccess: (signResponse) async {
          try {
            final signedTransaction = signResponse.data.toString();
            
            // Send signed transaction using Privy
            final sendRequest = EthereumRpcRequest(
              method: "eth_sendRawTransaction",
              params: [signedTransaction],
            );
            
            final sendResult = await wallet.provider.request(sendRequest);
            
            sendResult.fold(
              onSuccess: (sendResponse) {
                final txHash = sendResponse.data.toString();
                completer.complete(PayrollTransactionResult(
                  success: true,
                  transactionHash: txHash,
                  message: 'Payroll processed successfully',
                ));
              },
              onFailure: (error) {
                completer.complete(PayrollTransactionResult(
                  success: false,
                  error: error.message,
                  message: 'Failed to send transaction',
                ));
              },
            );
          } catch (e) {
            completer.complete(PayrollTransactionResult(
              success: false,
              error: e.toString(),
              message: 'Error during transaction sending',
            ));
          }
        },
        onFailure: (error) {
          completer.complete(PayrollTransactionResult(
            success: false,
            error: error.message,
            message: 'Failed to sign transaction',
          ));
        },
      );
      
      return await completer.future;
    } catch (e) {
      debugPrint('Error processing payroll batch: $e');
      return PayrollTransactionResult(
        success: false,
        error: e.toString(),
        message: 'Failed to process payroll',
      );
    }
  }
  
  /// Build transaction payload in the format expected by Privy SDK
  Future<String> _buildPrivyTransactionPayload(PayrollBatch batch, String userWalletAddress) async {
    try {
      final gasPrice = await _web3Client.getGasPrice();
      final gasLimit = await _estimateDisperseGas(batch, userWalletAddress);
      
      // Encode the contract call data
      final data = _disperseTokenFunction.encodeCall([
        EthereumAddress.fromHex(_usdcTokenAddress),
        batch.recipientAddresses.map((addr) => EthereumAddress.fromHex(addr)).toList(),
        batch.amountsInWei,
      ]);
      
      // Convert Uint8List to hex string
      final dataHex = "0x${hex.encode(data)}";
      
      // Convert gasPrice to BigInt properly
      final gasPriceBigInt = gasPrice.getInWei;
      
      // Build transaction payload for Privy (JSON format)
      final txPayload = {
        "from": userWalletAddress,
        "to": _disperseContractAddress,
        "value": "0x0", // No ETH value, only contract call
        "data": dataHex,
        "chainId": "0x1", // Mainnet chain ID
        "gasLimit": "0x${gasLimit.toRadixString(16)}",
        "maxPriorityFeePerGas": "0x3B9ACA00", // 1 Gwei tip
        "maxFeePerGas": "0x${(gasPriceBigInt * BigInt.from(2)).toRadixString(16)}", // 2x gas price as max fee
      };
      
      return jsonEncode(txPayload);
    } catch (e) {
      debugPrint('Error building Privy transaction payload: $e');
      rethrow;
    }
  }
  
  /// Check if address is valid Ethereum address
  bool _isValidEthereumAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Get transaction receipt
  Future<TransactionReceipt?> getTransactionReceipt(String txHash) async {
    try {
      return await _web3Client.getTransactionReceipt(txHash);
    } catch (e) {
      debugPrint('Error getting transaction receipt: $e');
      return null;
    }
  }
  
  /// Dispose resources
  void dispose() {
    _web3Client.dispose();
  }
}

/// Result of payroll validation
class PayrollValidationResult {
  final bool isValid;
  final List<String> errors;
  final BigInt estimatedGasLimit;
  final BigInt totalAmountRequired;
  final BigInt userBalance;
  final BigInt currentAllowance;
  
  PayrollValidationResult({
    required this.isValid,
    required this.errors,
    required this.estimatedGasLimit,
    required this.totalAmountRequired,
    required this.userBalance,
    required this.currentAllowance,
  });
}

/// Result of payroll transaction
class PayrollTransactionResult {
  final bool success;
  final String? transactionHash;
  final String? error;
  final String message;
  
  PayrollTransactionResult({
    required this.success,
    this.transactionHash,
    this.error,
    required this.message,
  });
} 