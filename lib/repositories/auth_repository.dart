import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood_tracker/main.dart'; // auth 변수를 사용하기 위해 추가

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth) : _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signUp(String email, String password) async {
    try {
      print('AuthRepository: 회원가입 시도 - email: $email');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('AuthRepository: Authentication 성공 - uid: ${credential.user?.uid}');

      // Firestore에 사용자 정보 저장
      try {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('AuthRepository: Firestore 사용자 정보 저장 성공');
      } catch (e) {
        print('AuthRepository: Firestore 저장 실패 - $e');
        // Firestore 저장 실패 시에도 회원가입은 성공한 것으로 처리
      }

      return credential;
    } catch (e) {
      print('AuthRepository: 회원가입 실패 - $e');
      rethrow; // 에러를 상위로 전달
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      print('AuthRepository: 로그인 시도 - email: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('AuthRepository: 로그인 성공 - uid: ${credential.user?.uid}');
      return credential;
    } catch (e) {
      print('AuthRepository: 로그인 실패 - $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
