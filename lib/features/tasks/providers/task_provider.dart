import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/task_repository.dart';
import '../../../shared/models/task_model.dart';
import '../../auth/providers/auth_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final tasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final user = auth.currentUser;
  if (user == null) return const Stream.empty();
  return ref.read(taskRepositoryProvider).getTasks(user.uid);
});

class TaskNotifier extends StateNotifier<AsyncValue<void>> {
  final TaskRepository _repository;

  TaskNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addTask(TaskModel task) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.addTask(task));
  }

  Future<void> updateTask(TaskModel task) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateTask(task));
  }

  Future<void> deleteTask(String taskId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteTask(taskId));
  }
}

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<void>>((ref) {
  return TaskNotifier(ref.read(taskRepositoryProvider));
});