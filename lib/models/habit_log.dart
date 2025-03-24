import 'package:uuid/uuid.dart';

class HabitLog {
  final String id;
  final String habitId;
  final DateTime date;
  final bool isCompleted;
  final String? notes;

  HabitLog({
    String? id,
    required this.habitId,
    required this.date,
    this.isCompleted = false,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'notes': notes,
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'],
      habitId: map['habit_id'],
      date: DateTime.parse(map['date']),
      isCompleted: map['is_completed'] == 1,
      notes: map['notes'],
    );
  }

  HabitLog copyWith({
    bool? isCompleted,
    String? notes,
  }) {
    return HabitLog(
      id: id,
      habitId: habitId,
      date: date,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }
}
