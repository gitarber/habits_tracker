import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habits_provider.dart';
import '../widgets/habit_tile.dart';
import '../models/habit.dart';
import '../widgets/add_habit_dialog.dart';
import '../widgets/add_habit_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load habits when the screen initializes
    Future.microtask(() {
      context.read<HabitsProvider>().loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
      ),
      body: Consumer<HabitsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No habits yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _addTestHabit(context),
                    child: const Text('Add Test Habit'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.habits.length,
            itemBuilder: (context, index) {
              final habit = provider.habits[index];
              return HabitTile(
                habit: habit,
                date: DateTime.now(),
              );
            },
          );
        },
      ),
      floatingActionButton: const AddHabitButton(),
    );
  }

  Future<void> _addTestHabit(BuildContext context) async {
    final habit = Habit(
      title: 'Test Habit ${DateTime.now().millisecondsSinceEpoch}',
      description: 'This is a test habit',
      icon: Icons.fitness_center,
      color: Colors.blue,
    );

    await context.read<HabitsProvider>().addHabit(habit);
  }
}
