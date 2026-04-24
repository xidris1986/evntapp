import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'services/service_locator.dart';
import 'services/settings_service.dart';
import 'screens/login_page.dart';
import 'screens/admin_page.dart';
import 'screens/student_dashboard.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/event_proposal_page.dart';
import 'utils/app_theme.dart';

void main() async {
  // Initialize error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // Handle async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Async error: $error');
    debugPrint('Stack trace: $stack');
    return true;
  };

  // Initialize Flutter bindings first
  WidgetsFlutterBinding.ensureInitialized();

  // Platform-specific initialization
  if (Platform.isWindows) {
    // Initialize sqflite_ffi for Windows
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  try {
    // Initialize service locator
    print('Initializing ServiceLocator from main()...');
    await ServiceLocator().setupLocator();
    print('ServiceLocator setup completed');

    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('Error initializing app: $e');
    debugPrint('Stack trace: $stackTrace');
    // Show error dialog or widget
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: $e'),
                const SizedBox(height: 8),
                const Text('Please restart the application'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingWrapper extends StatelessWidget {
  const LoadingWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing...'),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;
  late SettingsService _settingsService;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();

    // Configure error widget
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${errorDetails.exception}'),
              const SizedBox(height: 8),
              const Text('Please restart the application'),
            ],
          ),
        ),
      );
    };

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('Initializing app...');
      _settingsService = ServiceLocator().settingsService;
      _themeMode = await _settingsService.getThemeMode();

      debugPrint('Setting up theme listener...');
      // Listen for theme changes
      _settingsService.addListener((mode) {
        debugPrint('Theme changed to: $mode');
        if (mounted) {
          setState(() => _themeMode = mode);
        }
      });

      if (mounted) {
        debugPrint('App initialized successfully');
        setState(() => _isInitialized = true);
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _initializeApp: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management System',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: _isInitialized ? const LoginPage() : const LoadingWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/admin': (context) => const AdminPage(),
        '/teacher': (context) => const TeacherDashboard(),
        '/student': (context) => const StudentDashboard(),
        '/event-proposal': (context) => const EventProposalPage(),
      },
    );
  }
}
