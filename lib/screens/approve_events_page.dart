import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/service_locator.dart';
import '../utils/error_handler.dart';
import '../widgets/loading_overlay.dart';

class ApproveEventsPage extends StatefulWidget {
  const ApproveEventsPage({super.key});

  @override
  State<ApproveEventsPage> createState() => _ApproveEventsPageState();
}

class _ApproveEventsPageState extends State<ApproveEventsPage> {
  final _dbService = ServiceLocator().databaseService;
  final _notificationService = ServiceLocator().notificationService;
  bool _isLoading = true;
  List<Event> _pendingEvents = [];
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  List<Event> get _filteredEvents => _pendingEvents.where((event) {
    final search = _searchQuery.toLowerCase();
    return event.title.toLowerCase().contains(search) ||
           event.description.toLowerCase().contains(search) ||
           event.location.toLowerCase().contains(search) ||
           event.organizer.toLowerCase().contains(search);
  }).toList();

  @override
  void initState() {
    super.initState();
    _loadPendingEvents();
  }

  Future<void> _loadPendingEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await _dbService.getPendingEvents();
      setState(() => _pendingEvents = events);
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          'Error loading events: $e',
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveEvent(Event event) async {
    final confirmed = await ErrorHandler.confirmDialog(
      context,
      'Confirm Approval',
      'Are you sure you want to approve "${event.title}"?',
    );

    if (!confirmed) return;

    try {
      await _dbService.approveEvent(event.id);
      await _notificationService.addNotification(
        'Event "${event.title}" has been approved',
        event.organizer,
      );
      await _loadPendingEvents();
      if (mounted) {
        ErrorHandler.showSuccess(
          context,
          'Event approved successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          'Error approving event: $e',
        );
      }
    }
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(event.description),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text('Date: ${event.date.toString().split(' ')[0]}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on),
                  const SizedBox(width: 8),
                  Text('Location: ${event.location}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person),
                  const SizedBox(width: 8),
                  Text('Organizer: ${event.organizer}'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _approveEvent(event);
            },
            icon: const Icon(Icons.check),
            label: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      loadingText: 'Loading pending events...',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pending Events',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_filteredEvents.length} events pending approval',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _loadPendingEvents,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Events',
                hintText: 'Search by title, description, location, or organizer',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _pendingEvents.isEmpty
                                ? 'No pending events to approve'
                                : 'No events match your search',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear Search'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = _filteredEvents[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ExpansionTile(
                            title: Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Date: ${event.date.toString().split(' ')[0]} • Location: ${event.location}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                OutlinedButton(
                                  onPressed: () => _showEventDetails(event),
                                  child: const Text('Details'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _approveEvent(event),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Approve'),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.description,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        const Icon(Icons.person),
                                        const SizedBox(width: 8),
                                        Text('Organizer: ${event.organizer}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}