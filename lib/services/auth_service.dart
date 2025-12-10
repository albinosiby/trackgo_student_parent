import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository = AuthRepository();

  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  User? get currentUser => _authRepository.currentUser;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _authRepository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    return await _authRepository.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
