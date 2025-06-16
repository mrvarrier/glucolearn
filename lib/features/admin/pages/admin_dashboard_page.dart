import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_providers.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.adminPanel),
            if (currentUser != null)
              Text(
                'Welcome, ${currentUser.name}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing admin data...'),
                  duration: Duration(seconds: 1),
                ),
              );
              // Simulate refresh delay
              await Future.delayed(const Duration(seconds: 1));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Admin data refreshed!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'patient_view':
                  if (context.mounted) {
                    context.go('/patient-dashboard');
                  }
                  break;
                case 'logout':
                  await ref.read(authStateProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'patient_view',
                child: Row(
                  children: [
                    Icon(Icons.school),
                    SizedBox(width: 8),
                    Text('Patient View'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            Text(
              'Overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    context,
                    '156',
                    'Total Users',
                    Icons.people,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: _buildOverviewCard(
                    context,
                    '43',
                    'Content Items',
                    Icons.article,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.spaceMD),
            
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    context,
                    '28',
                    'Active Quizzes',
                    Icons.quiz,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: _buildOverviewCard(
                    context,
                    '12',
                    'Learning Plans',
                    Icons.school,
                    AppColors.info,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.spaceXL),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            
            Card(
              child: Column(
                children: [
                  _buildActionTile(
                    context,
                    AppStrings.contentManagement,
                    'Add, edit, and manage educational content',
                    Icons.article_outlined,
                    () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Content Management'),
                          content: const Text('Content management system will be available in a future update. You will be able to:\n\n• Add new learning materials\n• Edit existing content\n• Organize content categories\n• Upload videos and documents'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildActionTile(
                    context,
                    AppStrings.userManagement,
                    'View and manage user accounts',
                    Icons.people_outlined,
                    () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('User Management'),
                          content: const Text('User management system will be available in a future update. You will be able to:\n\n• View all registered users\n• Manage user accounts\n• View user progress\n• Send notifications'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildActionTile(
                    context,
                    AppStrings.analytics,
                    'View usage statistics and reports',
                    Icons.analytics_outlined,
                    () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Analytics Dashboard'),
                          content: const Text('Analytics dashboard will be available in a future update. You will be able to view:\n\n• User engagement metrics\n• Content performance\n• Learning progress statistics\n• Usage reports'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildActionTile(
                    context,
                    'Upload Content',
                    'Add new videos, quizzes, and learning materials',
                    Icons.upload_outlined,
                    () {
                      showBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingLG),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Upload Content',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spaceLG),
                              ListTile(
                                leading: const Icon(Icons.video_library),
                                title: const Text('Upload Video'),
                                subtitle: const Text('Add educational videos'),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Video upload feature coming soon!')),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.quiz),
                                title: const Text('Create Quiz'),
                                subtitle: const Text('Add interactive quizzes'),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Quiz creation feature coming soon!')),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.description),
                                title: const Text('Upload Document'),
                                subtitle: const Text('Add PDFs and articles'),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Document upload feature coming soon!')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppDimensions.spaceXL),
            
            // Recent Activity
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            
            Card(
              child: Column(
                children: [
                  _buildActivityItem(
                    context,
                    'New user registration',
                    'John Doe joined the platform',
                    '2 hours ago',
                    Icons.person_add,
                    AppColors.success,
                  ),
                  const Divider(height: 1),
                  _buildActivityItem(
                    context,
                    'Content updated',
                    'Blood Sugar Management video updated',
                    '5 hours ago',
                    Icons.edit,
                    AppColors.primary,
                  ),
                  const Divider(height: 1),
                  _buildActivityItem(
                    context,
                    'Quiz completed',
                    '25 users completed Diabetes Basics quiz',
                    '1 day ago',
                    Icons.quiz,
                    AppColors.warning,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppDimensions.spaceXL),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Icon(
                icon,
                color: color,
                size: AppDimensions.iconMD,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: AppDimensions.iconSM,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(
          icon,
          color: color,
          size: AppDimensions.iconSM,
        ),
      ),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }
}