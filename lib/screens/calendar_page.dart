import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/service_locator.dart';
import '../widgets/common_app_bar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _dbService = ServiceLocator().databaseService;
  bool _isLoading = true;
  List<Event> _approvedEvents = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await _dbService.getApprovedEvents();
      setState(() {
        _approvedEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading events: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  List<Event> _getEventsForDate(DateTime date) {
    return _approvedEvents.where((event) {
      return event.date.year == date.year &&
             event.date.month == date.month &&
             event.date.day == date.day;
    }).toList();
  }

  Widget _buildEventsList() {
    final events = _getEventsForDate(_selectedDate);

    if (events.isEmpty) {
      return const Center(
        child: Text('No events scheduled for this date'),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          child: ListTile(
            title: Text(event.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description),
                const SizedBox(height: 8),
                Text('Location: ${event.location}'),
                Text('Organizer: ${event.organizer}'),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Calendar',
        showThemeToggle: false,
        showLogout: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (date) => setState(() => _selectedDate = date),
            ),
            const SizedBox(height: 16),
            Text(
              'Events on ${_selectedDate.toString().split(' ')[0]}:',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(child: _buildEventsList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadEvents,
        tooltip: 'Refresh Events',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}