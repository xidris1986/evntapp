import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event.dart';
import '../models/user.dart';

class DatabaseService {
  Database? _db;

  bool get isInitialized => _db != null;

  Future<void> ensureInitialized() async {
    if (!isInitialized) {
      await init();
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE,
        name TEXT,
        type TEXT,
        password TEXT
      )
    ''');

    // Create index on email for faster lookups
    await db.execute('CREATE INDEX idx_users_email ON users(email)');

    // Create events table with all columns
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        date TEXT,
        location TEXT,
        organizer TEXT,
        status TEXT,
        resources TEXT,
        rejectionReason TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add resources and rejectionReason columns if they don't exist
      await db.execute('ALTER TABLE events ADD COLUMN resources TEXT');
      await db.execute('ALTER TABLE events ADD COLUMN rejectionReason TEXT');
    }
  }

  // Single instance of database
  static Database? _database;

  // Getter for the database instance
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      print('Initializing database...');
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'event_management.db');
      print('Database path: $path');

      final db = await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) {
          print('Database opened successfully');
        },
      );

      print('Database initialized successfully');
      return db;
    } catch (e, stackTrace) {
      print('Error initializing database: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> init() async {
    try {
      print('Initializing database service...');
      if (_database != null) {
        if (_database!.isOpen) {
          print('Closing existing database connection...');
          await _database!.close();
        }
        _database = null;
      }
      
      await database; // Initialize a new database connection
      print('Database service initialized successfully');
    } catch (e, stackTrace) {
      print('Error in database service initialization: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final results = await db.query('users');
    return results.map((row) => User.fromMap(row)).toList();
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(String userId) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (results.isEmpty) return null;
      return User.fromMap(results.first);
    } catch (e, stackTrace) {
      print('Error fetching user by email: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<String?> getUserPassword(String email) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        columns: ['password'],
        where: 'email = ?',
        whereArgs: [email],
      );

      if (results.isEmpty) return null;
      return results.first['password'] as String?;
    } catch (e, stackTrace) {
      print('Error fetching user password: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<void> createUser(User user, String password) async {
    final db = await database;
    await db.insert('users', {
      ...user.toMap(),
      'password': password, // In a real app, this should be hashed
    });
  }

  Future<List<Event>> getApprovedEvents() async {
    final db = await database;
    final results = await db.query(
      'events',
      where: 'status = ?',
      whereArgs: ['approved'],
    );
    return results.map((e) => Event.fromMap(e)).toList();
  }

  Future<List<Event>> getPendingEvents() async {
    final db = await database;
    final results = await db.query(
      'events',
      where: 'status = ?',
      whereArgs: ['pending'],
    );
    return results.map((e) => Event.fromMap(e)).toList();
  }

  Future<List<Event>> getEventsBySubmitter(String submitterId) async {
    final db = await database;
    final results = await db.query(
      'events',
      where: 'organizer = ?',
      whereArgs: [submitterId],
      orderBy: 'date DESC',
    );
    return results.map((e) => Event.fromMap(e)).toList();
  }

  Future<void> addEvent(Event event) async {
    final db = await database;
    await db.insert('events', event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    final db = await database;
    await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  Future<void> createEventProposal(Event event) async {
    final db = await database;
    await db.insert('events', event.toMap());
  }

  Future<void> approveEvent(String eventId) async {
    final db = await database;
    await db.update(
      'events',
      {'status': EventStatus.approved.toString().split('.').last},
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  Future<void> rejectEvent(String eventId, String reason) async {
    final db = await database;
    await db.update(
      'events',
      {
        'status': EventStatus.rejected.toString().split('.').last,
        'rejectionReason': reason,
      },
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }
}