import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'core/services/firebase_auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/data_seeding_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize services
  await FirebaseAuthService().initialize();
  await FirestoreService().seedFirestoreData();
  
  // Seed local database for demo purposes
  await DataSeedingService().seedDatabase();
  
  runApp(
    const ProviderScope(
      child: GlucoLearnApp(),
    ),
  );
}
