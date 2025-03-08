import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth) : _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signUp(String email, String password) async {
    try {
      print('AuthRepository: 회원가입 시도 - email: $email');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore에 사용자 정보 저장
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        print(
            'AuthRepository: Firestore에 사용자 정보 저장 완료 - uid: ${userCredential.user?.uid}');
      }

      return userCredential;
    } catch (e) {
      print('AuthRepository: 회원가입 실패 - $e');
      rethrow;
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      print('AuthRepository: 로그인 시도 - email: $email');
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('AuthRepository: 로그인 실패 - $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
