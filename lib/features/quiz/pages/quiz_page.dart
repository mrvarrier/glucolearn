import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class QuizPage extends StatelessWidget {
  final String quizId;

  const QuizPage({
    super.key,
    required this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimensions.spaceLG),
              Text(
                'Quiz Page',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              Text(
                'Quiz ID: $quizId',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              const Text(
                'This will be an interactive quiz interface with multiple question types, progress tracking, and instant feedback.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}