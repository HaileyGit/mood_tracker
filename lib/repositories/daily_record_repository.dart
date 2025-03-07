import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit.dart';

class DailyRecordRepository {
  final FirebaseFirestore _firestore;

  DailyRecordRepository(this._firestore);

  // 일일 기록 생성
  Future<DailyRecord> createRecord(DailyRecord record) async {
    final docRef =
        await _firestore.collection('daily_records').add(record.toMap());
    return record.copyWith(id: docRef.id);
  }

  // 특정 날짜의 기록 가져오기
  Stream<List<DailyRecord>> getDayRecords(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    print(
        '🔍 Querying Firestore - userId: $userId, date range: $startOfDay - $endOfDay');

    return _firestore
        .collection('daily_records')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .snapshots()
        .map((snapshot) {
      print('📊 Firestore snapshot size: ${snapshot.docs.length}');
      return snapshot.docs
          .map((doc) => DailyRecord.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // 월별 기록 가져오기
  Stream<List<DailyRecord>> getMonthRecords(String userId, DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1);

    print(
        '🗓️ Repository: Getting records for month ${month.year}-${month.month}');
    print('📅 Date range: $startOfMonth to $endOfMonth');
    print('👤 User ID: $userId');

    return _firestore
        .collection('daily_records')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfMonth.toIso8601String())
        .where('date', isLessThan: endOfMonth.toIso8601String())
        .snapshots()
        .map((snapshot) {
      print('📦 Received ${snapshot.docs.length} documents');
      return snapshot.docs.map((doc) {
        print('📄 Processing document: ${doc.id}');
        print('📅 Date in document: ${doc.data()['date']}');
        return DailyRecord.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // 기록 삭제
  Future<void> deleteRecord(String recordId) async {
    await _firestore.collection('daily_records').doc(recordId).delete();
  }
}
