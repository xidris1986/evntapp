import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/fc25_sidebar.dart';
import 'notifications_page.dart';
import 'approve_events_page.dart';
import 'delete_events_page.dart';
import 'event_manager_page.dart';
import 'calendar_page.dart';
import 'analytics_page.dart';
import 'user_management_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _notificationService = ServiceLocator().notificationService;

  int _selectedIndex = 0;
  bool _isLoading = true;
  int _unreadNotifications = 0;
  List<FCSidebarItem> _menuItems = [];
  
  @override
  void initState() {
    super.initState();
    _initializeMenuItems();
    _initializeData();
  }

  void _initializeMenuItems() {
    _menuItems = [
      FCSidebarItem(
        title: 'Notifications',
        icon: Icons.notifications,
        notificationCount: 0,
      ),
      FCSidebarItem(
        title: 'Approve Events',
        icon: Icons.check_circle,
      ),
      FCSidebarItem(
        title: 'Delete Events',
        icon: Icons.delete,
      ),
      FCSidebarItem(
        title: 'Event Manager',
        icon: Icons.event,
      ),
      FCSidebarItem(
        title: 'Calendar',
        icon: Icons.calendar_today,
      ),
      FCSidebarItem(
        title: 'Analytics',
        icon: Icons.analytics,
      ),
      FCSidebarItem(
        title: 'User Management',
        icon: Icons.people,
      ),
    ];
  }


  Future<void> _initializeData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      print('AdminPage: Getting unread notification count...');
      final unreadCount = await _notificationService.getUnreadCount();
      print('AdminPage: Unread count = $unreadCount');
      
      if (!mounted) return;
      
      setState(() {
        _unreadNotifications = unreadCount;
        _menuItems[0] = FCSidebarItem(
          title: 'Notifications',
          icon: Icons.notifications,
          notificationCount: _unreadNotifications,
        );
      });
    } catch (e, stackTrace) {
      print('Error in AdminPage._initializeData(): $e');
      print('Stack trace: $stackTrace');
      
      if (!mounted) return;
      
      // Show error in UI but don't crash
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading notifications: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Admin Dashboard',
        showLogout: true,
        showThemeToggle: true,
      ),
      body: Row(
        children: [
          FC25Sidebar(
            items: _menuItems,
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() => _selectedIndex = index);
            },
          ),
          Expanded(
            child: _buildPage(_selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return NotificationsPage(key: UniqueKey());
      case 1:
        return ApproveEventsPage(key: UniqueKey());
      case 2:
        return DeleteEventsPage(key: UniqueKey());
      case 3:
        return EventManagerPage(key: UniqueKey());
      case 4:
        return CalendarPage(key: UniqueKey());
      case 5:
        return AnalyticsPage(key: UniqueKey());
      case 6:
        return UserManagementPage(key: UniqueKey());
      default:
        return const Center(
          child: Text('Page not found'),
        );
    }
  }
}