import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/mood_view_model.dart';
import 'package:table_calendar/table_calendar.dart';
import '../view_models/daily_record_view_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  static const List<String> _tabs = ['home', 'record', 'habits'];
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isLoading = true; // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = ref.read(authViewModelProvider).value;
      if (user != null) {
        await ref
            .read(dailyRecordViewModelProvider.notifier)
            .loadMonthRecords(user.uid, _focusedDay);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        context.go('/auth');
      }
    });
  }

  void _onTap(int index) {
    context.go("/${_tabs[index]}");
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dailyRecordsState = ref.watch(dailyRecordViewModelProvider);

    print(
        '🏠 HomeScreen build - dailyRecordsState: $dailyRecordsState'); // 로그 추가

    final moodsState = ref.watch(moodViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('나쁜 습관 버리기'),
        actions: [
          // 테스트 데이터 생성 버튼
          IconButton(
            icon: const Icon(Icons.add_chart),
            onPressed: () async {
              final user = ref.read(authViewModelProvider).value;
              if (user != null) {
                await ref
                    .read(dailyRecordViewModelProvider.notifier)
                    .createTestData(user.uid);
                // 테스트 데이터 생성 후 월별 데이터 로드
                ref
                    .read(dailyRecordViewModelProvider.notifier)
                    .loadMonthRecords(user.uid, _focusedDay);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authViewModelProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 캘린더 위젯
                TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    final user = ref.read(authViewModelProvider).value;
                    if (user != null) {
                      // 날짜가 바뀔 때마다 해당 월의 데이터 로드
                      if (selectedDay.month != _focusedDay.month) {
                        ref
                            .read(dailyRecordViewModelProvider.notifier)
                            .loadMonthRecords(user.uid, selectedDay);
                      }
                    }
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                    final user = ref.read(authViewModelProvider).value;
                    if (user != null) {
                      ref
                          .read(dailyRecordViewModelProvider.notifier)
                          .loadMonthRecords(user.uid, focusedDay);
                    }
                  },
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(color: Colors.red),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      return Center(
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    },
                    markerBuilder: (context, date, events) {
                      return dailyRecordsState.when(
                        loading: () => null,
                        error: (_, __) => null,
                        data: (records) {
                          final dayRecords = records
                              .where((record) => isSameDay(record.date, date))
                              .toList();

                          if (dayRecords.isEmpty) return null;

                          // 성공한 기록이 있으면 초록색, 실패한 기록만 있으면 빨간색
                          final hasSuccess = dayRecords.any((r) => r.isSuccess);
                          final color = hasSuccess ? Colors.green : Colors.red;

                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withOpacity(0.8),
                            ),
                            child: Center(
                              child: Text(
                                dayRecords.first.emoji,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    todayBuilder: (context, date, _) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 리스트 뷰
                Expanded(
                  child: dailyRecordsState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('데이터를 불러오는데 실패했습니다: $error'),
                    ),
                    data: (records) {
                      final selectedDayRecords = records
                          .where(
                              (record) => isSameDay(record.date, _selectedDay))
                          .toList();

                      if (selectedDayRecords.isEmpty) {
                        return const Center(
                          child: Text('선택한 날짜의 기록이 없습니다'),
                        );
                      }

                      return ListView.builder(
                        itemCount: selectedDayRecords.length,
                        itemBuilder: (context, index) {
                          final record = selectedDayRecords[index];
                          return ListTile(
                            leading: Text(record.emoji,
                                style: const TextStyle(fontSize: 24)),
                            title: Text(record.note),
                            subtitle: Text(
                              record.isSuccess ? '성공' : '실패',
                              style: TextStyle(
                                color: record.isSuccess
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('기록 삭제'),
                                    content: const Text('이 기록을 삭제하시겠습니까?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          ref
                                              .read(dailyRecordViewModelProvider
                                                  .notifier)
                                              .deleteRecord(record.id);
                                          Navigator.pop(context);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.error,
                                        ),
                                        child: const Text('삭제'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: '오늘의 기록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '습관 관리',
          ),
        ],
      ),
    );
  }
}
