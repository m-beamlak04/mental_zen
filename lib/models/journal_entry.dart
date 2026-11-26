class JournalEntry {
  final String id;
  final String title;
  final String body;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });
}