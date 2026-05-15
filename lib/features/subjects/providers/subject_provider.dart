import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/subject_repository.dart';
import '../../../shared/models/subject_model.dart';
import '../../auth/providers/auth_provider.dart';

final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return SubjectRepository();
});

final subjectsProvider = StreamProvider<List<SubjectModel>>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final user = auth.currentUser;
  if (user == null) return const Stream.empty();
  return ref.read(subjectRepositoryProvider).getSubjects(user.uid);
});

class SubjectNotifier extends StateNotifier<AsyncValue<void>> {
  final SubjectRepository _repository;

  SubjectNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addSubject(SubjectModel subject) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.addSubject(subject));
  }

  Future<void> updateSubject(SubjectModel subject) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateSubject(subject));
  }

  Future<void> deleteSubject(String subjectId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteSubject(subjectId));
  }
}

final subjectNotifierProvider =
    StateNotifierProvider<SubjectNotifier, AsyncValue<void>>((ref) {
  return SubjectNotifier(ref.read(subjectRepositoryProvider));
});