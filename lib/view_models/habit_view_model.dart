import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../providers/providers.dart';
import '../repositories/habit_repository.dart';

final habitViewModelProvider =
    StateNotifierProvider<HabitViewModel, AsyncValue<List<Habit>>>((ref) {
  return HabitViewModel(ref.watch(habitRepositoryProvider));
});

class HabitViewModel extends StateNotifier<AsyncValue<List<Habit>>> {
  final HabitRepository _repository;

  HabitViewModel(this._repository) : super(const AsyncValue.loading());

  Future<void> createHabit({
    required String userId,
    required String title,
    required String description,
  }) async {
    try {
      final habit = Habit(
        userId: userId,
        title: title,
        description: description,
      );
      await _repository.createHabit(habit);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void loadUserHabits(String userId) {
    _repository.getUserHabits(userId).listen(
          (habits) => state = AsyncValue.data(habits),
          onError: (e) => state = AsyncValue.error(e, StackTrace.current),
        );
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _repository.deleteHabit(habitId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
