import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import 'package:get_it/get_it.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final DatabaseService _databaseService = GetIt.I<DatabaseService>();
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _databaseService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(User user) async {
    try {
      await _databaseService.deleteUser(user.id);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }

  Future<void> _updateUserType(User user) async {
    try {
      final newType = user.type == UserType.admin ? UserType.student : UserType.admin;
      final updatedUser = User(
        id: user.id,
        email: user.email,
        name: user.name,
        type: newType,
      );
      await _databaseService.updateUser(updatedUser);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User type updated to ${newType.toString().split('.').last}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user type: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final isAdmin = user.type == UserType.admin;
                return ListTile(
                  leading: Icon(
                    isAdmin ? Icons.admin_panel_settings : Icons.person,
                  ),
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      Text(
                        'Type: ${user.type.toString().split('.').last}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isAdmin
                              ? Icons.remove_moderator
                              : Icons.admin_panel_settings_outlined,
                        ),
                        onPressed: () => _updateUserType(user),
                        tooltip: isAdmin
                            ? 'Remove admin privileges'
                            : 'Grant admin privileges',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteUser(user),
                        tooltip: 'Delete user',
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadUsers,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}