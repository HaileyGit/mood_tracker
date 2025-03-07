import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/mood_repository.dart';

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MoodRepository(FirebaseFirestore.instance);
});
