import 'package:get_it/get_it.dart';
import 'auth_service.dart';
import 'database_service.dart';
import 'notification_service.dart';
import 'settings_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  final GetIt _getIt = GetIt.instance;

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  AuthService get authService => _getIt.get<AuthService>();
  DatabaseService get databaseService => _getIt.get<DatabaseService>();
  NotificationService get notificationService => _getIt.get<NotificationService>();

  SettingsService get settingsService => _getIt.get<SettingsService>();

  Future<void> setupLocator() async {
    try {
      print('Initializing ServiceLocator...');

      // Create and initialize database service first
      print('Initializing DatabaseService...');
      final dbService = DatabaseService();
      await dbService.init();
      _getIt.registerSingleton<DatabaseService>(dbService);
      print('DatabaseService initialized');

      // Create and initialize notification service
      print('Initializing NotificationService...');
      final notificationService = NotificationService();
      await notificationService.init();
      _getIt.registerSingleton<NotificationService>(notificationService);
      print('NotificationService initialized');

      // Register auth service
      print('Registering AuthService...');
      _getIt.registerLazySingleton(() => AuthService(dbService));
      print('AuthService registered');

      // Initialize and register settings service
      print('Initializing SettingsService...');
      final settingsService = SettingsService();
      await settingsService.init();
      _getIt.registerLazySingleton(() => settingsService);
      print('SettingsService initialized');

      print('ServiceLocator initialization complete');
    } catch (e, stackTrace) {
      print('Error during ServiceLocator initialization: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}