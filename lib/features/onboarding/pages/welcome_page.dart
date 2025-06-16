import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/user.dart';
import '../../../core/services/auth_service.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceXL),
                    
                    // Welcome Message
                    Text(
                      AppStrings.welcome,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceMD),
                    
                    Text(
                      AppStrings.appDescription,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceXXL),
                    
                    // Features List
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingLG),
                        child: Column(
                          children: [
                            _buildFeatureItem(
                              context,
                              Icons.school_outlined,
                              'Interactive Learning',
                              'Comprehensive diabetes education through videos, quizzes, and interactive content.',
                            ),
                            const SizedBox(height: AppDimensions.spaceMD),
                            _buildFeatureItem(
                              context,
                              Icons.analytics_outlined,
                              'Progress Tracking',
                              'Monitor your learning journey with detailed progress analytics and achievements.',
                            ),
                            const SizedBox(height: AppDimensions.spaceMD),
                            _buildFeatureItem(
                              context,
                              Icons.security_outlined,
                              'Secure & Private',
                              'Your health data stays on your device. No cloud storage, complete privacy.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action Buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.go('/medical-info');
                    },
                    child: const Text(AppStrings.getStarted),
                  ),
                  
                  const SizedBox(height: AppDimensions.spaceMD),
                  
                  TextButton(
                    onPressed: () async {
                      // Skip onboarding - create minimal profile and go to dashboard
                      final authService = AuthService();
                      
                      // Create default medical profile and preferences
                      final medicalProfile = MedicalProfile(
                        diabetesType: DiabetesType.type2,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      
                      final preferences = LearningPreferences();
                      
                      await authService.updateUserProfile(
                        medicalProfile: medicalProfile,
                        preferences: preferences,
                      );
                      
                      if (context.mounted) {
                        context.go('/');
                      }
                    },
                    child: const Text(AppStrings.skip),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          child: Icon(
            icon,
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
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceSM),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}