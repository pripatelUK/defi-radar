import 'package:decimal/decimal.dart';

/// Employee model for payroll processing
class Employee {
  final String id;
  final String name;
  final String walletAddress;
  final Decimal salaryAmount; // Using Decimal for precise calculations
  final String salaryAmountFormatted; // Display string like "$12,500"
  final PayrollStatus status;
  final DateTime? lastPaymentDate;
  final String? transactionHash;

  const Employee({
    required this.id,
    required this.name,
    required this.walletAddress,
    required this.salaryAmount,
    required this.salaryAmountFormatted,
    required this.status,
    this.lastPaymentDate,
    this.transactionHash,
  });

  /// Create Employee from the existing payment data structure
  factory Employee.fromPaymentData(Map<String, String> paymentData) {
    // Extract numeric value from formatted string like "$12,500"
    final amountStr = paymentData['amount']?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0';
    final amount = Decimal.parse(amountStr);
    
    return Employee(
      id: paymentData['name']?.replaceAll(' ', '_').toLowerCase() ?? '',
      name: paymentData['name'] ?? '',
      walletAddress: _getWalletAddressForEmployee(paymentData['name'] ?? ''),
      salaryAmount: amount,
      salaryAmountFormatted: paymentData['amount'] ?? '',
      status: PayrollStatus.fromString(paymentData['status'] ?? ''),
      lastPaymentDate: _parseDate(paymentData['date']),
    );
  }

  /// Convert salary amount to USDC wei (6 decimals)
  BigInt get salaryAmountInWei {
    return (salaryAmount * Decimal.fromInt(1000000)).toBigInt();
  }

  /// Create a copy of this employee with updated fields
  Employee copyWith({
    String? id,
    String? name,
    String? walletAddress,
    Decimal? salaryAmount,
    String? salaryAmountFormatted,
    PayrollStatus? status,
    DateTime? lastPaymentDate,
    String? transactionHash,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      walletAddress: walletAddress ?? this.walletAddress,
      salaryAmount: salaryAmount ?? this.salaryAmount,
      salaryAmountFormatted: salaryAmountFormatted ?? this.salaryAmountFormatted,
      status: status ?? this.status,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      transactionHash: transactionHash ?? this.transactionHash,
    );
  }

  /// Mock wallet addresses for existing employees
  static String _getWalletAddressForEmployee(String name) {
    final walletMap = {
      'Sarah Johnson': '0x6827b8f6cc60497d9bf5210d602C0EcaFDF7C405',
      'Mike Chen': '0x8ba1f109551bD432803012645AaC136c5D4b1991',
      'Emily Davis': '0x3Ec8593F930eA85F6b6b0b1c0E5A5a5a5A5A5a5A',
      'Alex Rodriguez': '0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6aa',
      'Lisa Wong': '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
      'David Miller': '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed',
    };
    return walletMap[name] ?? '0x0000000000000000000000000000000000000000';
  }

  /// Parse date from string format like "Dec 15"
  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      // For simplicity, assume current year
      final year = DateTime.now().year;
      final monthMap = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
        'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };
      final parts = dateStr.split(' ');
      if (parts.length == 2) {
        final month = monthMap[parts[0]] ?? 1;
        final day = int.tryParse(parts[1]) ?? 1;
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }
}

/// Enum for employee payroll status
enum PayrollStatus {
  pending,
  processing,
  completed,
  failed;

  /// Create from string status
  static PayrollStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PayrollStatus.pending;
      case 'processing':
        return PayrollStatus.processing;
      case 'completed':
        return PayrollStatus.completed;
      case 'failed':
        return PayrollStatus.failed;
      default:
        return PayrollStatus.pending;
    }
  }

  /// Convert to display string
  String get displayName {
    switch (this) {
      case PayrollStatus.pending:
        return 'Pending';
      case PayrollStatus.processing:
        return 'Processing';
      case PayrollStatus.completed:
        return 'Completed';
      case PayrollStatus.failed:
        return 'Failed';
    }
  }
}

/// Payroll batch for processing multiple employees
class PayrollBatch {
  final List<Employee> employees;
  final Decimal totalAmount;
  final String totalAmountFormatted;
  final DateTime createdAt;
  final PayrollBatchStatus status;
  final String? transactionHash;

  PayrollBatch({
    required this.employees,
    required this.totalAmount,
    required this.totalAmountFormatted,
    required this.createdAt,
    required this.status,
    this.transactionHash,
  });

  /// Create a payroll batch from list of employees
  factory PayrollBatch.fromEmployees(List<Employee> employees) {
    final totalAmount = employees.fold<Decimal>(
      Decimal.zero,
      (sum, employee) => sum + employee.salaryAmount,
    );
    
    return PayrollBatch(
      employees: employees,
      totalAmount: totalAmount,
      totalAmountFormatted: '\$${totalAmount.toStringAsFixed(0)}',
      createdAt: DateTime.now(),
      status: PayrollBatchStatus.pending,
    );
  }

  /// Get total amount in USDC wei
  BigInt get totalAmountInWei {
    return (totalAmount * Decimal.fromInt(1000000)).toBigInt();
  }

  /// Get list of recipient addresses
  List<String> get recipientAddresses {
    return employees.map((e) => e.walletAddress).toList();
  }

  /// Get list of amounts in wei
  List<BigInt> get amountsInWei {
    return employees.map((e) => e.salaryAmountInWei).toList();
  }
}

/// Enum for payroll batch status
enum PayrollBatchStatus {
  pending,
  processing,
  completed,
  failed;

  String get displayName {
    switch (this) {
      case PayrollBatchStatus.pending:
        return 'Pending';
      case PayrollBatchStatus.processing:
        return 'Processing';
      case PayrollBatchStatus.completed:
        return 'Completed';
      case PayrollBatchStatus.failed:
        return 'Failed';
    }
  }
} 