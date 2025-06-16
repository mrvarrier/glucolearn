import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'routes.dart';
import 'theme.dart';
import '../core/constants/app_strings.dart';
import '../core/services/auth_service.dart';
import '../core/services/data_seeding_service.dart';

class GlucoLearnApp extends ConsumerStatefulWidget {
  const GlucoLearnApp({super.key});

  @override
  ConsumerState<GlucoLearnApp> createState() => _GlucoLearnAppState();
}

class _GlucoLearnAppState extends ConsumerState<GlucoLearnApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();
      
      // Initialize authentication service
      await AuthService().initialize();
      
      // Seed database with demo data
      await DataSeedingService().seedDatabase();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Handle initialization error
      debugPrint('App initialization error: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Initializing ${AppStrings.appName}...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}

// Provider for app initialization state
final appInitializationProvider = StateProvider<bool>((ref) => false);

// Provider for theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);