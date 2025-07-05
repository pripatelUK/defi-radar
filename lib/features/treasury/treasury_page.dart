import 'package:flutter/material.dart';
import 'package:flutter_starter/core/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class TreasuryPage extends StatelessWidget {
  const TreasuryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasury'),
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
                        Icons.account_balance,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      Text(
                        'Treasury Dashboard',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.tightSpacing),
                      Text(
                        'Asset allocation and employee payments',
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

              // Total Treasury Value Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.largeSpacing),
                  child: Column(
                    children: [
                      Text(
                        'Total Treasury Value',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.tightSpacing),
                      Text(
                        '\$2,847,350',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.tightSpacing),
                      Text(
                        '+12.5% from last month',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.mainSpacing),

              // Asset Allocation Pie Chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pie_chart,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Text(
                            'Asset Allocation by Chain',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.largeSpacing),
                      
                      SizedBox(
                        height: 300,
                        child: Row(
                          children: [
                            // Pie Chart
                            Expanded(
                              flex: 2,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                  sections: _generatePieChartSections(),
                                ),
                              ),
                            ),
                            // Legend
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLegendItem('Sonic (USDC)', '\$1,150,000', AppColors.primary),
                                  const SizedBox(height: AppSpacing.secondarySpacing),
                                  _buildLegendItem('Ethereum (AAVE USDC)', '\$987,350', AppColors.blockchainOrange),
                                  const SizedBox(height: AppSpacing.secondarySpacing),
                                  _buildLegendItem('Arbitrum (AAVE USDT)', '\$710,000', AppColors.artPurple),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.mainSpacing),

              // Asset Details Cards
              Row(
                children: [
                  Expanded(
                    child: _buildAssetCard(
                      context,
                      'Sonic USDC',
                      '\$1,150,000',
                      '40.4%',
                      Icons.currency_exchange,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.secondarySpacing),
                  Expanded(
                    child: _buildAssetCard(
                      context,
                      'ETH AAVE USDC',
                      '\$987,350',
                      '34.7%',
                      Icons.account_balance,
                      AppColors.blockchainOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.secondarySpacing),
              Row(
                children: [
                  Expanded(
                    child: _buildAssetCard(
                      context,
                      'ARB AAVE USDT',
                      '\$710,000',
                      '24.9%',
                      Icons.trending_up,
                      AppColors.artPurple,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.secondarySpacing),
                  Expanded(
                    child: Container(), // Empty space for symmetry
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.largeSpacing),

              // Employee Payments Table
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payments,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Text(
                            'Recent Employee Payments',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.secondarySpacing,
                          horizontal: AppSpacing.mainSpacing,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text('Employee', style: Theme.of(context).textTheme.titleLarge)),
                            Expanded(flex: 1, child: Text('Amount', style: Theme.of(context).textTheme.titleLarge)),
                            Expanded(flex: 1, child: Text('Date', style: Theme.of(context).textTheme.titleLarge)),
                            Expanded(flex: 1, child: Text('Status', style: Theme.of(context).textTheme.titleLarge)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.tightSpacing),
                      
                      // Table Rows
                      ..._buildPaymentRows(context),
                      
                      const SizedBox(height: AppSpacing.mainSpacing),
                      
                      // Summary
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Paid This Month:',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$847,500',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.mainSpacing),

              // Quick Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.flash_on,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Text(
                            'Treasury Actions',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showComingSoonDialog(context, 'Process Payroll'),
                              icon: const Icon(Icons.account_balance_wallet),
                              label: const Text('Process Payroll'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showComingSoonDialog(context, 'Rebalance Assets'),
                              icon: const Icon(Icons.balance),
                              label: const Text('Rebalance Assets'),
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

  List<PieChartSectionData> _generatePieChartSections() {
    return [
      PieChartSectionData(
        color: AppColors.primary,
        value: 40.4,
        title: '40.4%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: AppColors.blockchainOrange,
        value: 34.7,
        title: '34.7%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: AppColors.artPurple,
        value: 24.9,
        title: '24.9%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.tightSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssetCard(
    BuildContext context,
    String title,
    String value,
    String percentage,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.mainSpacing),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.tightSpacing),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.tightSpacing),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              percentage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPaymentRows(BuildContext context) {
    final payments = [
      {'name': 'Sarah Johnson', 'amount': '\$12,500', 'date': 'Dec 15', 'status': 'Completed'},
      {'name': 'Mike Chen', 'amount': '\$10,800', 'date': 'Dec 15', 'status': 'Completed'},
      {'name': 'Emily Davis', 'amount': '\$9,200', 'date': 'Dec 15', 'status': 'Completed'},
      {'name': 'Alex Rodriguez', 'amount': '\$8,500', 'date': 'Dec 15', 'status': 'Pending'},
      {'name': 'Lisa Wong', 'amount': '\$11,300', 'date': 'Dec 15', 'status': 'Completed'},
      {'name': 'David Miller', 'amount': '\$9,800', 'date': 'Dec 15', 'status': 'Completed'},
    ];

    return payments.map((payment) {
      final isPending = payment['status'] == 'Pending';
      return Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.secondarySpacing,
          horizontal: AppSpacing.mainSpacing,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.tightSpacing),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.surfaceVariant,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                payment['name']!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                payment['amount']!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                payment['date']!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.tightSpacing,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPending ? AppColors.warning.withOpacity(0.2) : AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  payment['status']!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isPending ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature functionality will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 