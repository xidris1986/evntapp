import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/service_locator.dart';

class EventStatusPage extends StatefulWidget {
  const EventStatusPage({super.key});

  @override
  State<EventStatusPage> createState() => _EventStatusPageState();
}

class _EventStatusPageState extends State<EventStatusPage> {
  final _dbService = ServiceLocator().databaseService;
  bool _isLoading = true;
  List<Event> _submittedEvents = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      // Get current user's submitted events
      final events = await _dbService.getEventsBySubmitter(
        ServiceLocator().authService.currentUser?.id ?? '',
      );
      
      if (!mounted) return;
      
      setState(() {
        _submittedEvents = events;
      });
    } catch (e) {
      print('Error loading events: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading events: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getStatusChip(EventStatus status) {
    switch (status) {
      case EventStatus.pending:
        return '🕒 Pending Review';
      case EventStatus.approved:
        return '✅ Approved';
      case EventStatus.rejected:
        return '❌ Rejected';
    }
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.pending:
        return Colors.orange;
      case EventStatus.approved:
        return Colors.green;
      case EventStatus.rejected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_submittedEvents.isEmpty) {
      return const Center(
        child: Text('No events submitted yet'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        itemCount: _submittedEvents.length,
        itemBuilder: (context, index) {
          final event = _submittedEvents[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(event.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.description),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${event.date.toString().split(' ')[0]}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Location: ${event.location}'),
                ],
              ),
              trailing: Chip(
                label: Text(_getStatusChip(event.status)),
                backgroundColor: _getStatusColor(event.status).withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _getStatusColor(event.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Show more details in a dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(event.title),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Description: ${event.description}'),
                          const SizedBox(height: 8),
                          Text('Date: ${event.date.toString().split(' ')[0]}'),
                          Text('Location: ${event.location}'),
                          Text('Resources: ${event.resources}'),
                          const SizedBox(height: 16),
                          Text(
                            'Status: ${_getStatusChip(event.status)}',
                            style: TextStyle(
                              color: _getStatusColor(event.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}