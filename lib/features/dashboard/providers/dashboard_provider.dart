import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tasks/providers/task_provider.dart';
import '../../schedule/providers/schedule_provider.dart';
import '../../subjects/providers/subject_provider.dart';

final todayScheduleProvider = Provider((ref) {
  final scheduleAsync = ref.watch(scheduleProvider);
  final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  final today = days[DateTime.now().weekday - 1];

  return scheduleAsync.maybeWhen(
    data: (slots) => slots
        .where((s) => s.day == today)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime)),
    orElse: () => [],
  );
});

final pendingTasksProvider = Provider((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.maybeWhen(
    data: (tasks) => tasks.where((t) => t.status == 'todo').toList(),
    orElse: () => [],
  );
});

final urgentTasksProvider = Provider((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final now = DateTime.now();
  return tasksAsync.maybeWhen(
    data: (tasks) => tasks
        .where((t) =>
            t.status == 'todo' &&
            t.dueDate.difference(now).inDays <= 3)
        .toList(),
    orElse: () => [],
  );
});