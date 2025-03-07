import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood.dart';

class MoodRepository {
  final FirebaseFirestore _firestore;

  MoodRepository(this._firestore);

  // 무드 생성
  Future<Mood> createMood(Mood mood) async {
    final docRef = await _firestore.collection('moods').add(mood.toMap());
    return mood.copyWith(id: docRef.id);
  }

  // 사용자의 무드 목록 스트림
  Stream<List<Mood>> getUserMoods(String userId) {
    return _firestore
        .collection('moods')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Mood.fromMap(doc.id, doc.data()))
            .toList());
  }

  // 무드 삭제
  Future<void> deleteMood(String moodId) async {
    await _firestore.collection('moods').doc(moodId).delete();
  }
}
