import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/user.dart';
import '../../auth/providers/auth_providers.dart';

class MedicalInfoPageSimple extends ConsumerStatefulWidget {
  const MedicalInfoPageSimple({super.key});

  @override
  ConsumerState<MedicalInfoPageSimple> createState() => _MedicalInfoPageSimpleState();
}

class _MedicalInfoPageSimpleState extends ConsumerState<MedicalInfoPageSimple> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Form controllers
  String? _selectedDiabetesType;
  DateTime? _diagnosisDate;
  final _hba1cController = TextEditingController();
  final _healthcareProviderController = TextEditingController();
  
  // Learning preferences
  int _dailyGoal = 30;
  String _difficultyLevel = 'beginner';
  bool _notificationsEnabled = true;
  
  final List<String> _diabetesTypes = [
    'Type 1 Diabetes',
    'Type 2 Diabetes', 
    'Gestational Diabetes',
    'Pre-diabetes',
  ];

  @override
  void dispose() {
    _hba1cController.dispose();
    _healthcareProviderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.medicalInformation),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/welcome'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help us personalize your learning experience',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppDimensions.spaceLG),
              
              // Diabetes Type
              Text(
                'Diabetes Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              DropdownButtonFormField<String>(
                value: _selectedDiabetesType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select your diabetes type',
                ),
                items: _diabetesTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDiabetesType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select your diabetes type';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppDimensions.spaceLG),
              
              // Diagnosis Date (Optional)
              Text(
                'Diagnosis Date (Optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                title: Text(_diagnosisDate != null 
                  ? '${_diagnosisDate!.day}/${_diagnosisDate!.month}/${_diagnosisDate!.year}'
                  : 'Select diagnosis date'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _diagnosisDate = date;
                    });
                  }
                },
                ),
              ),
              
              const SizedBox(height: AppDimensions.spaceLG),
              
              // HbA1c Level (Optional)
              Text(
                'HbA1c Level (Optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              TextFormField(
                controller: _hba1cController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your HbA1c value',
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final hba1c = double.tryParse(value);
                    if (hba1c == null || hba1c < 4.0 || hba1c > 20.0) {
                      return 'Please enter a valid HbA1c level (4.0-20.0)';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppDimensions.spaceLG),
              
              // Healthcare Provider (Optional)
              Text(
                'Healthcare Provider (Optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              TextFormField(
                controller: _healthcareProviderController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your doctor or clinic name',
                ),
              ),
              
              const SizedBox(height: AppDimensions.spaceXL),
              
              // Learning Preferences
              Text(
                'Learning Preferences',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppDimensions.spaceLG),
              
              // Daily Goal
              Text(
                'Daily Learning Goal: $_dailyGoal minutes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _dailyGoal.toDouble(),
                min: 10,
                max: 120,
                divisions: 11,
                onChanged: (value) {
                  setState(() {
                    _dailyGoal = value.round();
                  });
                },
              ),
              
              const SizedBox(height: AppDimensions.spaceMD),
              
              // Experience Level
              Text(
                'Experience Level',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              DropdownButtonFormField<String>(
                value: _difficultyLevel,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'beginner', child: Text('Newly Diagnosed')),
                  DropdownMenuItem(value: 'intermediate', child: Text('Some Experience')),
                  DropdownMenuItem(value: 'advanced', child: Text('Very Experienced')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _difficultyLevel = value;
                    });
                  }
                },
              ),
              
              const SizedBox(height: AppDimensions.spaceMD),
              
              // Notifications
              SwitchListTile(
                title: const Text('Enable Learning Reminders'),
                subtitle: const Text('Get daily reminders to continue your learning'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              
              const SizedBox(height: AppDimensions.spaceXXL),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Complete Setup'),
                ),
              ),
              
              const SizedBox(height: AppDimensions.spaceLG),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create medical profile
      final medicalProfile = MedicalProfile(
        diabetesType: _getDiabetesType(_selectedDiabetesType!),
        diagnosisDate: _diagnosisDate,
        hba1c: _hba1cController.text.isNotEmpty 
          ? double.tryParse(_hba1cController.text) 
          : null,
        healthcareProvider: _healthcareProviderController.text.isNotEmpty 
          ? _healthcareProviderController.text 
          : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create learning preferences
      final preferences = LearningPreferences(
        dailyLearningGoalMinutes: _dailyGoal,
        notificationsEnabled: _notificationsEnabled,
        difficultyLevel: _difficultyLevel,
      );

      // Update user profile
      await ref.read(authStateProvider.notifier).updateProfile(
        medicalProfile: medicalProfile,
        preferences: preferences,
      );

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  DiabetesType _getDiabetesType(String type) {
    switch (type) {
      case 'Type 1 Diabetes':
        return DiabetesType.type1;
      case 'Type 2 Diabetes':
        return DiabetesType.type2;
      case 'Gestational Diabetes':
        return DiabetesType.gestational;
      case 'Pre-diabetes':
        return DiabetesType.prediabetes;
      default:
        return DiabetesType.type2;
    }
  }
}