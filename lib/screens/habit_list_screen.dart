import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/habit_view_model.dart';
import '../view_models/auth_view_model.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

class HabitListScreen extends ConsumerStatefulWidget {
  const HabitListScreen({super.key});

  @override
  ConsumerState<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends ConsumerState<HabitListScreen> {
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('습관 관리'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context),
        label: const Text('새로운 습관'),
        icon: const Icon(Icons.add),
      ),
      body: habitsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(child: Text('아직 등록된 습관이 없습니다'));
          }
          return ListView.builder(
            itemCount: habits.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final habit = habits[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  title: Text(
                    habit.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      habit.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('습관 삭제'),
                          content: const Text('이 습관을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(habitViewModelProvider.notifier)
                                    .deleteHabit(habit.id);
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
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새로운 습관 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '습관 이름',
                hintText: '예: 금연, 금주 등',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '설명',
                hintText: '습관에 대한 설명을 입력하세요',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final user = ref.read(authViewModelProvider).value;
              if (user == null) return;

              await ref.read(habitViewModelProvider.notifier).createHabit(
                    userId: user.uid,
                    title: titleController.text,
                    description: descriptionController.text,
                  );

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
}
