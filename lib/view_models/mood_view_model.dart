import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood.dart';
import '../repositories/mood_repository.dart';
import '../providers/mood_providers.dart';

final moodViewModelProvider =
    StateNotifierProvider<MoodViewModel, AsyncValue<List<Mood>>>((ref) {
  return MoodViewModel(ref.watch(moodRepositoryProvider));
});

class MoodViewModel extends StateNotifier<AsyncValue<List<Mood>>> {
  final MoodRepository _repository;

  MoodViewModel(this._repository) : super(const AsyncValue.loading());

  // 무드 생성
  Future<void> createMood({
    required String userId,
    required String emoji,
    required String description,
  }) async {
    try {
      final mood = Mood(
        id: '', // Firestore에서 자동 생성
        userId: userId,
        emoji: emoji,
        description: description,
        createdAt: DateTime.now(),
      );
      await _repository.createMood(mood);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // 사용자의 무드 목록 로드
  void loadUserMoods(String userId) {
    _repository.getUserMoods(userId).listen(
          (moods) => state = AsyncValue.data(moods),
          onError: (e) => state = AsyncValue.error(e, StackTrace.current),
        );
  }

  // 무드 삭제
  Future<void> deleteMood(String moodId) async {
    try {
      await _repository.deleteMood(moodId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
