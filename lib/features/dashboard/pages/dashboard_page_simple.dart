import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../auth/providers/auth_providers.dart';

class DashboardPageSimple extends ConsumerWidget {
  const DashboardPageSimple({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back${currentUser?.name != null ? ', ${currentUser!.name.split(' ').first}' : ''}!',
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
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: AppDimensions.iconLG,
                          ),
                          const SizedBox(width: AppDimensions.spaceMD),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Learning Streak',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '7 Days',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppDimensions.spaceLG),
              
              // Progress Card
              Text(
                'Current Plan',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type 2 Diabetes Fundamentals',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceMD),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                        child: LinearProgressIndicator(
                          value: 0.65,
                          backgroundColor: AppColors.progressTrack,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceMD),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '13 of 20 lessons completed',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '65%',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppDimensions.spaceLG),
              
              // Today's Goals
              Text(
                "Today's Goals",
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
                        true,
                        Icons.quiz_outlined,
                      ),
                      const Divider(),
                      _buildGoalItem(
                        context,
                        'Read 1 Article',
                        false,
                        Icons.article_outlined,
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
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          // Navigate to learning
                        },
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingLG),
                          child: Column(
                            children: [
                              Icon(
                                Icons.school,
                                size: AppDimensions.iconLG,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: AppDimensions.spaceMD),
                              Text(
                                'Continue\nLearning',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMD),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          // Navigate to quiz
                        },
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingLG),
                          child: Column(
                            children: [
                              Icon(
                                Icons.quiz,
                                size: AppDimensions.iconLG,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(height: AppDimensions.spaceMD),
                              Text(
                                'Take\nQuiz',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spaceXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalItem(
    BuildContext context,
    String goal,
    bool isCompleted,
    IconData icon,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isCompleted 
          ? AppColors.success.withValues(alpha: 0.1)
          : AppColors.textSecondary.withValues(alpha: 0.1),
        child: Icon(
          isCompleted ? Icons.check : icon,
          color: isCompleted ? AppColors.success : AppColors.textSecondary,
          size: AppDimensions.iconSM,
        ),
      ),
      title: Text(
        goal,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
          color: isCompleted ? AppColors.textSecondary : null,
        ),
      ),
      trailing: isCompleted
        ? Icon(
            Icons.check_circle,
            color: AppColors.success,
          )
        : null,
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning! Ready to learn?';
    } else if (hour < 17) {
      return 'Good afternoon! Time for some learning?';
    } else {
      return 'Good evening! How about a quick lesson?';
    }
  }
}