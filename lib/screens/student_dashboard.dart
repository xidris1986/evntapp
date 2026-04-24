import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/fc25_sidebar.dart';
import 'notifications_page.dart';
import 'event_proposal_page.dart';
import 'event_status_page.dart';
import 'calendar_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
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
        title: 'Submit Proposal',
        icon: Icons.add_circle,
      ),
      FCSidebarItem(
        title: 'Event Status',
        icon: Icons.pending_actions,
      ),
      FCSidebarItem(
        title: 'Calendar',
        icon: Icons.calendar_today,
      ),
    ];
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final unreadCount = await _notificationService.getUnreadCount();
      
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
      print('Error in StudentDashboard._initializeData(): $e');
      print('Stack trace: $stackTrace');
      
      if (!mounted) return;
      
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
        title: 'Student Dashboard',
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
        return EventProposalPage(key: UniqueKey());
      case 2:
        return EventStatusPage(key: UniqueKey());
      case 3:
        return CalendarPage(key: UniqueKey());
      default:
        return const Center(
          child: Text('Page not found'),
        );
    }
  }
}