class Mood {
  final String id;
  final String userId;
  final String emoji;
  final String description;
  final DateTime createdAt;

  Mood({
    required this.id,
    required this.userId,
    required this.emoji,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'emoji': emoji,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Mood.fromMap(String id, Map<String, dynamic> map) {
    return Mood(
      id: id,
      userId: map['userId'],
      emoji: map['emoji'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Mood copyWith({
    String? id,
    String? userId,
    String? emoji,
    String? description,
    DateTime? createdAt,
  }) {
    return Mood(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
