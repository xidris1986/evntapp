import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/service_locator.dart';
import '../utils/error_handler.dart';

class EventManagerPage extends StatefulWidget {
  const EventManagerPage({super.key});

  @override
  State<EventManagerPage> createState() => _EventManagerPageState();
}

class _EventManagerPageState extends State<EventManagerPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _organizerController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  
  final _dbService = ServiceLocator().databaseService;
  final _notificationService = ServiceLocator().notificationService;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final event = Event(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        location: _locationController.text,
        organizer: _organizerController.text,
      );

      await _dbService.addEvent(event);
      await _notificationService.addNotification(
        'New event "${event.title}" has been created',
        event.organizer,
      );

      if (mounted) {
        ErrorHandler.showSuccess(
          context,
          'Event created successfully',
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          'Error creating event: $e',
        );
      }
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _organizerController.clear();
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Event',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Event Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an event title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an event description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Event Date: '),
                        TextButton(
                          onPressed: () => _selectDate(context),
                          child: Text(
                            _selectedDate.toString().split(' ')[0],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an event location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _organizerController,
                      decoration: const InputDecoration(
                        labelText: 'Organizer',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an organizer name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _resetForm,
                          child: const Text('Reset'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _createEvent,
                          child: const Text('Create Event'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _organizerController.dispose();
    super.dispose();
  }
}