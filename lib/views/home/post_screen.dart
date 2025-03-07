import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _descriptionController = TextEditingController();
  String _selectedEmoji = '😊';

  final List<String> _emojis = ['😊', '😢', '😡', '😴', '🤔', '😎'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 무드 작성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '오늘의 기분을 설명해주세요',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _emojis
                  .map(
                    (emoji) => ChoiceChip(
                      label: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      selected: _selectedEmoji == emoji,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedEmoji = emoji;
                          });
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: 무드 저장 로직 구현
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            context.go('/home');
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

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
