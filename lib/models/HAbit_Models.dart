class HabitModel {
  final String id;
  String name;
  bool isCompleted;
  final DateTime createdAt;
  DateTime? completedAt;

  HabitModel({
    required this.id,
    required this.name,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
  });

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      isCompleted: map['is_completed'] ?? false,
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(map['created_at'])
              : DateTime.now(),
      completedAt:
          map['completed_at'] != null
              ? DateTime.parse(map['completed_at'])
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  // Convert to the current format used in the app
  List<dynamic> toLocalFormat() {
    return [name, isCompleted];
  }

  // Create from the current list format used in the app
  factory HabitModel.fromLocalFormat(List<dynamic> data) {
    return HabitModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: data[0],
      isCompleted: data[1],
      createdAt: DateTime.now(),
    );
  }
}
