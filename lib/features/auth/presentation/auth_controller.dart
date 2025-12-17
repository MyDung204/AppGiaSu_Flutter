import 'dart:async';
import 'package:doantotnghiep/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial state implementation needed
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password);
      // Role is already handled/cached in signIn
    });
  }

  Future<void> register(String email, String password, String role) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final name = email.split('@')[0]; 
      await ref.read(authRepositoryProvider).signUpWithEmailAndPassword(name, email, password, role);
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).signOut());
  }
}
