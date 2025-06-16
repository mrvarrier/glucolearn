import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'core/services/firebase_auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/data_seeding_service.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Firebase services
    await FirebaseAuthService().initialize();
    await FirestoreService().seedFirestoreData();
    
    AppLogger.success('Firebase initialized successfully');
  } catch (e) {
    AppLogger.warning('Firebase initialization failed: $e');
    AppLogger.info('App will run in local-only mode');
  }
  
  // Always seed local database for demo and offline functionality
  try {
    await DataSeedingService().seedDatabase();
    AppLogger.success('Local database seeded successfully');
  } catch (e) {
    AppLogger.error('Local database seeding failed', e);
  }
  
  runApp(
    const ProviderScope(
      child: GlucoLearnApp(),
    ),
  );
}
