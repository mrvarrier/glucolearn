import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class QuizResultPage extends StatelessWidget {
  final String quizId;
  final String? attemptId;

  const QuizResultPage({
    super.key,
    required this.quizId,
    this.attemptId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: 64,
                color: AppColors.warning,
              ),
              const SizedBox(height: AppDimensions.spaceLG),
              Text(
                'Quiz Results',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              Text(
                'Quiz ID: $quizId',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (attemptId != null) ...[
                const SizedBox(height: AppDimensions.spaceSM),
                Text(
                  'Attempt ID: $attemptId',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.spaceMD),
              const Text(
                'This will show detailed quiz results, score breakdown, correct/incorrect answers, and learning recommendations.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}