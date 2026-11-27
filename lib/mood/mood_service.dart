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

  DocumentReference<Map<String, dynamic>> _moodDocument(String date) {
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
    return _moodDocument(date).snapshots().map((snapshot) {
      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return null;
      }

      if (data['createdAt'] == null || data['updatedAt'] == null) {
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

    final document = _moodDocument(date);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);

      final data = <String, dynamic>{
        'date': date,
        'rating': rating,
        'note': note,
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
