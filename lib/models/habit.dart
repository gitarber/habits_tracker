import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Habit {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final TimeOfDay? reminderTime;
  final Color? color;
  final IconData? icon;
  final int streak;
  final int totalCompletions;

  Habit({
    String? id,
    required this.title,
    this.description,
    DateTime? createdAt,
    this.reminderTime,
    this.color,
    this.icon,
    this.streak = 0,
    this.totalCompletions = 0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'reminder_time': reminderTime != null
          ? '${reminderTime!.hour}:${reminderTime!.minute}'
          : null,
      'color': color?.value,
      'icon': icon?.codePoint,
      'streak': streak,
      'total_completions': totalCompletions,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    TimeOfDay? reminderTime;
    if (map['reminder_time'] != null) {
      final parts = (map['reminder_time'] as String).split(':');
      if (parts.length == 2) {
        reminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    return Habit(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      reminderTime: reminderTime,
      color: map['color'] != null ? Color(map['color']) : null,
      icon: map['icon'] != null
          ? IconData(map['icon'], fontFamily: 'MaterialIcons')
          : null,
      streak: map['streak'] ?? 0,
      totalCompletions: map['total_completions'] ?? 0,
    );
  }

  Habit copyWith({
    String? title,
    String? description,
    TimeOfDay? reminderTime,
    Color? color,
    IconData? icon,
    int? streak,
    int? totalCompletions,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      reminderTime: reminderTime ?? this.reminderTime,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      streak: streak ?? this.streak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
    );
  }
}
