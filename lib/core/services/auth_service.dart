import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();
  
  User? _currentUser;
  User? get currentUser => _currentUser;

  static const String _currentUserKey = 'current_user_id';
  static const String _rememberMeKey = 'remember_me';

  Future<void> initialize() async {
    await _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserKey);
    
    if (userId != null) {
      final userData = await _databaseService.getUserById(userId);
      if (userData != null) {
        _currentUser = User.fromJson(_convertDbDataToJson(userData));
      }
    }
  }

  Map<String, dynamic> _convertDbDataToJson(Map<String, dynamic> dbData) {
    return {
      'id': dbData['id'],
      'email': dbData['email'],
      'name': dbData['name'],
      'passwordHash': dbData['password_hash'],
      'role': dbData['role'],
      'createdAt': dbData['created_at'],
      'updatedAt': dbData['updated_at'],
      'isActive': dbData['is_active'] == 1,
      'medicalProfile': null,
      'preferences': null,
      'assignedPlans': <String>[],
    };
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<AuthResult> signIn(String email, String password, {bool rememberMe = false}) async {
    try {
      final userData = await _databaseService.getUserByEmail(email.toLowerCase());
      
      if (userData == null) {
        return AuthResult(
          success: false,
          message: 'User not found',
        );
      }

      final hashedPassword = _hashPassword(password);
      if (userData['password_hash'] != hashedPassword) {
        return AuthResult(
          success: false,
          message: 'Invalid password',
        );
      }

      if (userData['is_active'] == 0) {
        return AuthResult(
          success: false,
          message: 'Account is deactivated',
        );
      }

      _currentUser = User.fromJson(_convertDbDataToJson(userData));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, _currentUser!.id);
      await prefs.setBool(_rememberMeKey, rememberMe);

      return AuthResult(
        success: true,
        message: 'Login successful',
        user: _currentUser,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.patient,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await _databaseService.getUserByEmail(email.toLowerCase());
      if (existingUser != null) {
        return AuthResult(
          success: false,
          message: 'User already exists with this email',
        );
      }

      // Validate password strength
      if (password.length < 6) {
        return AuthResult(
          success: false,
          message: 'Password must be at least 6 characters long',
        );
      }

      final now = DateTime.now();
      final userId = _uuid.v4();
      final hashedPassword = _hashPassword(password);

      final userData = {
        'id': userId,
        'email': email.toLowerCase(),
        'password_hash': hashedPassword,
        'name': name,
        'role': role.name,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
        'is_active': 1,
      };

      await _databaseService.insertUser(userData);

      // Create new user object
      _currentUser = User(
        id: userId,
        email: email.toLowerCase(),
        name: name,
        passwordHash: hashedPassword,
        role: role,
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, userId);

      return AuthResult(
        success: true,
        message: 'Account created successfully',
        user: _currentUser,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Sign up failed: ${e.toString()}',
      );
    }
  }

  Future<bool> updateUserProfile({
    String? name,
    MedicalProfile? medicalProfile,
    LearningPreferences? preferences,
  }) async {
    if (_currentUser == null) return false;

    try {
      final now = DateTime.now();
      final updates = <String, dynamic>{
        'updated_at': now.millisecondsSinceEpoch,
      };

      if (name != null) {
        updates['name'] = name;
        _currentUser!.name = name;
      }

      await _databaseService.updateUser(_currentUser!.id, updates);

      // Update medical profile if provided
      if (medicalProfile != null) {
        _currentUser!.medicalProfile = medicalProfile;
        // Handle medical profile update in database
      }

      // Update preferences if provided
      if (preferences != null) {
        _currentUser!.preferences = preferences;
        // Handle preferences update in database
      }

      _currentUser!.updatedAt = now;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.remove(_rememberMeKey);
  }

  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  Future<AuthResult> resetPassword(String email) async {
    try {
      final userData = await _databaseService.getUserByEmail(email.toLowerCase());
      
      if (userData == null) {
        return AuthResult(
          success: false,
          message: 'User not found',
        );
      }

      // In a real app, you would send a reset email here
      // For this local version, we'll just return success
      return AuthResult(
        success: true,
        message: 'Password reset instructions sent to your email',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Reset failed: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) {
      return AuthResult(
        success: false,
        message: 'No user logged in',
      );
    }

    try {
      final hashedOldPassword = _hashPassword(oldPassword);
      if (_currentUser!.passwordHash != hashedOldPassword) {
        return AuthResult(
          success: false,
          message: 'Current password is incorrect',
        );
      }

      if (newPassword.length < 6) {
        return AuthResult(
          success: false,
          message: 'New password must be at least 6 characters long',
        );
      }

      final hashedNewPassword = _hashPassword(newPassword);
      final now = DateTime.now();

      await _databaseService.updateUser(_currentUser!.id, {
        'password_hash': hashedNewPassword,
        'updated_at': now.millisecondsSinceEpoch,
      });

      _currentUser!.passwordHash = hashedNewPassword;
      _currentUser!.updatedAt = now;

      return AuthResult(
        success: true,
        message: 'Password changed successfully',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Password change failed: ${e.toString()}',
      );
    }
  }

  Future<void> deleteAccount() async {
    if (_currentUser == null) return;

    try {
      // In a real app, you might want to soft delete or anonymize data
      await _databaseService.updateUser(_currentUser!.id, {
        'is_active': 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await signOut();
    } catch (e) {
      // Handle error
    }
  }
}

class AuthResult {
  final bool success;
  final String message;
  final User? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}