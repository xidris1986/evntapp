import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/service_locator.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final _dbService = ServiceLocator().databaseService;
  bool _isLoading = true;
  List<Event> _allEvents = [];

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading events: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, int> _getEventsByMonth() {
    final eventsByMonth = <String, int>{};
    for (final event in _allEvents) {
      final monthYear = '${event.date.year}-${event.date.month.toString().padLeft(2, '0')}';
      eventsByMonth[monthYear] = (eventsByMonth[monthYear] ?? 0) + 1;
    }
    return eventsByMonth;
  }

  Map<String, int> _getEventsByLocation() {
    final eventsByLocation = <String, int>{};
    for (final event in _allEvents) {
      eventsByLocation[event.location] = (eventsByLocation[event.location] ?? 0) + 1;
    }
    return eventsByLocation;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final eventsByMonth = _getEventsByMonth();
    final eventsByLocation = _getEventsByLocation();
    final approvedCount = _allEvents.where((e) => e.status == EventStatus.approved).length;
    final pendingCount = _allEvents.where((e) => e.status == EventStatus.pending).length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  'Total Events',
                  _allEvents.length.toString(),
                  Icons.event,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCard(
                  'Approved Events',
                  approvedCount.toString(),
                  Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCard(
                  'Pending Events',
                  pendingCount.toString(),
                  Icons.pending,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Events by Month',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: eventsByMonth.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Events by Location',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: eventsByLocation.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, IconData icon, {Color? color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}