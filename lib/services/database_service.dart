import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  static SharedPreferences? _prefs;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<void> initDatabase() async {
    if (kIsWeb) {
      await initPrefs();
    } else {
      // For desktop/mobile platforms
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      await _initDatabase();
    }
  }

  Future<void> initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb)
      throw UnsupportedError(
          'Web platform uses SharedPreferences instead of SQLite');

    String path = join(await getDatabasesPath(), 'habits_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE habits(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            created_at INTEGER NOT NULL,
            reminder_time TEXT,
            color INTEGER,
            icon INTEGER,
            streak INTEGER DEFAULT 0,
            total_completions INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE habit_logs(
            id TEXT PRIMARY KEY,
            habit_id TEXT NOT NULL,
            date TEXT NOT NULL,
            is_completed INTEGER DEFAULT 0,
            notes TEXT,
            FOREIGN KEY (habit_id) REFERENCES habits (id)
          )
        ''');
      },
    );
  }

  Future<void> _saveHabitsToPrefs(List<Habit> habits) async {
    if (!kIsWeb) return;
    await initPrefs();
    final habitsJson = habits.map((h) => h.toMap()).toList();
    await _prefs!.setString('habits', jsonEncode(habitsJson));
  }

  Future<List<Habit>> _loadHabitsFromPrefs() async {
    if (!kIsWeb) return [];
    await initPrefs();
    final habitsJson = _prefs!.getString('habits');
    if (habitsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(habitsJson);
    return decoded
        .map((json) => Habit.fromMap(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<List<Habit>> getHabits() async {
    if (kIsWeb) {
      return _loadHabitsFromPrefs();
    } else {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query('habits');
      return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
    }
  }

  Future<void> insertHabit(Habit habit) async {
    if (kIsWeb) {
      final habits = await _loadHabitsFromPrefs();
      habits.add(habit);
      await _saveHabitsToPrefs(habits);
    } else {
      final Database db = await database;
      await db.insert(
        'habits',
        habit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> updateHabit(Habit habit) async {
    if (kIsWeb) {
      final habits = await _loadHabitsFromPrefs();
      final index = habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        habits[index] = habit;
        await _saveHabitsToPrefs(habits);
      }
    } else {
      final Database db = await database;
      await db.update(
        'habits',
        habit.toMap(),
        where: 'id = ?',
        whereArgs: [habit.id],
      );
    }
  }

  Future<void> deleteHabit(String id) async {
    if (kIsWeb) {
      final habits = await _loadHabitsFromPrefs();
      habits.removeWhere((h) => h.id == id);
      await _saveHabitsToPrefs(habits);
    } else {
      final Database db = await database;
      await db.delete(
        'habits',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // HabitLog CRUD operations
  Future<void> insertHabitLog(HabitLog log) async {
    if (kIsWeb) {
      await initPrefs();
      final logs = await getHabitLogs(log.habitId);
      logs.add(log);
      await _saveHabitLogs(log.habitId, logs);
    } else {
      final db = await database;
      await db.insert(
        'habit_logs',
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<HabitLog>> getHabitLogs(String habitId, {DateTime? date}) async {
    if (kIsWeb) {
      await initPrefs();
      final logsJson = _prefs!.getString('habit_logs_$habitId');
      if (logsJson == null) return [];

      final List<dynamic> logsList = jsonDecode(logsJson);
      final logs = logsList
          .map((json) => HabitLog.fromMap(Map<String, dynamic>.from(json)))
          .toList();

      if (date != null) {
        return logs
            .where((log) =>
                log.date.year == date.year &&
                log.date.month == date.month &&
                log.date.day == date.day)
            .toList();
      }
      return logs;
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'habit_logs',
        where: date == null ? 'habitId = ?' : 'habitId = ? AND date = ?',
        whereArgs: date == null ? [habitId] : [habitId, date.toIso8601String()],
      );
      return List.generate(maps.length, (i) => HabitLog.fromMap(maps[i]));
    }
  }

  Future<void> _saveHabitLogs(String habitId, List<HabitLog> logs) async {
    await _prefs!.setString(
        'habit_logs_$habitId',
        jsonEncode(
          logs.map((log) => log.toMap()).toList(),
        ));
  }

  Future<void> updateHabitLog(HabitLog log) async {
    if (kIsWeb) {
      await initPrefs();
      final logs = await getHabitLogs(log.habitId);
      final index = logs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        logs[index] = log;
        await _saveHabitLogs(log.habitId, logs);
      }
    } else {
      final db = await database;
      await db.update(
        'habit_logs',
        log.toMap(),
        where: 'id = ?',
        whereArgs: [log.id],
      );
    }
  }

  Future<void> deleteHabitLog(String id, String habitId) async {
    if (kIsWeb) {
      await initPrefs();
      final logs = await getHabitLogs(habitId);
      logs.removeWhere((log) => log.id == id);
      await _saveHabitLogs(habitId, logs);
    } else {
      final db = await database;
      await db.delete(
        'habit_logs',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
}
