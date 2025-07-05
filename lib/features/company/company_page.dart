import 'package:flutter/material.dart';
import 'package:flutter_starter/core/app_colors.dart';

class CompanyPage extends StatelessWidget {
  const CompanyPage({super.key});

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
                        'Company Dashboard',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.tightSpacing),
                      Text(
                        'Manage your business operations and analytics',
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
                            'Business Analytics',
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
                              'Revenue',
                              '\$125,000',
                              Icons.monetization_on,
                              AppColors.success,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.secondarySpacing),
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              'Users',
                              '1,234',
                              Icons.people,
                              AppColors.primary,
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
                              'Growth',
                              '+23%',
                              Icons.trending_up,
                              AppColors.success,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.secondarySpacing),
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              'Conversions',
                              '456',
                              Icons.swap_horiz,
                              AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.mainSpacing),

              // Team Management Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            'Team Management',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      
                      _buildTeamMember(
                        context,
                        'Sarah Johnson',
                        'CEO & Founder',
                        Icons.person,
                        AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.tightSpacing),
                      _buildTeamMember(
                        context,
                        'Mike Chen',
                        'CTO',
                        Icons.code,
                        AppColors.aiBlue,
                      ),
                      const SizedBox(height: AppSpacing.tightSpacing),
                      _buildTeamMember(
                        context,
                        'Emily Davis',
                        'Head of Marketing',
                        Icons.campaign,
                        AppColors.artPurple,
                      ),
                      
                      const SizedBox(height: AppSpacing.mainSpacing),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddTeamMemberDialog(context),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Team Member'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.mainSpacing),

              // Projects Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mainSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.work,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Text(
                            'Active Projects',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      
                      _buildProjectItem(
                        context,
                        'Mobile App Redesign',
                        'In Progress',
                        0.75,
                        AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.tightSpacing),
                      _buildProjectItem(
                        context,
                        'API Integration',
                        'Review',
                        0.90,
                        AppColors.warning,
                      ),
                      const SizedBox(height: AppSpacing.tightSpacing),
                      _buildProjectItem(
                        context,
                        'Security Audit',
                        'Planning',
                        0.25,
                        AppColors.error,
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
                            'Quick Actions',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.mainSpacing),
                      
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showComingSoonDialog(context, 'Generate Report'),
                              icon: const Icon(Icons.assessment),
                              label: const Text('Generate Report'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.tightSpacing),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showComingSoonDialog(context, 'Schedule Meeting'),
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Schedule Meeting'),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(
    BuildContext context,
    String name,
    String role,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.tightSpacing),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.secondarySpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                role,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showTeamMemberOptions(context, name),
        ),
      ],
    );
  }

  Widget _buildProjectItem(
    BuildContext context,
    String name,
    String status,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              status,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.tightSpacing),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: AppSpacing.tightSpacing),
        Text(
          '${(progress * 100).toInt()}% Complete',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _showAddTeamMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Team Member'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.mainSpacing),
            TextField(
              decoration: InputDecoration(
                labelText: 'Role/Position',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.mainSpacing),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Team member invitation sent!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Send Invitation'),
          ),
        ],
      ),
    );
  }

  void _showTeamMemberOptions(BuildContext context, String memberName) {
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
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog(context, 'Edit Profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Remove from Team'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog(context, 'Remove from Team');
              },
            ),
          ],
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
} 