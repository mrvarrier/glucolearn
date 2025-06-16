import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.pushNamed('edit-profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceMD),
                    Text(
                      currentUser?.name ?? 'User Name',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      currentUser?.email ?? 'user@email.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceMD),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingMD,
                        vertical: AppDimensions.paddingSM,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                      ),
                      child: Text(
                        _getDiabetesTypeDisplay(currentUser?.medicalProfile?.diabetesType),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.spaceLG),
            
            // Medical Information Section
            _buildSection(
              context,
              AppStrings.medicalProfile,
              Icons.medical_information_outlined,
              [
                _buildInfoItem(
                  context,
                  'Diabetes Type',
                  _getDiabetesTypeDisplay(currentUser?.medicalProfile?.diabetesType),
                  Icons.info_outline,
                ),
                if (currentUser?.medicalProfile?.diagnosisDate != null)
                  _buildInfoItem(
                    context,
                    'Diagnosis Date',
                    _formatDate(currentUser!.medicalProfile!.diagnosisDate!),
                    Icons.calendar_today_outlined,
                  ),
                if (currentUser?.medicalProfile?.hba1c != null)
                  _buildInfoItem(
                    context,
                    'HbA1c Level',
                    '${currentUser!.medicalProfile!.hba1c}%',
                    Icons.analytics_outlined,
                  ),
                if (currentUser?.medicalProfile?.healthcareProvider != null)
                  _buildInfoItem(
                    context,
                    'Healthcare Provider',
                    currentUser!.medicalProfile!.healthcareProvider!,
                    Icons.local_hospital_outlined,
                  ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.spaceLG),
            
            // Learning Preferences Section
            _buildSection(
              context,
              'Learning Preferences',
              Icons.school_outlined,
              [
                _buildInfoItem(
                  context,
                  'Daily Learning Goal',
                  '${currentUser?.preferences?.dailyLearningGoalMinutes ?? 30} minutes',
                  Icons.timer_outlined,
                ),
                _buildInfoItem(
                  context,
                  'Experience Level',
                  _capitalizeFirst(currentUser?.preferences?.difficultyLevel ?? 'Beginner'),
                  Icons.psychology_outlined,
                ),
                _buildInfoItem(
                  context,
                  'Notifications',
                  currentUser?.preferences?.notificationsEnabled == true ? 'Enabled' : 'Disabled',
                  Icons.notifications_outlined,
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.spaceLG),
            
            // Settings Section
            _buildSection(
              context,
              'Settings',
              Icons.settings_outlined,
              [
                _buildActionItem(
                  context,
                  AppStrings.notificationSettings,
                  Icons.notifications_outlined,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification settings coming soon!')),
                    );
                  },
                ),
                _buildActionItem(
                  context,
                  AppStrings.privacySettings,
                  Icons.privacy_tip_outlined,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy settings coming soon!')),
                    );
                  },
                ),
                _buildActionItem(
                  context,
                  'Export Data',
                  Icons.download_outlined,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data export feature coming soon!')),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.spaceLG),
            
            // Support Section
            _buildSection(
              context,
              'Support',
              Icons.help_outline,
              [
                _buildActionItem(
                  context,
                  AppStrings.helpSupport,
                  Icons.help_outline,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & support coming soon!')),
                    );
                  },
                ),
                _buildActionItem(
                  context,
                  AppStrings.aboutApp,
                  Icons.info_outlined,
                  () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('About GlucoLearn'),
                        content: const Text('GlucoLearn v1.0.0\n\nA comprehensive diabetes education app for interactive learning and progress tracking.'),
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
                _buildActionItem(
                  context,
                  'Contact Us',
                  Icons.contact_support_outlined,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contact support feature coming soon!')),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.spaceXL),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showLogoutDialog(context, ref);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text(AppStrings.logout),
              ),
            ),
            
            const SizedBox(height: AppDimensions.spaceXL),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: AppDimensions.iconMD,
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconSM,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textSecondary,
      ),
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authStateProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }

  String _getDiabetesTypeDisplay(dynamic diabetesType) {
    if (diabetesType == null) return 'Not specified';
    return diabetesType.toString().split('.').last.replaceAll('type', 'Type ').replaceAll('prediabetes', 'Pre-diabetes').replaceAll('gestational', 'Gestational');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}