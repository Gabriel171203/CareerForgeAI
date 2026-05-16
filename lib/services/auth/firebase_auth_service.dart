import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmailPassword({
    required String email, 
    required String password, 
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await credential.user?.updateDisplayName(displayName);
    await credential.user?.reload(); // Refresh local user data
    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
