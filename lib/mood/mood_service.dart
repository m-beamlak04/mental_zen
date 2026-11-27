import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/mood.dart';

class MoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getTodayDate() {
    final now = DateTime.now();

    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  void _validateDate(String date) {
    final validFormat = RegExp(r'^\d{4}-\d{2}-\d{2}$');

    if (!validFormat.hasMatch(date)) {
      throw ArgumentError('Date must use YYYY-MM-DD format.');
    }

    final parsedDate = DateTime.tryParse(date);

    if (parsedDate == null ||
        parsedDate.toIso8601String().split('T').first != date) {
      throw ArgumentError('Invalid calendar date.');
    }
  }

  DocumentReference<Map<String, dynamic>> _moodDocument(String date) {
    _validateDate(date);

    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User is not authenticated.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .doc(date);
  }

  Future<Mood?> getMood(String date) async {
    final snapshot = await _moodDocument(date).get();

    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      return null;
    }

    return Mood.fromFirestore(data);
  }

  Stream<Mood?> watchMood(String date) {
    return _moodDocument(date)
        .snapshots(includeMetadataChanges: true)
        .where((snapshot) => !snapshot.metadata.hasPendingWrites)
        .map((snapshot) {
          final data = snapshot.data();

          if (!snapshot.exists || data == null) {
            return null;
          }

          return Mood.fromFirestore(data);
        });
  }

  Future<void> saveMood({
    required String date,
    required int rating,
    String? note,
  }) async {
    if (rating < 1 || rating > 5) {
      throw ArgumentError('Mood rating must be between 1 and 5.');
    }

    final trimmedNote = note?.trim();

    if (trimmedNote != null && trimmedNote.length > 500) {
      throw ArgumentError('Mood note cannot exceed 500 characters.');
    }

    final document = _moodDocument(date);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);

      final data = <String, dynamic>{
        'date': date,
        'rating': rating,
        'note': trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (snapshot.exists) {
        transaction.update(document, data);
      } else {
        transaction.set(document, {
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
