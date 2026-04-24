import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../utils/error_handler.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/loading_overlay.dart';

class NotificationsPage extends StatelessWidget {
  final _notificationService = ServiceLocator().notificationService;

  NotificationsPage({super.key});

  Future<void> _deleteNotification(
    BuildContext context,
    String notification,
  ) async {
    final confirmed = await ErrorHandler.confirmDialog(
      context,
      'Delete Notification',
      'Are you sure you want to delete this notification?',
    );

    if (!confirmed || !context.mounted) return;

    try {
      await _notificationService.removeNotification(notification);
      if (!context.mounted) return;
      ErrorHandler.showSuccess(
        context,
        'Notification deleted successfully',
      );
    } catch (e) {
      if (!context.mounted) return;
      ErrorHandler.showError(
        context,
        'Error deleting notification: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Notifications',
        showThemeToggle: false,
        showLogout: false,
      ),
      body: FutureBuilder<List<String>>(
        future: _notificationService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingOverlay(
              isLoading: true,
              child: SizedBox(),
            );
          }

          if (snapshot.hasError) {
            ErrorHandler.showError(
              context,
              'Error loading notifications: ${snapshot.error}',
            );
            return const Center(
              child: Text('Failed to load notifications'),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  title: Text(notification),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteNotification(context, notification),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}