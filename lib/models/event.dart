class Event {
  final int? id;
  final String eventName;
  final DateTime from;
  final DateTime to;
  final String? notes;
  final bool isAllDay;
  final int colorIndex;

  Event({
    this.id,
    required this.eventName,
    required this.from,
    required this.to,
    this.notes,
    required this.isAllDay,
    required this.colorIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventName': eventName,
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'notes': notes,
      'isAllDay': isAllDay ? 1 : 0,
      'colorIndex': colorIndex,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      eventName: map['eventName'],
      from: DateTime.parse(map['from']),
      to: DateTime.parse(map['to']),
      notes: map['notes'],
      isAllDay: map['isAllDay'] == 1,
      colorIndex: map['colorIndex'],
    );
  }
}