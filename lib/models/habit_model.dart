class Habit {
  final String? id;
  final String userId;
  final String name;
  bool completed;
  final DateTime createdAt;
  
  Habit({
    this.id,
    required this.userId,
    required this.name,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      completed: json['completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'completed': completed,
    };
  }
}