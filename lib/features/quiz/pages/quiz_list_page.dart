import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class QuizListPage extends StatelessWidget {
  const QuizListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mockQuizzes = [
      {
        'id': '1',
        'title': 'Diabetes Basics Quiz',
        'description': 'Test your understanding of Type 2 diabetes fundamentals.',
        'questions': 10,
        'difficulty': 'Beginner',
        'category': 'Understanding Diabetes',
        'bestScore': 85,
        'attempts': 2,
      },
      {
        'id': '2',
        'title': 'Blood Sugar Management',
        'description': 'Quiz on monitoring and managing blood glucose levels.',
        'questions': 15,
        'difficulty': 'Intermediate',
        'category': 'Blood Sugar Management',
        'bestScore': null,
        'attempts': 0,
      },
      {
        'id': '3',
        'title': 'Nutrition & Diet Planning',
        'description': 'Test your knowledge of healthy eating for diabetes.',
        'questions': 12,
        'difficulty': 'Intermediate',
        'category': 'Nutrition & Diet',
        'bestScore': 92,
        'attempts': 1,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.takeAQuiz),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusLG),
                  ),
                ),
                builder: (context) => Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Quizzes',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppDimensions.spaceLG),
                      
                      Text(
                        'Difficulty Level',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppDimensions.spaceMD),
                      Wrap(
                        spacing: AppDimensions.spaceMD,
                        children: [
                          FilterChip(
                            label: const Text('Beginner'),
                            selected: false,
                            onSelected: (selected) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Filter applied: Beginner')),
                              );
                            },
                          ),
                          FilterChip(
                            label: const Text('Intermediate'),
                            selected: false,
                            onSelected: (selected) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Filter applied: Intermediate')),
                              );
                            },
                          ),
                          FilterChip(
                            label: const Text('Advanced'),
                            selected: false,
                            onSelected: (selected) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Filter applied: Advanced')),
                              );
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppDimensions.spaceLG),
                      
                      Text(
                        'Quiz Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppDimensions.spaceMD),
                      Wrap(
                        spacing: AppDimensions.spaceMD,
                        children: [
                          FilterChip(
                            label: const Text('Not Started'),
                            selected: false,
                            onSelected: (selected) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Filter applied: Not Started')),
                              );
                            },
                          ),
                          FilterChip(
                            label: const Text('Completed'),
                            selected: false,
                            onSelected: (selected) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Filter applied: Completed')),
                              );
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppDimensions.spaceXL),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        itemCount: mockQuizzes.length,
        itemBuilder: (context, index) {
          final quiz = mockQuizzes[index];
          return _buildQuizCard(context, quiz);
        },
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, Map<String, dynamic> quiz) {
    final bool hasAttempted = quiz['attempts'] > 0;
    final int? bestScore = quiz['bestScore'];

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
      child: InkWell(
        onTap: () {
          context.pushNamed('quiz-detail', pathParameters: {
            'id': quiz['id'],
          });
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    child: Icon(
                      Icons.quiz_rounded,
                      color: AppColors.primary,
                      size: AppDimensions.iconMD,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz['title'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          quiz['category'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasAttempted && bestScore != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingSM,
                        vertical: AppDimensions.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(bestScore).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                      ),
                      child: Text(
                        '$bestScore%',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: _getScoreColor(bestScore),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spaceMD),
              
              Text(
                quiz['description'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: AppDimensions.spaceMD),
              
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    '${quiz['questions']} questions',
                    Icons.help_outline,
                  ),
                  const SizedBox(width: AppDimensions.spaceSM),
                  _buildInfoChip(
                    context,
                    quiz['difficulty'],
                    Icons.psychology_outlined,
                  ),
                  if (hasAttempted) ...[
                    const SizedBox(width: AppDimensions.spaceSM),
                    _buildInfoChip(
                      context,
                      '${quiz['attempts']} attempt${quiz['attempts'] > 1 ? 's' : ''}',
                      Icons.history,
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: AppDimensions.spaceMD),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.pushNamed('quiz-detail', pathParameters: {
                          'id': quiz['id'],
                        });
                      },
                      child: Text(hasAttempted ? 'Retake Quiz' : 'Start Quiz'),
                    ),
                  ),
                  if (hasAttempted) ...[
                    const SizedBox(width: AppDimensions.spaceMD),
                    OutlinedButton(
                      onPressed: () {
                        context.pushNamed('quiz-result', pathParameters: {
                          'id': quiz['id'],
                        }, queryParameters: {
                          'attemptId': 'latest',
                        });
                      },
                      child: const Text('View Results'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSM,
        vertical: AppDimensions.paddingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return AppColors.success;
    if (score >= 80) return AppColors.warning;
    if (score >= 70) return AppColors.primary;
    return AppColors.error;
  }
}