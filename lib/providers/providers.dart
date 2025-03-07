import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/habit_repository.dart';
import '../repositories/daily_record_repository.dart';

final habitRepositoryProvider = Provider((ref) {
  return HabitRepository(FirebaseFirestore.instance);
});

final dailyRecordRepositoryProvider = Provider((ref) {
  return DailyRecordRepository(FirebaseFirestore.instance);
});
