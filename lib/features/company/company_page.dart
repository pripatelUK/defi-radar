import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter/core/app_colors.dart';

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  // Sample team members data with Ethereum addresses
  final List<Map<String, dynamic>> _teamMembers = [
    {
      'name': 'Sarah Johnson',
      'role': 'CEO & Founder',
      'nationality': 'United States',
      'salary': '15,000',
      'ethAddress': '0x742d35Cc6634C0532925a3b8D6Ac0bC2bb7651B2',
      'icon': Icons.person,
      'color': AppColors.primary,
    },
    {
      'name': 'Mike Chen',
      'role': 'CTO',
      'nationality': 'Canada',
      'salary': '12,500',
      'ethAddress': '0x8ba1f109551bD432803012645Hac136c593weF93',
      'icon': Icons.code,
      'color': AppColors.aiBlue,
    },
    {
      'name': 'Emily Davis',
      'role': 'Head of Marketing',
      'nationality': 'United Kingdom',
      'salary': '10,800',
      'ethAddress': '0x1234567890123456789012345678901234567890',
      'icon': Icons.campaign,
      'color': AppColors.artPurple,
    },
    {
      'name': 'Alex Rodriguez',
      'role': 'Lead Developer',
      'nationality': 'Spain',
      'salary': '9,500',
      'ethAddress': '0xabcdef1234567890abcdef1234567890abcdef12',
      'icon': Icons.computer,
      'color': AppColors.blockchainOrange,
    },
    {
      'name': 'Lisa Wong',
      'role': 'Product Manager',
      'nationality': 'Singapore',
      'salary': '11,200',
      'ethAddress': '0x9876543210987654321098765432109876543210',
      'icon': Icons.inventory,
      'color': AppColors.climateGreen,
    },
    {
      'name': 'David Miller',
      'role': 'Designer',
      'nationality': 'Australia',
      'salary': '8,800',
      'ethAddress': '0xfedcba0987654321fedcba0987654321fedcba09',
      'icon': Icons.palette,
      'color': AppColors.warning,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nationalityController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company'),
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
                        Icons.business,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      Text(
                        'Team Management',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.tightSpacing),
                      Text(
                        'Manage your team members and business operations',
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

              // Business Analytics Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.analytics,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Text(
                            'Team Overview',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      
                      // Metrics Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              'Team Size',
                              '${_teamMembers.length}',
                              Icons.people,
                              AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.secondarySpacing),
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              'Monthly Payroll',
                              '\$${_calculateTotalPayroll()}',
                              Icons.monetization_on,
                              AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.secondarySpacing),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              'Avg Salary',
                              '\$${_calculateAverageSalary()}',
                              Icons.trending_up,
                              AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.secondarySpacing),
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              'Countries',
                              '${_getUniqueCountries()}',
                              Icons.public,
                              AppColors.info,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.mainSpacing),

              // Team Management Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.group,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.tightSpacing),
                              Text(
                                'Team Members',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddTeamMemberDialog,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Member'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.largeSpacing),
                      
                      // Team Member Cards Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.secondarySpacing,
                          mainAxisSpacing: AppSpacing.secondarySpacing,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _teamMembers.length,
                        itemBuilder: (context, index) {
                          final member = _teamMembers[index];
                          return _buildTeamMemberCard(context, member);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.mainSpacing),

              // Quick Actions Card
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
                            'Team Actions',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      
                    //   Row(
                    //     children: [
                    //       Expanded(
                    //         child: ElevatedButton.icon(
                    //           onPressed: () => _showComingSoonDialog(context, 'Process Payroll'),
                    //           icon: const Icon(Icons.account_balance_wallet),
                    //           label: const Text('Process Payroll'),
                    //         ),
                    //       ),
                    //       const SizedBox(width: AppSpacing.tightSpacing),
                    //       Expanded(
                    //         child: ElevatedButton.icon(
                    //           onPressed: () => _showComingSoonDialog(context, 'Generate Report'),
                    //           icon: const Icon(Icons.assessment),
                    //           label: const Text('Team Report'),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    //   const SizedBox(height: AppSpacing.tightSpacing),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showAllEthereumAddresses,
                              icon: const Icon(Icons.currency_bitcoin),
                              label: const Text('View All Addresses'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                              ),
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

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.mainSpacing),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.cardRadius),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: AppSpacing.tightSpacing),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(BuildContext context, Map<String, dynamic> member) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showTeamMemberDetails(context, member),
        borderRadius: BorderRadius.circular(AppRadius.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.mainSpacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar with Ethereum indicator
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: member['color'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      member['icon'],
                      color: member['color'],
                      size: 30,
                    ),
                  ),
                  // Ethereum address indicator
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.currency_bitcoin,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.secondarySpacing),
              
              // Name
              Text(
                member['name'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.tightSpacing),
              
              // Role
              Text(
                member['role'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.tightSpacing),
              
              // Salary
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.tightSpacing,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '\$${member['salary']} USDC',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTeamMemberDetails(BuildContext context, Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Role', member['role']),
            _buildDetailRow('Nationality', member['nationality']),
            _buildDetailRow('Monthly Salary', '\$${member['salary']} USDC'),
            const SizedBox(height: AppSpacing.secondarySpacing),
            // Ethereum Address Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.currency_bitcoin,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.tightSpacing),
                    Text(
                      'Ethereum Address',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.tightSpacing),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.secondarySpacing),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.smallRadius),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatAddress(member['ethAddress']),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.tightSpacing),
                      InkWell(
                        onTap: () => _copyAddressToClipboard(member['ethAddress']),
                        borderRadius: BorderRadius.circular(AppRadius.smallRadius),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.copy,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final memberIndex = _teamMembers.indexOf(member);
              _showTeamMemberOptions(context, member['name'], memberIndex);
            },
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.tightSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showAddTeamMemberDialog() {
    // Clear controllers
    _nameController.clear();
    _nationalityController.clear();
    _salaryController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Team Member'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: AppSpacing.mainSpacing),
              TextField(
                controller: _nationalityController,
                decoration: const InputDecoration(
                  labelText: 'Nationality',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
              ),
              const SizedBox(height: AppSpacing.mainSpacing),
              TextField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Salary (USDC)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on),
                  hintText: 'e.g. 5000',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty &&
                  _nationalityController.text.isNotEmpty &&
                  _salaryController.text.isNotEmpty) {
                _addTeamMember();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add Member'),
          ),
        ],
      ),
    );
  }

  void _addTeamMember() {
    setState(() {
      _teamMembers.add({
        'name': _nameController.text,
        'role': 'Team Member',
        'nationality': _nationalityController.text,
        'salary': _salaryController.text,
        'ethAddress': "0x8ba1f109551bD432803012645Hac136c593weF95",
        'icon': Icons.person,
        'color': AppColors.primary,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_nameController.text} added to the team!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showTeamMemberOptions(BuildContext context, String memberName, int memberIndex) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog(context, 'Send Message');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Details'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog(context, 'Edit Details');
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline, color: AppColors.error),
              title: const Text('Remove from Team', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _showRemoveConfirmationDialog(context, memberName, memberIndex);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveConfirmationDialog(BuildContext context, String memberName, int memberIndex) {
    // Safety check: Don't allow removing the last team member
    if (_teamMembers.length <= 1) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot Remove'),
          content: const Text('You cannot remove the last team member. Add more members before removing this one.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final member = _teamMembers[memberIndex];
    final isFounder = member['role'].toString().toLowerCase().contains('founder') || 
                     member['role'].toString().toLowerCase().contains('ceo');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Team Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to remove $memberName from the team?'),
            const SizedBox(height: AppSpacing.tightSpacing),
            if (isFounder) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.secondarySpacing),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.warning, size: 16),
                    const SizedBox(width: AppSpacing.tightSpacing),
                    Expanded(
                      child: Text(
                        'Warning: This person is a founder/CEO',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.tightSpacing),
            ],
            Text(
              'This action cannot be undone.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeTeamMember(memberIndex, memberName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _removeTeamMember(int memberIndex, String memberName) {
    setState(() {
      _teamMembers.removeAt(memberIndex);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$memberName has been removed from the team'),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // Note: In a real app, you'd implement proper undo functionality
            _showComingSoonDialog(context, 'Undo Remove');
          },
        ),
      ),
    );
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

  String _calculateTotalPayroll() {
    final total = _teamMembers.fold<double>(
      0.0,
      (sum, member) => sum + double.tryParse(member['salary'].replaceAll(',', ''))!,
    );
    return total.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _calculateAverageSalary() {
    if (_teamMembers.isEmpty) return '0';
    final total = _teamMembers.fold<double>(
      0.0,
      (sum, member) => sum + double.tryParse(member['salary'].replaceAll(',', ''))!,
    );
    final average = total / _teamMembers.length;
    return average.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  int _getUniqueCountries() {
    final countries = _teamMembers.map((member) => member['nationality']).toSet();
    return countries.length;
  }

  // Helper method to format Ethereum address
  String _formatAddress(String address) {
    if (address.length > 14) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 8)}';
    }
    return address;
  }

  // Helper method to copy address to clipboard
  void _copyAddressToClipboard(String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ethereum address copied to clipboard!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
        ),
      ),
    );
  }

  void _showAllEthereumAddresses() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.currency_bitcoin,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.tightSpacing),
            const Text('Team Ethereum Addresses'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Here are all the Ethereum addresses for your team members:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.mainSpacing),
                ...(_teamMembers.map((member) => _buildAddressCard(member)).toList()),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => _copyAllAddressesToClipboard(),
            child: const Text('Copy All'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> member) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.secondarySpacing),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.mainSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: member['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    member['icon'],
                    color: member['color'],
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.secondarySpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member['name'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        member['role'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.secondarySpacing),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.secondarySpacing),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.smallRadius),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      member['ethAddress'],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.tightSpacing),
                  InkWell(
                    onTap: () => _copyAddressToClipboard(member['ethAddress']),
                    borderRadius: BorderRadius.circular(AppRadius.smallRadius),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.copy,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyAllAddressesToClipboard() {
    final allAddresses = _teamMembers
        .map((member) => '${member['name']}: ${member['ethAddress']}')
        .join('\n');
    
    Clipboard.setData(ClipboardData(text: allAddresses));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All Ethereum addresses copied to clipboard!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
        ),
      ),
    );
  }
} 