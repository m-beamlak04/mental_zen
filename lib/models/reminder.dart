class Reminder {
  final String id;
  final String type;
  final int hour;
  final int minute;
  final bool enabled;
  final DateTime updatedAt;

  const Reminder({
    required this.id,
    required this.type,
    required this.hour,
    required this.minute,
    required this.enabled,
    required this.updatedAt,
  });
}