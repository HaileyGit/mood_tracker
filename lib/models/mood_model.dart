class MoodModel {
  final String id;
  final String userId;
  final String emoji;
  final String description;
  final DateTime createdAt;

  MoodModel({
    required this.id,
    required this.userId,
    required this.emoji,
    required this.description,
    required this.createdAt,
  });

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      emoji: json['emoji'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'emoji': emoji,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
