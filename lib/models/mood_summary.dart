class MoodSummary {
  final String period;
  final double averageRating;
  final int entryCount;
  final DateTime updatedAt;

  const MoodSummary({
    required this.period,
    required this.averageRating,
    required this.entryCount,
    required this.updatedAt,
  });
}