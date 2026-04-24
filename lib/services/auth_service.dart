import '../models/user.dart';
import 'database_service.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final DatabaseService _db;
  User? _currentUser;

  AuthService(this._db);

  bool get isAuthenticated => _currentUser != null;
  User? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    try {
      debugPrint('Attempting login for email: $email');
      final user = await _db.getUserByEmail(email);
      
      if (user != null) {
        final storedPassword = await _db.getUserPassword(email);
        if (storedPassword == password) { // In production, use proper password hashing
          debugPrint('Login successful for user: ${user.email}');
          _currentUser = user;
          return true;
        } else {
          debugPrint('Password mismatch for user: ${user.email}');
        }
      } else {
        debugPrint('No user found with email: $email');
      }
      return false;
    } catch (e, stackTrace) {
      debugPrint('Error during login: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<bool> register(String email, String password, String name, UserType type) async {
    try {
      // Check if user already exists
      final existingUser = await _db.getUserByEmail(email);
      if (existingUser != null) {
        return false;
      }

      // Create new user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        type: type,
      );

      await _db.createUser(user, password);
      _currentUser = user;
      return true;
    } catch (e) {
      return false;
    }
  }
}