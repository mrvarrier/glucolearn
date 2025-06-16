import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../auth/providers/auth_providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _healthcareProviderController;
  late TextEditingController _hba1cController;
  
  int _dailyLearningGoal = 30;
  String _difficultyLevel = 'beginner';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(currentUserProvider);
    
    _nameController = TextEditingController(text: currentUser?.name ?? '');
    _emailController = TextEditingController(text: currentUser?.email ?? '');
    _healthcareProviderController = TextEditingController(
      text: currentUser?.medicalProfile?.healthcareProvider ?? ''
    );
    _hba1cController = TextEditingController(
      text: currentUser?.medicalProfile?.hba1c?.toString() ?? ''
    );
    
    if (currentUser?.preferences != null) {
      _dailyLearningGoal = currentUser!.preferences!.dailyLearningGoalMinutes;
      _difficultyLevel = currentUser.preferences!.difficultyLevel;
      _notificationsEnabled = currentUser.preferences!.notificationsEnabled;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _healthcareProviderController.dispose();
    _hba1cController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              _buildSection(
                'Personal Information',
                Icons.person_outline,
                [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spaceLG),
              
              // Medical Information Section
              _buildSection(
                'Medical Information',
                Icons.medical_information_outlined,
                [
                  TextFormField(
                    controller: _healthcareProviderController,
                    decoration: const InputDecoration(
                      labelText: 'Healthcare Provider (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  TextFormField(
                    controller: _hba1cController,
                    decoration: const InputDecoration(
                      labelText: 'HbA1c Level (%) (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final hba1c = double.tryParse(value);
                        if (hba1c == null || hba1c < 4.0 || hba1c > 20.0) {
                          return 'Please enter a valid HbA1c level (4.0-20.0)';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spaceLG),
              
              // Learning Preferences Section
              _buildSection(
                'Learning Preferences',
                Icons.school_outlined,
                [
                  // Daily Learning Goal
                  Text(
                    'Daily Learning Goal: $_dailyLearningGoal minutes',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Slider(
                    value: _dailyLearningGoal.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 11,
                    onChanged: (value) {
                      setState(() {
                        _dailyLearningGoal = value.round();
                      });
                    },
                  ),
                  
                  const SizedBox(height: AppDimensions.spaceMD),
                  
                  // Difficulty Level
                  DropdownButtonFormField<String>(
                    value: _difficultyLevel,
                    decoration: const InputDecoration(
                      labelText: 'Experience Level',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                      DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                      DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
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
                  
                  // Notifications Toggle
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive learning reminders and updates'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
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

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Here you would typically update the user profile
      // For now, we'll just simulate a save operation
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Go back to profile page
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}