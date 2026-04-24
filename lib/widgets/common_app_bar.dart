import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../utils/error_handler.dart';

class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showThemeToggle;
  final bool showLogout;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showThemeToggle = true,
    this.showLogout = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CommonAppBar> createState() => _CommonAppBarState();
}

class _CommonAppBarState extends State<CommonAppBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final settingsService = ServiceLocator().settingsService;
    final themeMode = await settingsService.getThemeMode();
    setState(() => _isDark = themeMode == ThemeMode.dark);
    if (_isDark) {
      _controller.forward();
    }
  }

  Future<void> _toggleTheme() async {
    final settingsService = ServiceLocator().settingsService;
    final newMode = _isDark ? ThemeMode.light : ThemeMode.dark;
    await settingsService.setThemeMode(newMode);
    
    setState(() => _isDark = !_isDark);
    if (_isDark) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await ErrorHandler.confirmDialog(
      context,
      'Confirm Logout',
      'Are you sure you want to logout?',
    );

    if (confirmed && mounted) {
      await ServiceLocator().authService.logout();
      if (!mounted) return;
      
      // Show logout success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Wait for message to be visible then navigate
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      actions: [
        if (widget.showThemeToggle)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return IconButton(
                onPressed: _toggleTheme,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isDark
                      ? const Icon(Icons.dark_mode, key: ValueKey('dark'))
                      : const Icon(Icons.light_mode, key: ValueKey('light')),
                ),
                tooltip: _isDark ? 'Switch to light mode' : 'Switch to dark mode',
              );
            },
          ),
        if (widget.showLogout)
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
      ],
    );
  }
}