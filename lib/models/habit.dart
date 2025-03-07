import 'package:uuid/uuid.dart';

class Habit {
  final String id;
  final String userId;
  final String title; // 습관 이름 (예: 술, 택시 등)
  final String description; // 설명
  final bool isActive; // 현재 진행중인 습관인지

  Habit({
    String? id,
    required this.userId,
    required this.title,
    required this.description,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'isActive': isActive,
    };
  }

  factory Habit.fromMap(String id, Map<String, dynamic> map) {
    return Habit(
      id: id,
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      isActive: map['isActive'] ?? true,
    );
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    bool? isActive,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}

class DailyRecord {
  final String id;
  final String userId;
  final String habitId;
  final DateTime date;
  final bool isSuccess; // 성공 여부
  final String emoji; // 그날의 감정
  final String note; // 메모
  final int rewardStamp; // 도장 (1-3개)

  DailyRecord({
    String? id,
    required this.userId,
    required this.habitId,
    required this.date,
    required this.isSuccess,
    required this.emoji,
    required this.note,
    required this.rewardStamp,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'habitId': habitId,
      'date': date.toIso8601String(),
      'isSuccess': isSuccess,
      'emoji': emoji,
      'note': note,
      'rewardStamp': rewardStamp,
    };
  }

  factory DailyRecord.fromMap(String id, Map<String, dynamic> map) {
    return DailyRecord(
      id: id,
      userId: map['userId'] as String,
      habitId: map['habitId'] as String,
      date: DateTime.parse(map['date'] as String),
      isSuccess: map['isSuccess'] as bool,
      emoji: map['emoji'] as String,
      note: map['note'] as String,
      rewardStamp: map['rewardStamp'] as int,
    );
  }

  DailyRecord copyWith({
    String? id,
    String? userId,
    String? habitId,
    DateTime? date,
    bool? isSuccess,
    String? emoji,
    String? note,
    int? rewardStamp,
  }) {
    return DailyRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isSuccess: isSuccess ?? this.isSuccess,
      emoji: emoji ?? this.emoji,
      note: note ?? this.note,
      rewardStamp: rewardStamp ?? this.rewardStamp,
    );
  }
}
