import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_providers.dart';
import '../widgets/progress_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/streak_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStrings.welcomeBack}${currentUser?.name != null ? ', ${currentUser!.name.split(' ').first}' : ''}!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              _getGreetingMessage(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate refresh delay
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streak Card
              const StreakCard(),
              
              const SizedBox(height: AppDimensions.spaceLG),
              
              // Progress Overview
              Text(
                AppStrings.currentPlan,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              const ProgressCard(),
              
              const SizedBox(height: AppDimensions.spaceLG),
              
              // Today's Goals
              Text(
                AppStrings.todaysGoals,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMD),
                  child: Column(
                    children: [
                      _buildGoalItem(
                        context,
                        'Complete 1 Video Lesson',
                        false,
                        Icons.play_circle_outline,
                      ),
                      const Divider(),
                      _buildGoalItem(
                        context,
                        'Take 1 Quiz',
                        false,
                        Icons.quiz_outlined,
                      ),
                      const Divider(),
                      _buildGoalItem(
                        context,
                        '30 Minutes Learning',
                        true,
                        Icons.timer_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppDimensions.spaceLG),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              
              Row(
                children: [
                  Expanded(
                    child: QuickActionCard(
                      title: AppStrings.continueLastLesson,
                      icon: Icons.play_arrow_rounded,
                      color: AppColors.primary,
                      onTap: () {
                        context.go('/learn');
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMD),
                  Expanded(
                    child: QuickActionCard(
                      title: AppStrings.takeQuiz,
                      icon: Icons.quiz_rounded,
                      color: AppColors.secondary,
                      onTap: () {
                        context.go('/quiz');
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spaceMD),
              
              Row(
                children: [
                  Expanded(
                    child: QuickActionCard(
                      title: AppStrings.viewProgress,
                      icon: Icons.analytics_rounded,
                      color: AppColors.warning,
                      onTap: () {
                        context.go('/progress');
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMD),
                  Expanded(
                    child: QuickActionCard(
                      title: 'Browse Library',
                      icon: Icons.library_books_rounded,
                      color: AppColors.info,
                      onTap: () {
                        context.go('/learn');
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spaceLG),
              
              // Recent Activity
              Text(
                AppStrings.recentActivity,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMD),
                  child: Column(
                    children: [
                      _buildActivityItem(
                        context,
                        'Completed: Understanding Type 2 Diabetes',
                        '2 hours ago',
                        Icons.check_circle_outline,
                        AppColors.success,
                      ),
                      const Divider(),
                      _buildActivityItem(
                        context,
                        'Quiz: Blood Sugar Management - 85%',
                        'Yesterday',
                        Icons.quiz_outlined,
                        AppColors.primary,
                      ),
                      const Divider(),
                      _buildActivityItem(
                        context,
                        'Watched: Healthy Eating Basics',
                        '2 days ago',
                        Icons.play_circle_outline,
                        AppColors.warning,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppDimensions.spaceXL),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning! Ready to learn?';
    } else if (hour < 17) {
      return 'Good afternoon! Continue your journey.';
    } else {
      return 'Good evening! Time for learning.';
    }
  }

  Widget _buildGoalItem(
    BuildContext context,
    String title,
    bool isCompleted,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: isCompleted ? AppColors.success : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
          color: isCompleted ? AppColors.textSecondary : null,
        ),
      ),
      trailing: Icon(
        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isCompleted ? AppColors.success : AppColors.textSecondary,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
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
      subtitle: Text(
        time,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}