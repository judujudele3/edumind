import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/schedule_repository.dart';
import '../../../shared/models/schedule_model.dart';
import '../../auth/providers/auth_provider.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository();
});

final scheduleProvider = StreamProvider<List<ScheduleModel>>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final user = auth.currentUser;
  if (user == null) return const Stream.empty();
  return ref.read(scheduleRepositoryProvider).getSchedule(user.uid);
});

class ScheduleNotifier extends StateNotifier<AsyncValue<void>> {
  final ScheduleRepository _repository;

  ScheduleNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addSlot(ScheduleModel slot) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.addSlot(slot));
  }

  Future<void> deleteSlot(String slotId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteSlot(slotId));
  }
}

final scheduleNotifierProvider =
    StateNotifierProvider<ScheduleNotifier, AsyncValue<void>>((ref) {
  return ScheduleNotifier(ref.read(scheduleRepositoryProvider));
});