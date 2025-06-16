import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class FirebaseConnectionTest {
  static Future<void> runTests() async {
    print('🔥 Starting Firebase Connection Tests...');
    
    // Test 1: Firebase Core
    await _testFirebaseCore();
    
    // Test 2: Authentication
    await _testAuthentication();
    
    // Test 3: Firestore
    await _testFirestore();
    
    // Test 4: Services
    await _testServices();
    
    print('✅ All Firebase tests completed!');
  }

  static Future<void> _testFirebaseCore() async {
    try {
      print('\n1️⃣ Testing Firebase Core...');
      final app = Firebase.app();
      print('✅ Firebase Core: ${app.name} (${app.options.projectId})');
    } catch (e) {
      print('❌ Firebase Core Error: $e');
    }
  }

  static Future<void> _testAuthentication() async {
    try {
      print('\n2️⃣ Testing Firebase Authentication...');
      final auth = FirebaseAuth.instance;
      
      // Test anonymous sign in
      final userCredential = await auth.signInAnonymously();
      print('✅ Anonymous Auth: ${userCredential.user?.uid}');
      
      // Sign out
      await auth.signOut();
      print('✅ Sign out successful');
    } catch (e) {
      print('❌ Authentication Error: $e');
    }
  }

  static Future<void> _testFirestore() async {
    try {
      print('\n3️⃣ Testing Firestore...');
      final firestore = FirebaseFirestore.instance;
      
      // Test write
      await firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase connection test',
      });
      print('✅ Firestore Write: Success');
      
      // Test read
      final doc = await firestore.collection('test').doc('connection').get();
      if (doc.exists) {
        print('✅ Firestore Read: ${doc.data()}');
      }
      
      // Clean up
      await firestore.collection('test').doc('connection').delete();
      print('✅ Firestore Cleanup: Success');
    } catch (e) {
      print('❌ Firestore Error: $e');
    }
  }

  static Future<void> _testServices() async {
    try {
      print('\n4️⃣ Testing Custom Services...');
      
      // Test FirebaseAuthService
      final authService = FirebaseAuthService();
      print('✅ FirebaseAuthService: Initialized');
      
      // Test FirestoreService  
      final firestoreService = FirestoreService();
      print('✅ FirestoreService: Initialized');
      
      // Test analytics call
      final analytics = await firestoreService.getAnalytics();
      print('✅ Analytics Test: ${analytics.keys.length} metrics');
    } catch (e) {
      print('❌ Services Error: $e');
    }
  }

  static Future<void> testDemoAccounts() async {
    print('\n🧪 Testing Demo Accounts...');
    
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
        print('✅ Demo Admin Account: Created');
        await authService.signOut();
      } else {
        print('❌ Demo Admin Account: ${adminResult.message}');
      }
      
      // Test patient account creation  
      final patientResult = await authService.signUp(
        name: 'Demo Patient',
        email: 'patient@demo.glucolearn.com', 
        password: 'patient123!',
        role: UserRole.patient,
      );
      
      if (patientResult.success) {
        print('✅ Demo Patient Account: Created');
        await authService.signOut();
      } else {
        print('❌ Demo Patient Account: ${patientResult.message}');
      }
    } catch (e) {
      print('❌ Demo Accounts Error: $e');
    }
  }
}

