import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/mood_view_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodState = ref.watch(moodViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authViewModelProvider.notifier).signOut();
              context.go('/signin');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: moodState.when(
        data: (moods) {
          if (moods.isEmpty) {
            return const Center(
              child: Text('아직 기록된 무드가 없습니다.'),
            );
          }

          return ListView.builder(
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              return ListTile(
                leading: Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(mood.description),
                subtitle: Text(
                  '${mood.createdAt.year}/${mood.createdAt.month}/${mood.createdAt.day}',
                ),
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('삭제'),
                      content: const Text('이 무드를 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(moodViewModelProvider.notifier)
                                .deleteMood(mood.id);
                            Navigator.pop(context);
                          },
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            context.go('/post');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '작성',
          ),
        ],
      ),
    );
  }
}
