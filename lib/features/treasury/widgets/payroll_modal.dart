import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter/core/app_colors.dart';
import 'package:flutter_starter/core/models/employee.dart';
import 'package:flutter_starter/core/services/blockchain_service.dart';
import 'package:flutter_starter/core/privy_manager.dart';

/// Modal widget for processing payroll payments
class PayrollModal extends StatefulWidget {
  final List<Employee> employees;
  
  const PayrollModal({
    super.key,
    required this.employees,
  });

  @override
  State<PayrollModal> createState() => _PayrollModalState();
}

class _PayrollModalState extends State<PayrollModal> {
  late PayrollBatch _payrollBatch;
  final BlockchainService _blockchainService = BlockchainService();
  
  // State variables
  bool _isLoading = false;
  bool _isValidating = false;
  bool _isProcessing = false;
  PayrollValidationResult? _validationResult;
  PayrollTransactionResult? _transactionResult;
  
  // UI State
  int _currentStep = 0;
  final PageController _pageController = PageController();
  
  @override
  void initState() {
    super.initState();
    _payrollBatch = PayrollBatch.fromEmployees(widget.employees);
    _initializeBlockchainService();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Initialize blockchain service
  Future<void> _initializeBlockchainService() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _blockchainService.initialize();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to initialize blockchain service: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Validate payroll batch
  Future<void> _validatePayrollBatch() async {
    setState(() {
      _isValidating = true;
    });
    
    try {
      // Get user wallet address from Privy
      final user = privyManager.privy.user;
      if (user == null || user.embeddedEthereumWallets.isEmpty) {
        throw Exception('No Ethereum wallet found');
      }
      
      final walletAddress = user.embeddedEthereumWallets.first.address;
      final validationResult = await _blockchainService.validatePayrollBatch(
        _payrollBatch,
        walletAddress,
      );
      
      setState(() {
        _validationResult = validationResult;
        _isValidating = false;
      });
      
      if (validationResult.isValid) {
        _nextStep();
      }
    } catch (e) {
      setState(() {
        _isValidating = false;
      });
      _showErrorSnackBar('Validation failed: ${e.toString()}');
    }
  }

  /// Process payroll batch
  Future<void> _processPayrollBatch() async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final transactionResult = await _blockchainService.processPayrollBatch(_payrollBatch);
      
      setState(() {
        _transactionResult = transactionResult;
        _isProcessing = false;
      });
      
      if (transactionResult.success) {
        _nextStep();
      } else {
        _showErrorSnackBar(transactionResult.error ?? 'Transaction failed');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorSnackBar('Processing failed: ${e.toString()}');
    }
  }

  /// Navigate to next step
  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
        ),
      ),
    );
  }

  /// Copy transaction hash to clipboard
  void _copyTransactionHash() {
    if (_transactionResult?.transactionHash != null) {
      Clipboard.setData(ClipboardData(text: _transactionResult!.transactionHash!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaction hash copied to clipboard'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(AppSpacing.mainSpacing),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            const SizedBox(height: AppSpacing.mainSpacing),
            
            // Step indicator
            _buildStepIndicator(),
            
            const SizedBox(height: AppSpacing.mainSpacing),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(),
            ),
            
            const SizedBox(height: AppSpacing.mainSpacing),
            
            // Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }

  /// Build header
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.account_balance_wallet,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: AppSpacing.tightSpacing),
        Text(
          'Process Payroll',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  /// Build step indicator
  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepItem(0, 'Review', Icons.list_alt),
        _buildStepConnector(0),
        _buildStepItem(1, 'Confirm', Icons.check_circle_outline),
        _buildStepConnector(1),
        _buildStepItem(2, 'Complete', Icons.done_all),
      ],
    );
  }

  /// Build step item
  Widget _buildStepItem(int stepIndex, String title, IconData icon) {
    final isActive = _currentStep == stepIndex;
    final isCompleted = _currentStep > stepIndex;
    
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success
                : isActive
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isCompleted || isActive ? Colors.white : AppColors.onSurfaceVariant,
            size: 20,
          ),
        ),
        const SizedBox(height: AppSpacing.tightSpacing),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isCompleted || isActive
                ? Theme.of(context).colorScheme.onSurface
                : AppColors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// Build step connector
  Widget _buildStepConnector(int stepIndex) {
    final isCompleted = _currentStep > stepIndex;
    
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? AppColors.success : AppColors.surfaceVariant,
      ),
    );
  }

  /// Build content based on current step
  Widget _buildContent() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildReviewStep(),
        _buildConfirmStep(),
        _buildCompleteStep(),
      ],
    );
  }

  /// Build review step
  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Employee Payments',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.mainSpacing),
        
        // Summary card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.mainSpacing),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Employees:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${widget.employees.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.tightSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      _payrollBatch.totalAmountFormatted,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.mainSpacing),
        
        // Employee list
        Expanded(
          child: ListView.separated(
            itemCount: widget.employees.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.tightSpacing),
            itemBuilder: (context, index) {
              final employee = widget.employees[index];
              return _buildEmployeeCard(employee);
            },
          ),
        ),
      ],
    );
  }

  /// Build employee card
  Widget _buildEmployeeCard(Employee employee) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.mainSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  employee.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  employee.salaryAmountFormatted,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.tightSpacing),
            Text(
              'Wallet: ${employee.walletAddress}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build confirm step
  Widget _buildConfirmStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Transaction',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.mainSpacing),
        
        if (_isValidating) ...[
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: AppSpacing.mainSpacing),
          const Text('Validating transaction...'),
        ] else if (_validationResult != null) ...[
          if (_validationResult!.isValid) ...[
            Card(
              color: AppColors.success.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.tightSpacing),
                    Text(
                      'Transaction Validated Successfully',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.mainSpacing),
            _buildTransactionDetails(),
          ] else ...[
            Card(
              color: AppColors.error.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                child: Column(
                  children: [
                    Icon(
                      Icons.error,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.tightSpacing),
                    Text(
                      'Validation Failed',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.tightSpacing),
                    ...(_validationResult!.errors.map((error) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.tightSpacing),
                          child: Text(
                            error,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ))),
                  ],
                ),
              ),
            ),
          ],
        ] else ...[
          const Text('Click "Validate" to check transaction requirements.'),
        ],
      ],
    );
  }

  /// Build transaction details
  Widget _buildTransactionDetails() {
    if (_validationResult == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.mainSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.mainSpacing),
            _buildDetailRow('Total Amount', _payrollBatch.totalAmountFormatted),
            _buildDetailRow('Recipients', '${_payrollBatch.employees.length} employees'),
            _buildDetailRow('Estimated Gas', '${_validationResult!.estimatedGasLimit}'),
            // _buildDetailRow('Your Balance', '\$${(_validationResult!.userBalance / BigInt.from(1000000))}'),
          ],
        ),
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.tightSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build complete step
  Widget _buildCompleteStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Complete',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.mainSpacing),
        
        if (_isProcessing) ...[
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: AppSpacing.mainSpacing),
          const Text('Processing transaction...'),
        ] else if (_transactionResult != null) ...[
          if (_transactionResult!.success) ...[
            Card(
              color: AppColors.success.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 64,
                    ),
                    const SizedBox(height: AppSpacing.mainSpacing),
                    Text(
                      'Payroll Processed Successfully!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.tightSpacing),
                    Text(
                      'All employee payments have been sent to their wallets.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (_transactionResult!.transactionHash != null) ...[
                      const SizedBox(height: AppSpacing.mainSpacing),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Transaction Hash:',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.tightSpacing),
                            GestureDetector(
                              onTap: _copyTransactionHash,
                              child: Text(
                                _transactionResult!.transactionHash!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.tightSpacing),
                            Text(
                              'Tap to copy',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ] else ...[
            Card(
              color: AppColors.error.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                child: Column(
                  children: [
                    Icon(
                      Icons.error,
                      color: AppColors.error,
                      size: 64,
                    ),
                    const SizedBox(height: AppSpacing.mainSpacing),
                    Text(
                      'Transaction Failed',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.tightSpacing),
                    Text(
                      _transactionResult!.error ?? 'Unknown error occurred',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  /// Build action buttons
  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        if (_currentStep > 0)
          TextButton(
            onPressed: _previousStep,
            child: const Text('Back'),
          )
        else
          const SizedBox.shrink(),
        
        // Main action button
        ElevatedButton(
          onPressed: _getMainActionCallback(),
          child: Text(_getMainActionText()),
        ),
      ],
    );
  }

  /// Get main action callback
  VoidCallback? _getMainActionCallback() {
    switch (_currentStep) {
      case 0:
        return _validatePayrollBatch;
      case 1:
        return _validationResult?.isValid == true ? _processPayrollBatch : null;
      case 2:
        return () => Navigator.of(context).pop();
      default:
        return null;
    }
  }

  /// Get main action text
  String _getMainActionText() {
    switch (_currentStep) {
      case 0:
        return 'Validate';
      case 1:
        return _isProcessing ? 'Processing...' : 'Process Payroll';
      case 2:
        return 'Close';
      default:
        return 'Next';
    }
  }
} 