import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Mood.fromFirestore(Map<String, dynamic> data) {
    return Mood(
      date: data['date'] as String,
      rating: data['rating'] as int,
      note: data['note'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'rating': rating,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
