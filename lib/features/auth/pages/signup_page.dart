import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/user.dart';
import '../providers/auth_providers.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    setState(() {
      _isLoading = true;
    });

    final formData = _formKey.currentState!.value;
    final name = formData['name'] as String;
    final email = formData['email'] as String;
    final password = formData['password'] as String;
    final roleString = formData['role'] as String? ?? 'patient';
    final role = UserRole.values.byName(roleString);

    try {
      await ref.read(authStateProvider.notifier).signUp(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      // Check if signup was successful
      final authState = ref.read(authStateProvider);
      if (authState.isAuthenticated && mounted) {
        // Role-based redirect will be handled by the router
        context.go('/');
      } else if (authState.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.errorGeneric),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.createAccount),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.spaceLG),
              
              Text(
                'Join ${AppStrings.appName}',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppDimensions.spaceSM),
              
              Text(
                'Start your diabetes education journey today',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppDimensions.spaceXL),
              
              // Signup Form
              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'name',
                      decoration: const InputDecoration(
                        labelText: AppStrings.name,
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(2),
                      ]),
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceMD),
                    
                    FormBuilderTextField(
                      name: 'email',
                      decoration: const InputDecoration(
                        labelText: AppStrings.email,
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceMD),
                    
                    FormBuilderTextField(
                      name: 'password',
                      decoration: const InputDecoration(
                        labelText: AppStrings.password,
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock_outlined),
                        helperText: 'Must be at least 6 characters',
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(6),
                      ]),
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceMD),
                    
                    FormBuilderDropdown<String>(
                      name: 'role',
                      decoration: const InputDecoration(
                        labelText: 'Account Type',
                        hintText: 'Select your account type',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      initialValue: 'patient',
                      items: const [
                        DropdownMenuItem(
                          value: 'patient',
                          child: Text('Patient'),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Administrator'),
                        ),
                      ],
                      validator: FormBuilderValidators.required(),
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceMD),
                    
                    FormBuilderTextField(
                      name: 'confirmPassword',
                      decoration: const InputDecoration(
                        labelText: AppStrings.confirmPassword,
                        hintText: 'Confirm your password',
                        prefixIcon: Icon(Icons.lock_outlined),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        (value) {
                          final password = _formKey.currentState?.fields['password']?.value;
                          if (value != password) {
                            return AppStrings.errorPasswordMismatch;
                          }
                          return null;
                        },
                      ]),
                      onSubmitted: (_) => _handleSignup(),
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceXL),
                    
                    // Terms and Privacy Notice
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingMD),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      child: Text(
                        'By creating an account, you agree to our Terms of Service and Privacy Policy. Your health data will be stored securely on your device.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceLG),
                    
                    // Signup Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(AppStrings.createAccount),
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceLG),
                    
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(AppStrings.alreadyHaveAccount),
                        TextButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          child: const Text(AppStrings.login),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}