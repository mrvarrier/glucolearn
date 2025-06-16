import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.progress),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTimeRange? pickedRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
                initialDateRange: _selectedDateRange ?? DateTimeRange(
                  start: DateTime.now().subtract(const Duration(days: 30)),
                  end: DateTime.now(),
                ),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: AppColors.primary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              
              if (pickedRange != null) {
                setState(() {
                  _selectedDateRange = pickedRange;
                });
                
                // Show confirmation of selected range
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Progress filtered from ${_formatDate(pickedRange.start)} to ${_formatDate(pickedRange.end)}',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Progress Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Progress',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceLG),
                    
                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            '1,250',
                            'Points Earned',
                            Icons.star,
                            AppColors.warning,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            '7',
                            'Current Streak',
                            Icons.local_fire_department,
                            AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceMD),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            '18',
                            'Lessons Completed',
                            Icons.school,
                            AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            '12',
                            'Quizzes Taken',
                            Icons.quiz,
                            AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.spaceLG),
            
            // Learning Progress Section
            Text(
              AppStrings.learningProgress,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                child: Column(
                  children: [
                    _buildProgressItem(
                      context,
                      'Understanding Diabetes',
                      0.85,
                      '17/20 lessons',
                      AppColors.primary,
                    ),
                    const Divider(),
                    _buildProgressItem(
                      context,
                      'Blood Sugar Management',
                      0.60,
                      '9/15 lessons',
                      AppColors.warning,
                    ),
                    const Divider(),
                    _buildProgressItem(
                      context,
                      'Nutrition & Diet',
                      0.30,
                      '4/12 lessons',
                      AppColors.error,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.spaceLG),
            
            // Quiz Performance Section
            Text(
              AppStrings.quizPerformance,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                child: Column(
                  children: [
                    _buildQuizResultItem(
                      context,
                      'Diabetes Basics Quiz',
                      85,
                      '2 days ago',
                    ),
                    const Divider(),
                    _buildQuizResultItem(
                      context,
                      'Nutrition Quiz',
                      92,
                      '1 week ago',
                    ),
                    const Divider(),
                    _buildQuizResultItem(
                      context,
                      'Exercise & Activity',
                      78,
                      '2 weeks ago',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.spaceLG),
            
            // Achievements Section
            Text(
              AppStrings.achievements,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                child: Column(
                  children: [
                    _buildAchievementItem(
                      context,
                      'First Steps',
                      'Complete your first lesson',
                      Icons.flag,
                      true,
                    ),
                    const Divider(),
                    _buildAchievementItem(
                      context,
                      'Week Warrior',
                      'Maintain a 7-day learning streak',
                      Icons.local_fire_department,
                      true,
                    ),
                    const Divider(),
                    _buildAchievementItem(
                      context,
                      'Quiz Master',
                      'Score 90% or higher on 5 quizzes',
                      Icons.emoji_events,
                      false,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.spaceXL),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
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
        const SizedBox(height: AppDimensions.spaceSM),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
    );
  }

  Widget _buildProgressItem(
    BuildContext context,
    String category,
    double progress,
    String subtitle,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(
          Icons.school,
          color: color,
          size: AppDimensions.iconSM,
        ),
      ),
      title: Text(category),
      subtitle: Text(subtitle),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${(progress * 100).round()}%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          SizedBox(
            width: 40,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizResultItem(
    BuildContext context,
    String quizName,
    int score,
    String date,
  ) {
    final Color scoreColor = score >= 90
        ? AppColors.success
        : score >= 80
            ? AppColors.warning
            : score >= 70
                ? AppColors.primary
                : AppColors.error;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scoreColor.withValues(alpha: 0.1),
        child: Icon(
          Icons.quiz,
          color: scoreColor,
          size: AppDimensions.iconSM,
        ),
      ),
      title: Text(quizName),
      subtitle: Text(date),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSM,
          vertical: AppDimensions.paddingXS,
        ),
        decoration: BoxDecoration(
          color: scoreColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        child: Text(
          '$score%',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: scoreColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool isEarned,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isEarned 
            ? AppColors.warning.withValues(alpha: 0.1)
            : AppColors.textSecondary.withValues(alpha: 0.1),
        child: Icon(
          icon,
          color: isEarned ? AppColors.warning : AppColors.textSecondary,
          size: AppDimensions.iconSM,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isEarned ? null : AppColors.textSecondary,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: isEarned
          ? Icon(
              Icons.check_circle,
              color: AppColors.success,
            )
          : Icon(
              Icons.lock_outline,
              color: AppColors.textSecondary,
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}