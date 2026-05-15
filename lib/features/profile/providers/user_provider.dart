import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_repository.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final userProvider = FutureProvider<UserModel?>((ref) async {
  final auth = ref.watch(firebaseAuthProvider);
  final user = auth.currentUser;
  if (user == null) return null;
  return ref.read(userRepositoryProvider).getUser(user.uid);
});

class UserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createUser(UserModel user) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createUser(user);
      return user;
    });
  }

  Future<void> updateUser(UserModel user) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateUser(user);
      return user;
    });
  }
}

final userNotifierProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<UserModel?>>((ref) {
  return UserNotifier(ref.read(userRepositoryProvider));
});