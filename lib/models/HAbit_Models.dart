// class HabitModel {
//   final String? id;
//   final String userId;
//   String name;
//   bool isCompleted;
//   final DateTime createdAt;
//   DateTime? completedAt;

//   HabitModel({
//     required this.id,
//     required this.userId,
//     required this.name,
//     required this.isCompleted,
//     required this.createdAt,
//     this.completedAt,
//   });

//   factory HabitModel.fromMap(Map<String, dynamic> map) {
//     return HabitModel(
//       id: map['id'],
//       userId: map['user_id'],
//       name: map['name'],
//       isCompleted: map['is_completed'] ?? false,
//       createdAt: DateTime.parse(map['created_at']),
//       completedAt:
//           map['completed_at'] != null
//               ? DateTime.parse(map['completed_at'])
//               : null,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       if (id != null) 'id': id,
//       'user_id': userId,
//       'name': name,
//       'is_completed': isCompleted,
//       'created_at': createdAt.toIso8601String(),
//       'completed_at': completedAt?.toIso8601String(),
//     };
//   }

//   List<dynamic> toLocalFormat() {
//     return [name, isCompleted];
//   }
// }
