class Mood {
  final String date;
  final int rating;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Mood({
    required this.date,
    required this.rating,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
}