import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../main.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<User?>>((ref) {
  return AuthViewModel(AuthRepository(auth));
});

class AuthViewModel extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthViewModel(this._repository) : super(const AsyncValue.data(null)) {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      state = AsyncValue.data(user);
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      print('AuthViewModel: 로그인 시작');

      final credential = await _repository.signIn(email, password);
      print('AuthViewModel: 로그인 성공 - uid: ${credential.user?.uid}');

      state = AsyncValue.data(credential.user);
    } catch (e) {
      print('AuthViewModel: 로그인 실패 - $e');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      print('AuthViewModel: 회원가입 시작');

      final credential = await _repository.signUp(email, password);
      print('AuthViewModel: 회원가입 성공 - uid: ${credential.user?.uid}');

      state = AsyncValue.data(credential.user);
    } catch (e) {
      print('AuthViewModel: 회원가입 실패 - $e');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _repository.signOut();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
