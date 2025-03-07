import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/mood_view_model.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  final _descriptionController = TextEditingController();
  String _selectedEmoji = '😊'; // 기본 이모지

  static const List<String> _emojis = [
    '😊',
    '😃',
    '😄',
    '🥰',
    '😍',
    '😢',
    '😭',
    '😤',
    '😠',
    '😡',
    '😌',
    '😴',
    '🤔',
    '🤨',
    '😐',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새로운 감정 기록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '지금 기분이 어떠신가요?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('감정 선택:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojis.map((emoji) {
                return InkWell(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: emoji == _selectedEmoji
                            ? Colors.blue
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 32)),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final user = ref.read(authViewModelProvider).value;
                if (user == null) return;

                await ref.read(moodViewModelProvider.notifier).createMood(
                      userId: user.uid,
                      emoji: _selectedEmoji,
                      description: _descriptionController.text,
                    );

                if (context.mounted) {
                  context.go('/home');
                }
              },
              child: const Text('기록하기'),
            ),
          ],
        ),
      ),
    );
  }
}
