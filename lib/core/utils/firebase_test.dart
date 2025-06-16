import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import 'logger.dart';

class FirebaseConnectionTest {
  static Future<void> runTests() async {
    AppLogger.info('🔥 Starting Firebase Connection Tests...');
    
    // Test 1: Firebase Core
    await _testFirebaseCore();
    
    // Test 2: Authentication
    await _testAuthentication();
    
    // Test 3: Firestore
    await _testFirestore();
    
    // Test 4: Services
    await _testServices();
    
    AppLogger.success('All Firebase tests completed!');
  }

  static Future<void> _testFirebaseCore() async {
    try {
      AppLogger.info('\n1️⃣ Testing Firebase Core...');
      final app = Firebase.app();
      AppLogger.success('Firebase Core: ${app.name} (${app.options.projectId})');
    } catch (e) {
      AppLogger.error('Firebase Core Error', e);
    }
  }

  static Future<void> _testAuthentication() async {
    try {
      AppLogger.info('\n2️⃣ Testing Firebase Authentication...');
      final auth = FirebaseAuth.instance;
      
      // Test anonymous sign in
      final userCredential = await auth.signInAnonymously();
      AppLogger.success('Anonymous Auth: ${userCredential.user?.uid}');
      
      // Sign out
      await auth.signOut();
      AppLogger.success('Sign out successful');
    } catch (e) {
      AppLogger.error('Authentication Error', e);
    }
  }

  static Future<void> _testFirestore() async {
    try {
      AppLogger.info('\n3️⃣ Testing Firestore...');
      final firestore = FirebaseFirestore.instance;
      
      // Test write
      await firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase connection test',
      });
      AppLogger.success('Firestore Write: Success');
      
      // Test read
      final doc = await firestore.collection('test').doc('connection').get();
      if (doc.exists) {
        AppLogger.success('Firestore Read: ${doc.data()}');
      }
      
      // Clean up
      await firestore.collection('test').doc('connection').delete();
      AppLogger.success('Firestore Cleanup: Success');
    } catch (e) {
      AppLogger.error('Firestore Error', e);
    }
  }

  static Future<void> _testServices() async {
    try {
      AppLogger.info('\n4️⃣ Testing Custom Services...');
      
      // Test FirebaseAuthService
      FirebaseAuthService();
      AppLogger.success('FirebaseAuthService: Initialized');
      
      // Test FirestoreService  
      final firestoreService = FirestoreService();
      AppLogger.success('FirestoreService: Initialized');
      
      // Test analytics call
      final analytics = await firestoreService.getAnalytics();
      AppLogger.success('Analytics Test: ${analytics.keys.length} metrics');
    } catch (e) {
      AppLogger.error('Services Error', e);
    }
  }

  static Future<void> testDemoAccounts() async {
    AppLogger.info('\n🧪 Testing Demo Accounts...');
    
    try {
      final authService = FirebaseAuthService();
      
      // Test admin account creation
      final adminResult = await authService.signUp(
        name: 'Demo Admin',
        email: 'admin@demo.glucolearn.com',
        password: 'admin123!',
        role: UserRole.admin,
      );
      
      if (adminResult.success) {
        AppLogger.success('Demo Admin Account: Created');
        await authService.signOut();
      } else {
        AppLogger.error('Demo Admin Account: ${adminResult.message}');
      }
      
      // Test patient account creation  
      final patientResult = await authService.signUp(
        name: 'Demo Patient',
        email: 'patient@demo.glucolearn.com', 
        password: 'patient123!',
        role: UserRole.patient,
      );
      
      if (patientResult.success) {
        AppLogger.success('Demo Patient Account: Created');
        await authService.signOut();
      } else {
        AppLogger.error('Demo Patient Account: ${patientResult.message}');
      }
    } catch (e) {
      AppLogger.error('Demo Accounts Error', e);
    }
  }
}

