import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/habit_view_model.dart';
import '../view_models/daily_record_view_model.dart';
import '../view_models/auth_view_model.dart';
import 'package:go_router/go_router.dart';

class DailyRecordScreen extends ConsumerStatefulWidget {
  const DailyRecordScreen({super.key});

  @override
  ConsumerState<DailyRecordScreen> createState() => _DailyRecordScreenState();
}

class _DailyRecordScreenState extends ConsumerState<DailyRecordScreen> {
  final _noteController = TextEditingController();
  String _selectedEmoji = '😊';
  final List<String> _emojis = ['😊', '😃', '😔', '😣', '😴', '😎'];
  final List<String> _selectedHabits = [];
  bool _isSuccess = true;

  // 감정 데이터 정의
  final List<Map<String, dynamic>> _moods = [
    {
      'emoji': '😡',
      'color': Colors.red,
      'text': 'Bad',
      'value': 1,
    },
    {
      'emoji': '😔',
      'color': Colors.orange,
      'text': 'Not Good',
      'value': 2,
    },
    {
      'emoji': '😊',
      'color': Colors.yellow,
      'text': 'Okay',
      'value': 3,
    },
    {
      'emoji': '😄',
      'color': Colors.lightGreen,
      'text': 'Good',
      'value': 4,
    },
    {
      'emoji': '🥰',
      'color': Colors.green,
      'text': 'Great',
      'value': 5,
    },
  ];

  int _selectedMoodIndex = 2; // 기본값 'Okay'

  @override
  void initState() {
    super.initState();
    final user = ref.read(authViewModelProvider).value;
    if (user != null) {
      ref.read(habitViewModelProvider.notifier).loadUserHabits(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsState = ref.watch(habitViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('오늘의 기록'),
        actions: [
          TextButton(
            onPressed: _saveRecord,
            child: const Text('저장'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 큰 이모지 표시
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    _moods[_selectedMoodIndex]['emoji'],
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _moods[_selectedMoodIndex]['text'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 감정 선택 슬라이더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 배경 게이지
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _moods.map((m) => m['color'] as Color).toList(),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  // 슬라이더
                  SliderTheme(
                    data: SliderThemeData(
                      thumbShape: CustomSliderThumbShape(
                        emoji: _moods[_selectedMoodIndex]['emoji'],
                      ),
                      overlayShape: SliderComponentShape.noOverlay,
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                    ),
                    child: Slider(
                      min: 0,
                      max: 4,
                      value: _selectedMoodIndex.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMoodIndex = value.round();
                          _selectedEmoji = _moods[_selectedMoodIndex]['emoji'];
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 오늘의 기분 텍스트
            Center(
              child: Text(
                _isSuccess ? '오늘은 성공!' : '오늘은 실패...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isSuccess ? Colors.green : Colors.red,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 날짜 표시
            Center(
              child: Text(
                '${DateTime.now().year}년 ${DateTime.now().month}월 ${DateTime.now().day}일',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 습관 선택
            habitsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (habits) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: habits.map((habit) {
                  final isSelected = _selectedHabits.contains(habit.id);
                  return FilterChip(
                    label: Text(habit.title),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedHabits.add(habit.id);
                        } else {
                          _selectedHabits.remove(habit.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // 성공/실패 토글
            SwitchListTile(
              title: const Text('오늘 성공했나요?'),
              value: _isSuccess,
              onChanged: (value) => setState(() => _isSuccess = value),
            ),

            const SizedBox(height: 16),

            // 메모 입력
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '메모',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  void _saveRecord() async {
    if (_selectedHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('하나 이상의 습관을 선택해주세요')),
      );
      return;
    }

    final user = ref.read(authViewModelProvider).value;
    if (user == null) return;

    // 선택된 각 습관에 대해 기록 생성
    for (final habitId in _selectedHabits) {
      await ref.read(dailyRecordViewModelProvider.notifier).createRecord(
            userId: user.uid,
            habitId: habitId,
            isSuccess: _isSuccess,
            emoji: _selectedEmoji,
            note: _noteController.text,
            rewardStamp: _isSuccess ? 1 : 0,
          );
    }

    if (mounted) {
      context.go('/home');
    }
  }
}

// 커스텀 슬라이더 썸브 모양
class CustomSliderThumbShape extends SliderComponentShape {
  final String emoji;

  CustomSliderThumbShape({required this.emoji});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(30, 30);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final canvas = context.canvas;

    // 흰색 원형 배경
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 15, paint);

    // 이모지 텍스트
    final textSpan = TextSpan(
      text: emoji,
      style: const TextStyle(fontSize: 20),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textCenter = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textCenter);
  }
}
