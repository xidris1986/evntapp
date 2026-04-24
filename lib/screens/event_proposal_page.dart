import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/service_locator.dart';
import '../widgets/common_app_bar.dart';
import '../utils/error_handler.dart';

class EventProposalPage extends StatefulWidget {
  const EventProposalPage({super.key});

  @override
  State<EventProposalPage> createState() => _EventProposalPageState();
}

class _EventProposalPageState extends State<EventProposalPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _resourcesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  
  late final _dbService = ServiceLocator().databaseService;
  late final _notificationService = ServiceLocator().notificationService;
  
  @override
  void initState() {
    super.initState();
    _ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    try {
      await _dbService.ensureInitialized();
    } catch (e) {
      debugPrint('Error initializing database: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitProposal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final event = Event(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        location: _locationController.text,
        organizer: ServiceLocator().authService.currentUser?.name ?? 'Unknown',
        status: EventStatus.pending,
        resources: _resourcesController.text,
      );

      await _dbService.createEventProposal(event);
      
      // Notify admins and teachers
      await _notificationService.notifyAdminsAndTeachers(
        'New Event Proposal: ${event.title}',
      );

      if (!mounted) return;
      
      ErrorHandler.showSuccess(
        context,
        'Event proposal submitted successfully! Awaiting approval.',
      );
      
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showError(context, 'Error submitting proposal: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _resourcesController.clear();
    setState(() => _selectedDate = DateTime.now());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _resourcesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Propose Event',
        showThemeToggle: false,
        showLogout: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                controller: _resourcesController,
                decoration: const InputDecoration(
                  labelText: 'Required Resources',
                  border: OutlineInputBorder(),
                  hintText: 'List any resources, equipment, or support needed',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please list required resources';
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
                    onPressed: _submitProposal,
                    child: const Text('Submit Proposal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}