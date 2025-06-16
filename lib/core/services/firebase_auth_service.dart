import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  app_user.User? _currentUser;
  app_user.User? get currentUser => _currentUser;

  Future<void> initialize() async {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _currentUser = null;
      }
    });

    // Load current user if already signed in
    final currentFirebaseUser = _auth.currentUser;
    if (currentFirebaseUser != null) {
      await _loadUserData(currentFirebaseUser.uid);
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _currentUser = app_user.User.fromJson({
          'id': uid,
          'email': userData['email'],
          'name': userData['name'],
          'passwordHash': '', // Not stored in Firebase
          'role': userData['role'],
          'createdAt': userData['createdAt'],
          'updatedAt': userData['updatedAt'],
          'isActive': userData['isActive'] ?? true,
          'medicalProfile': null, // Will be loaded from local storage
          'preferences': userData['preferences'],
          'assignedPlans': List<String>.from(userData['assignedPlans'] ?? []),
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<AuthResult> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _loadUserData(credential.user!.uid);
        return AuthResult(
          success: true,
          message: 'Login successful',
          user: _currentUser,
        );
      } else {
        return AuthResult(
          success: false,
          message: 'Login failed',
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'User not found';
          break;
        case 'wrong-password':
          message = 'Invalid password';
          break;
        case 'user-disabled':
          message = 'Account is disabled';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }
      return AuthResult(success: false, message: message);
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
    app_user.UserRole role = app_user.UserRole.patient,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final now = DateTime.now();
        final uid = credential.user!.uid;

        // Create user document in Firestore
        await _firestore.collection('users').doc(uid).set({
          'email': email.toLowerCase(),
          'name': name,
          'role': role.name,
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
          'isActive': true,
          'preferences': role == app_user.UserRole.patient ? {
            'preferredContentTypes': ['video', 'quiz'],
            'dailyLearningGoalMinutes': 30,
            'notificationsEnabled': true,
            'reminderTimes': [9, 20],
            'difficultyLevel': 'beginner',
          } : null,
          'assignedPlans': [],
        });

        // Update display name
        await credential.user!.updateDisplayName(name);

        // Load user data
        await _loadUserData(uid);

        return AuthResult(
          success: true,
          message: 'Account created successfully',
          user: _currentUser,
        );
      } else {
        return AuthResult(
          success: false,
          message: 'Account creation failed',
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'email-already-in-use':
          message = 'Email already exists';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = 'Sign up failed: ${e.message}';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Sign up failed: ${e.toString()}',
      );
    }
  }

  Future<bool> updateUserProfile({
    String? name,
    app_user.LearningPreferences? preferences,
  }) async {
    if (_currentUser == null) return false;

    try {
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (name != null) {
        updates['name'] = name;
        await _auth.currentUser?.updateDisplayName(name);
        _currentUser!.name = name;
      }

      if (preferences != null) {
        updates['preferences'] = preferences.toJson();
        _currentUser!.preferences = preferences;
      }

      await _firestore.collection('users').doc(_currentUser!.id).update(updates);
      _currentUser!.updatedAt = DateTime.now();
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
  }

  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(
        success: true,
        message: 'Password reset email sent',
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'User not found';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = 'Reset failed: ${e.message}';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Reset failed: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> changePassword(String oldPassword, String newPassword) async {
    if (_auth.currentUser == null) {
      return AuthResult(
        success: false,
        message: 'No user logged in',
      );
    }

    try {
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: oldPassword,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);

      // Update password
      await _auth.currentUser!.updatePassword(newPassword);

      return AuthResult(
        success: true,
        message: 'Password changed successfully',
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Current password is incorrect';
          break;
        case 'weak-password':
          message = 'New password is too weak';
          break;
        default:
          message = 'Password change failed: ${e.message}';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Password change failed: ${e.toString()}',
      );
    }
  }

  Future<void> deleteAccount() async {
    if (_auth.currentUser == null) return;

    try {
      final uid = _auth.currentUser!.uid;
      
      // Soft delete in Firestore (mark as inactive)
      await _firestore.collection('users').doc(uid).update({
        'isActive': false,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Note: In production, you might want to keep the Firebase Auth account
      // and just mark the user as inactive in Firestore
      await _auth.currentUser!.delete();
      _currentUser = null;
    } catch (e) {
      print('Error deleting account: $e');
    }
  }

  bool get isAuthenticated => _auth.currentUser != null && _currentUser != null;
  bool get isAdmin => _currentUser?.role == app_user.UserRole.admin;

  // Get Firebase Auth user for additional Firebase features
  User? get firebaseUser => _auth.currentUser;
}

class AuthResult {
  final bool success;
  final String message;
  final app_user.User? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}