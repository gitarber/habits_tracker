import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../services/database_service.dart';

class HabitsProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Habit> _habits = [];
  Map<String, List<HabitLog>> _habitLogs = {};
  bool _isLoading = true;

  List<Habit> get habits => _habits;
  Map<String, List<HabitLog>> get habitLogs => _habitLogs;
  bool get isLoading => _isLoading;

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _databaseService.getHabits();
      for (var habit in _habits) {
        await loadHabitLogs(habit.id);
      }
    } catch (e) {
      debugPrint('Error loading habits: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadHabitLogs(String habitId) async {
    try {
      final logs = await _databaseService.getHabitLogs(habitId);
      _habitLogs[habitId] = logs;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading habit logs: $e');
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      await _databaseService.insertHabit(habit);
      _habits.add(habit);
      _habitLogs[habit.id] = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding habit: $e');
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _databaseService.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating habit: $e');
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _databaseService.deleteHabit(id);
      _habits.removeWhere((habit) => habit.id == id);
      _habitLogs.remove(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting habit: $e');
    }
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    try {
      final logs = _habitLogs[habitId] ?? [];
      final existingLog = logs.firstWhere(
        (log) =>
            log.date.year == date.year &&
            log.date.month == date.month &&
            log.date.day == date.day,
        orElse: () => HabitLog(
          habitId: habitId,
          date: DateTime(date.year, date.month, date.day),
        ),
      );

      final updatedLog = existingLog.copyWith(
        isCompleted: !existingLog.isCompleted,
      );

      if (existingLog.id == updatedLog.id) {
        await _databaseService.updateHabitLog(updatedLog);
        final logIndex = logs.indexWhere((log) => log.id == updatedLog.id);
        logs[logIndex] = updatedLog;
      } else {
        await _databaseService.insertHabitLog(updatedLog);
        logs.add(updatedLog);
      }

      _habitLogs[habitId] = logs;
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling habit completion: $e');
    }
  }

  Future<void> addHabitNote(String habitId, DateTime date, String note) async {
    try {
      final logs = _habitLogs[habitId] ?? [];
      final existingLog = logs.firstWhere(
        (log) =>
            log.date.year == date.year &&
            log.date.month == date.month &&
            log.date.day == date.day,
        orElse: () => HabitLog(
          habitId: habitId,
          date: DateTime(date.year, date.month, date.day),
        ),
      );

      final updatedLog = existingLog.copyWith(notes: note);

      if (existingLog.id == updatedLog.id) {
        await _databaseService.updateHabitLog(updatedLog);
        final logIndex = logs.indexWhere((log) => log.id == updatedLog.id);
        logs[logIndex] = updatedLog;
      } else {
        await _databaseService.insertHabitLog(updatedLog);
        logs.add(updatedLog);
      }

      _habitLogs[habitId] = logs;
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding habit note: $e');
    }
  }
}
