enum EventStatus {
  pending,
  approved,
  rejected
}

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String organizer;
  final EventStatus status;
  final String resources;
  final String? rejectionReason;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.organizer,
    this.status = EventStatus.pending,
    this.resources = '',
    this.rejectionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'organizer': organizer,
      'status': status.toString().split('.').last,
      'resources': resources,
      'rejectionReason': rejectionReason,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    // Convert string status to enum
    final statusStr = (map['status'] ?? 'pending') as String;
    final status = EventStatus.values.firstWhere(
      (e) => e.toString().split('.').last == statusStr,
      orElse: () => EventStatus.pending,
    );
    
    return Event(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      location: map['location'] as String,
      organizer: map['organizer'] as String,
      status: status,
      resources: (map['resources'] as String?) ?? '',
      rejectionReason: map['rejectionReason'] as String?,
    );
  }
}