import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import 'service_locator.dart';

class NotificationService {
  Database? _db;

  Future<void> init() async {
    try {
      print('NotificationService.init(): Getting database path...');
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'notifications.db');
      print('NotificationService.init(): Database path = $path');

      print('NotificationService.init(): Opening database...');
      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          print('NotificationService.init(): Creating notifications table...');
          await db.execute('''
            CREATE TABLE notifications (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              userId TEXT,
              message TEXT,
              timestamp TEXT,
              isRead INTEGER DEFAULT 0
            )
          ''');
          print('NotificationService.init(): Table created successfully');
        },
      );
      print('NotificationService.init(): Database opened successfully');
    } catch (e, stackTrace) {
      print('Error initializing NotificationService: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    final userId = ServiceLocator().authService.currentUser?.id;
    if (userId == null) return 0;

    final db = _db;
    if (db == null) throw Exception('Database not initialized');

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM notifications 
      WHERE userId = ? AND isRead = 0
    ''', [userId]);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<String>> getNotifications() async {
    final userId = ServiceLocator().authService.currentUser?.id;
    if (userId == null) return [];

    final db = _db;
    if (db == null) throw Exception('Database not initialized');

    final results = await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );

    return results.map((row) => row['message'] as String).toList();
  }

  Future<void> addNotification(String userId, String message) async {
    final db = _db;
    if (db == null) throw Exception('Database not initialized');

    await db.insert('notifications', {
      'userId': userId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> notifyAdminsAndTeachers(String message) async {
    final db = _db;
    if (db == null) throw Exception('Database not initialized');

    final users = await ServiceLocator().databaseService.getAllUsers();
    final adminAndTeachers = users.where(
      (user) => user.type == UserType.admin || user.type == UserType.teacher,
    );

    for (final user in adminAndTeachers) {
      await addNotification(user.id, message);
    }
  }

  Future<void> notifyStudent(String userId, String message) async {
    await addNotification(userId, message);
  }

  Future<void> clearNotifications() async {
    final userId = ServiceLocator().authService.currentUser?.id;
    if (userId == null) return;

    final db = _db;
    if (db == null) throw Exception('Database not initialized');

    await db.delete(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> removeNotification(String notification) async {
    final userId = ServiceLocator().authService.currentUser?.id;
    if (userId == null) return;

    final db = _db;
    if (db == null) throw Exception('Database not initialized');

    await db.delete(
      'notifications',
      where: 'userId = ? AND message = ?',
      whereArgs: [userId, notification],
    );
  }
}