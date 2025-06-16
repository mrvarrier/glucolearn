import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/user.dart';
import '../../auth/providers/auth_providers.dart';

class MedicalInfoPage extends ConsumerStatefulWidget {
  const MedicalInfoPage({super.key});

  @override
  ConsumerState<MedicalInfoPage> createState() => _MedicalInfoPageState();
}

class _MedicalInfoPageState extends ConsumerState<MedicalInfoPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  int _currentStep = 0;
  bool _isLoading = false;

  final List<String> _diabetesTypes = [
    'Type 1 Diabetes',
    'Type 2 Diabetes',
    'Gestational Diabetes',
    'Pre-diabetes',
  ];

  final List<String> _treatments = [
    'Insulin',
    'Metformin',
    'Diet Only',
    'Other Medications',
    'Not Currently Treated',
  ];

  final List<String> _complications = [
    'None',
    'Diabetic Retinopathy',
    'Diabetic Neuropathy',
    'Diabetic Nephropathy',
    'Cardiovascular Disease',
    'Other',
  ];

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final formData = _formKey.currentState!.value;
      
      // Create medical profile
      final medicalProfile = MedicalProfile(
        diabetesType: _getDiabetesType(formData['diabetesType']),
        diagnosisDate: formData['diagnosisDate'],
        hba1c: formData['hba1c']?.toDouble(),
        complications: List<String>.from(formData['complications'] ?? []),
        healthcareProvider: formData['healthcareProvider'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create learning preferences
      final preferences = LearningPreferences(
        preferredContentTypes: List<String>.from(formData['contentTypes'] ?? ['video', 'quiz']),
        dailyLearningGoalMinutes: formData['learningGoal'] ?? 30,
        notificationsEnabled: formData['notifications'] ?? true,
        difficultyLevel: formData['difficultyLevel'] ?? 'beginner',
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

  DiabetesType _getDiabetesType(String? type) {
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
      body: FormBuilder(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) {
            setState(() {
              _currentStep = step;
            });
          },
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() {
                _currentStep++;
              });
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            }
          },
          controlsBuilder: (context, details) {
            return Row(
              children: [
                if (details.stepIndex > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text(AppStrings.back),
                  ),
                const SizedBox(width: AppDimensions.spaceMD),
                ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    if (details.stepIndex == 2) {
                      _handleSubmit();
                    } else {
                      details.onStepContinue?.call();
                    }
                  },
                  child: _isLoading && details.stepIndex == 2
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(details.stepIndex == 2 ? AppStrings.finish : AppStrings.next),
                ),
              ],
            );
          },
          steps: [
            // Step 1: Diabetes Information
            Step(
              title: const Text('Diabetes Information'),
              content: Column(
                children: [
                  FormBuilderDropdown<String>(
                    name: 'diabetesType',
                    decoration: const InputDecoration(
                      labelText: AppStrings.diabetesType,
                      prefixIcon: Icon(Icons.medical_information_outlined),
                    ),
                    validator: FormBuilderValidators.required(),
                    items: _diabetesTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  FormBuilderDateTimePicker(
                    name: 'diagnosisDate',
                    decoration: const InputDecoration(
                      labelText: AppStrings.diagnosisDate,
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    inputType: InputType.date,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  FormBuilderTextField(
                    name: 'hba1c',
                    decoration: const InputDecoration(
                      labelText: AppStrings.hba1cLevel,
                      prefixIcon: Icon(Icons.analytics_outlined),
                      suffixText: '%',
                      helperText: 'Enter your most recent HbA1c value',
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.max(20),
                      FormBuilderValidators.min(4),
                    ]),
                  ),
                ],
              ),
              isActive: _currentStep >= 0,
            ),
            
            // Step 2: Treatment Information
            Step(
              title: const Text('Treatment Information'),
              content: Column(
                children: [
                  FormBuilderCheckboxGroup<String>(
                    name: 'treatments',
                    decoration: const InputDecoration(
                      labelText: AppStrings.currentTreatment,
                    ),
                    options: _treatments
                        .map((treatment) => FormBuilderFieldOption(
                              value: treatment,
                              child: Text(treatment),
                            ))
                        .toList(),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  FormBuilderCheckboxGroup<String>(
                    name: 'complications',
                    decoration: const InputDecoration(
                      labelText: AppStrings.complications,
                    ),
                    options: _complications
                        .map((complication) => FormBuilderFieldOption(
                              value: complication,
                              child: Text(complication),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  FormBuilderTextField(
                    name: 'healthcareProvider',
                    decoration: const InputDecoration(
                      labelText: AppStrings.healthcareProvider,
                      prefixIcon: Icon(Icons.local_hospital_outlined),
                      helperText: 'Your doctor or clinic name (optional)',
                    ),
                  ),
                ],
              ),
              isActive: _currentStep >= 1,
            ),
            
            // Step 3: Learning Preferences
            Step(
              title: const Text('Learning Preferences'),
              content: Column(
                children: [
                  FormBuilderCheckboxGroup<String>(
                    name: 'contentTypes',
                    decoration: const InputDecoration(
                      labelText: 'Preferred Content Types',
                    ),
                    initialValue: const ['video', 'quiz'],
                    options: const [
                      FormBuilderFieldOption(
                        value: 'video',
                        child: Text('Video Lessons'),
                      ),
                      FormBuilderFieldOption(
                        value: 'quiz',
                        child: Text('Interactive Quizzes'),
                      ),
                      FormBuilderFieldOption(
                        value: 'slides',
                        child: Text('Slide Presentations'),
                      ),
                      FormBuilderFieldOption(
                        value: 'document',
                        child: Text('Downloadable Documents'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  FormBuilderSlider(
                    name: 'learningGoal',
                    decoration: const InputDecoration(
                      labelText: 'Daily Learning Goal (minutes)',
                    ),
                    initialValue: 30,
                    min: 10,
                    max: 120,
                    divisions: 11,
                    displayValues: DisplayValues.current,
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  FormBuilderDropdown<String>(
                    name: 'difficultyLevel',
                    decoration: const InputDecoration(
                      labelText: 'Experience Level',
                      prefixIcon: Icon(Icons.psychology_outlined),
                    ),
                    initialValue: 'beginner',
                    items: const [
                      DropdownMenuItem(
                        value: 'beginner',
                        child: Text('Newly Diagnosed'),
                      ),
                      DropdownMenuItem(
                        value: 'intermediate',
                        child: Text('Some Experience'),
                      ),
                      DropdownMenuItem(
                        value: 'advanced',
                        child: Text('Very Experienced'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  FormBuilderSwitch(
                    name: 'notifications',
                    title: const Text('Enable Learning Reminders'),
                    subtitle: const Text('Get daily reminders to continue your learning'),
                    initialValue: true,
                  ),
                ],
              ),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }
}