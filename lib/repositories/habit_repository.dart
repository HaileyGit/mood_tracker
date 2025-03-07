import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit.dart';

class HabitRepository {
  final FirebaseFirestore _firestore;

  HabitRepository(this._firestore);

  // 습관 생성
  Future<Habit> createHabit(Habit habit) async {
    final docRef = await _firestore.collection('habits').add(habit.toMap());
    return habit.copyWith(id: docRef.id);
  }

  // 사용자의 습관 목록 스트림
  Stream<List<Habit>> getUserHabits(String userId) {
    return _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Habit.fromMap(doc.id, doc.data()))
            .toList());
  }

  // 습관 삭제 (실제로는 비활성화)
  Future<void> deleteHabit(String habitId) async {
    await _firestore
        .collection('habits')
        .doc(habitId)
        .update({'isActive': false});
  }
}
