import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../../../core/services/auth_service.dart';

// Current user provider
final currentUserProvider = StateProvider<User?>((ref) => null);

// Authentication state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref);
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Authentication state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier(this.ref) : super(AuthState.initial()) {
    _initialize();
  }

  final Ref ref;

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await AuthService().initialize();
      final currentUser = AuthService().currentUser;
      
      if (currentUser != null) {
        ref.read(currentUserProvider.notifier).state = currentUser;
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signIn(String email, String password, {bool rememberMe = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await AuthService().signIn(email, password, rememberMe: rememberMe);
      
      if (result.success) {
        ref.read(currentUserProvider.notifier).state = result.user;
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await AuthService().signUp(
        name: name,
        email: email,
        password: password,
      );
      
      if (result.success) {
        ref.read(currentUserProvider.notifier).state = result.user;
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await AuthService().signOut();
      ref.read(currentUserProvider.notifier).state = null;
      
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProfile({
    String? name,
    MedicalProfile? medicalProfile,
    LearningPreferences? preferences,
  }) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final success = await AuthService().updateUserProfile(
        name: name,
        medicalProfile: medicalProfile,
        preferences: preferences,
      );
      
      if (success) {
        final updatedUser = AuthService().currentUser;
        ref.read(currentUserProvider.notifier).state = updatedUser;
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Authentication state
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.error,
  });

  factory AuthState.initial() {
    return AuthState(
      isAuthenticated: false,
      isLoading: false,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}