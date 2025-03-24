import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../providers/habits_provider.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final DateTime date;

  const HabitTile({
    super.key,
    required this.habit,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitsProvider>(
      builder: (context, provider, child) {
        final habitLogs = provider.habitLogs[habit.id] ?? [];
        final todayLog = habitLogs.firstWhere(
          (log) =>
              log.date.year == date.year &&
              log.date.month == date.month &&
              log.date.day == date.day,
          orElse: () => HabitLog(
            habitId: habit.id,
            date: DateTime(date.year, date.month, date.day),
          ),
        );

        return Card(
          child: InkWell(
            onTap: () => _showHabitDetails(context),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    habit.icon ?? Icons.check_circle_outline,
                    color: habit.color ?? Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (habit.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            habit.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Checkbox(
                    value: todayLog.isCompleted,
                    onChanged: (bool? value) {
                      provider.toggleHabitCompletion(habit.id, date);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHabitDetails(BuildContext context) {
    // TODO: Implement habit details modal
  }
}
