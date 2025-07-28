import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// Firebase
import 'firebase_options.dart';

// Core imports
import 'core/di/injector.dart';
import 'core/ui/themes/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'features/dashboard/ui/dashboard_screen.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/auth/ui/register_screen.dart';
import 'features/auth/ui/profile_screen.dart';

// Data model imports for Hive registration
import 'core/data/models/user.dart';
import 'core/data/models/medication.dart';
import 'core/data/models/dose.dart';
import 'core/data/models/schedule.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final logger = Logger();
  
  try {
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register Hive adapters
    _registerHiveAdapters();
    
// Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Firebase initialized successfully - using production Firebase
    logger.i('Firebase initialized with project: ${DefaultFirebaseOptions.currentPlatform.projectId}');
    
    // Setup dependency injection
    await setupDependencyInjection();
    
    logger.i('Dosify app initialized successfully');
  } catch (e, stackTrace) {
    logger.e('Failed to initialize app', error: e, stackTrace: stackTrace);
  }
  
  runApp(
    const ProviderScope(
      child: DosifyApp(),
    ),
  );
}

void _registerHiveAdapters() {
  // Register User adapter
  Hive.registerAdapter(UserAdapter());

  // Register Medication related adapters
  Hive.registerAdapter(MedicationAdapter());
  Hive.registerAdapter(MedicationCategoryAdapter());
  Hive.registerAdapter(MedicationFormAdapter());
  Hive.registerAdapter(MedicationTypeAdapter());
  Hive.registerAdapter(StrengthUnitAdapter());
  Hive.registerAdapter(StockUnitAdapter());
  Hive.registerAdapter(StorageConditionsAdapter());
  Hive.registerAdapter(VialTypeAdapter());
  
  // Register Dose related adapters
  Hive.registerAdapter(DoseAdapter());
  Hive.registerAdapter(DoseStatusAdapter());
  Hive.registerAdapter(DoseUnitAdapter());
  Hive.registerAdapter(SideEffectsAdapter());
  Hive.registerAdapter(EffectivenessAdapter());
  Hive.registerAdapter(ReconstitutionRecordAdapter());
  Hive.registerAdapter(SeverityLevelAdapter());
  
  // Register Schedule related adapters
  Hive.registerAdapter(ScheduleAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());
  Hive.registerAdapter(ReconstitutionInfoAdapter());
  Hive.registerAdapter(ScheduleFrequencyAdapter());
  Hive.registerAdapter(ScheduleTypeAdapter());
  Hive.registerAdapter(DayOfWeekAdapter());
  Hive.registerAdapter(InjectionSiteAdapter());
}

class DosifyApp extends ConsumerWidget {
  const DosifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'Dosify',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: '/',
          routes: {
            '/': (context) => const _AuthWrapper(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/profile': (context) => const ProfileScreen(),
          },
        );
      },
    );
  }
}

class _AuthWrapper extends ConsumerWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) => user == null ? const LoginScreen() : const DashboardScreen(),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
