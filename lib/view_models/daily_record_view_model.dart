import 'dart:async';

import 'dart:async'; // TimeoutException을 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../providers/providers.dart';
import '../repositories/daily_record_repository.dart';

final dailyRecordViewModelProvider =
    StateNotifierProvider<DailyRecordViewModel, AsyncValue<List<DailyRecord>>>(
        (ref) {
  return DailyRecordViewModel(ref.watch(dailyRecordRepositoryProvider));
});

class DailyRecordViewModel
    extends StateNotifier<AsyncValue<List<DailyRecord>>> {
  final DailyRecordRepository _repository;

  DailyRecordViewModel(this._repository) : super(const AsyncValue.loading());

  Future<void> createRecord({
    required String userId,
    required String habitId,
    required bool isSuccess,
    required String emoji,
    required String note,
    required int rewardStamp,
  }) async {
    try {
      final record = DailyRecord(
        userId: userId,
        habitId: habitId,
        date: DateTime.now(),
        isSuccess: isSuccess,
        emoji: emoji,
        note: note,
        rewardStamp: rewardStamp,
      );
      await _repository.createRecord(record);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void loadDayRecords(String userId, DateTime date) {
    print('📅 Loading records for date: ${date.toString()}');
    _repository.getDayRecords(userId, date).listen(
      (records) {
        print('📝 Received records: ${records.length}');
        state = AsyncValue.data(records);
      },
      onError: (e) {
        print('❌ Error loading records: $e');
        state = AsyncValue.error(e, StackTrace.current);
      },
    );
  }

  Future<void> loadMonthRecords(String userId, DateTime month) async {
    print('🔄 Starting loadMonthRecords...');
    state = const AsyncValue.loading();
    try {
      print('📅 Loading records for month: ${month.year}-${month.month}');
      print('🔍 User ID: $userId');

      final recordsStream = _repository.getMonthRecords(userId, month);
      print('📡 Got stream from repository');

      final records = await recordsStream.first.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('데이터 로드 시간이 초과되었습니다.');
        },
      );

      print('📝 Received monthly records: ${records.length}');
      print('📊 Records data: ${records.map((r) => '${r.date}: ${r.emoji}')}');

      if (mounted) {
        print('✅ Updating state with records');
        state = AsyncValue.data(records);
      } else {
        print('❌ Widget not mounted, skipping state update');
      }
    } catch (e, stack) {
      print('❌ Error loading monthly records:');
      print('Error: $e');
      print('Stack trace: $stack');
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> deleteRecord(String recordId) async {
    try {
      await _repository.deleteRecord(recordId);
      // 현재 상태에서 해당 record 제거
      state.whenData((records) {
        final updatedRecords =
            records.where((record) => record.id != recordId).toList();
        state = AsyncValue.data(updatedRecords);
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // 테스트 데이터 생성
  Future<void> createTestData(String userId) async {
    try {
      final testData = [
        {
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'isSuccess': true,
          'emoji': '😊',
          'note': '어제도 성공!',
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'isSuccess': false,
          'emoji': '😔',
          'note': '이틀 전에는 실패...',
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'isSuccess': true,
          'emoji': '🎉',
          'note': '3일 전 성공',
        },
        // 더 많은 날짜 추가 가능
      ];

      for (var data in testData) {
        final record = DailyRecord(
          userId: userId,
          habitId: 'test-habit-id', // 실제 습관 ID로 변경 필요
          date: data['date'] as DateTime,
          isSuccess: data['isSuccess'] as bool,
          emoji: data['emoji'] as String,
          note: data['note'] as String,
          rewardStamp: (data['isSuccess'] as bool) ? 1 : 0,
        );
        await _repository.createRecord(record);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
