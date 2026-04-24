import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/service_locator.dart';
import '../utils/error_handler.dart';
import '../widgets/loading_overlay.dart';

class DeleteEventsPage extends StatefulWidget {
  const DeleteEventsPage({super.key});

  @override
  State<DeleteEventsPage> createState() => _DeleteEventsPageState();
}

class _DeleteEventsPageState extends State<DeleteEventsPage> {
  final _dbService = ServiceLocator().databaseService;
  final _notificationService = ServiceLocator().notificationService;
  bool _isLoading = true;
  List<Event> _allEvents = [];
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'date'; // 'date', 'title', 'location'
  bool _sortAscending = true;
  String _filterStatus = 'all'; // 'all', 'approved', 'pending'

  List<Event> get _filteredAndSortedEvents {
    List<Event> events = _allEvents.where((event) {
      if (_filterStatus == 'approved' && event.status != EventStatus.approved) return false;
      if (_filterStatus == 'pending' && event.status == EventStatus.approved) return false;

      final search = _searchQuery.toLowerCase();
      return event.title.toLowerCase().contains(search) ||
             event.description.toLowerCase().contains(search) ||
             event.location.toLowerCase().contains(search) ||
             event.organizer.toLowerCase().contains(search);
    }).toList();

    events.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'location':
          comparison = a.location.compareTo(b.location);
          break;
        case 'date':
        default:
          comparison = a.date.compareTo(b.date);
      }
      return _sortAscending ? comparison : -comparison;
    });

    return events;
  }

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final approved = await _dbService.getApprovedEvents();
      final pending = await _dbService.getPendingEvents();
      setState(() => _allEvents = [...approved, ...pending]);
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

  Future<void> _deleteEvent(Event event) async {
    final confirmed = await ErrorHandler.confirmDialog(
      context,
      'Confirm Delete',
      'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
    );

    if (!confirmed) return;

    try {
      await _dbService.deleteEvent(event.id);
      await _notificationService.addNotification(
        'Event "${event.title}" has been deleted',
        event.organizer,
      );
      await _loadEvents();
      if (mounted) {
        ErrorHandler.showSuccess(
          context,
          'Event deleted successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          'Error deleting event: $e',
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      loadingText: 'Loading events...',
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
                      'Manage Events',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_filteredAndSortedEvents.length} events found',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _loadEvents,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
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
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Sort by',
                              border: OutlineInputBorder(),
                            ),
                            value: _sortBy,
                            items: const [
                              DropdownMenuItem(
                                value: 'date',
                                child: Text('Date'),
                              ),
                              DropdownMenuItem(
                                value: 'title',
                                child: Text('Title'),
                              ),
                              DropdownMenuItem(
                                value: 'location',
                                child: Text('Location'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _sortBy = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(_sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward),
                          onPressed: () {
                            setState(() => _sortAscending = !_sortAscending);
                          },
                          tooltip:
                              _sortAscending ? 'Sort Ascending' : 'Sort Descending',
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Filter Status',
                              border: OutlineInputBorder(),
                            ),
                            value: _filterStatus,
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All Events'),
                              ),
                              DropdownMenuItem(
                                value: 'approved',
                                child: Text('Approved Only'),
                              ),
                              DropdownMenuItem(
                                value: 'pending',
                                child: Text('Pending Only'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _filterStatus = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredAndSortedEvents.isEmpty
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
                            _allEvents.isEmpty
                                ? 'No events available'
                                : 'No events match your criteria',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (_searchQuery.isNotEmpty ||
                              _filterStatus != 'all') ...[
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _filterStatus = 'all';
                                });
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear Filters'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredAndSortedEvents.length,
                      itemBuilder: (context, index) {
                        final event = _filteredAndSortedEvents[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    event.title,
                                    style: TextStyle(
                                      color: event.status == EventStatus.approved
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    event.status == EventStatus.approved ? 'Approved' : 'Pending',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: event.status == EventStatus.approved
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(event.description),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Date: ${event.date.toString().split(' ')[0]}',
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.location_on, size: 16),
                                    const SizedBox(width: 4),
                                    Text('Location: ${event.location}'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16),
                                    const SizedBox(width: 4),
                                    Text('Organizer: ${event.organizer}'),
                                  ],
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: IconButton.outlined(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => _deleteEvent(event),
                            ),
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