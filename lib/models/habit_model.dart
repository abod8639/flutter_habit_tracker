import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class HabitModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime? completedAt;

  @HiveField(5)
  int? colorValue;

  HabitModel({
    String? id,
    required this.name,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
    this.colorValue,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
      colorValue: map['color_value'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'color_value': colorValue,
    };
  }

  // Deprecated: Used for migration from old list format
  List<dynamic> toLocalFormat() {
    return [name, isCompleted];
  }

  // Deprecated: Used for migration from old list format
  factory HabitModel.fromLocalFormat(List<dynamic> data) {
    return HabitModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: data[0],
      isCompleted: data[1],
      createdAt: DateTime.now(),
    );
  }
}

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 0;

  @override
  HabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      isCompleted: fields[2] as bool,
      createdAt: fields[3] as DateTime,
      completedAt: fields[4] as DateTime?,
      colorValue: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.completedAt)
      ..writeByte(5)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
