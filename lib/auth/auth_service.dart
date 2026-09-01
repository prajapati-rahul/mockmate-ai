import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================
  // GOOGLE SIGN-IN
  // =========================
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: <String>[
          'email',
        ],
      );

      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn();

      // User cancelled Google account selection
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential =
          GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // =========================
  // EMAIL LOGIN
  // =========================
  Future<User?> login(
    String email,
    String password,
  ) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return result.user;
  }

  // =========================
  // EMAIL REGISTRATION
  // =========================
  Future<User?> register(
    String email,
    String password,
  ) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return result.user;
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await _auth.signOut();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {
      // Ignore Google sign-out errors
    }
  }

  // =========================
  // PASSWORD RESET
  // =========================
  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      return;
    }

    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  // =========================
  // CURRENT USER
  // =========================
  User? get currentUser => _auth.currentUser;

  // =========================
  // AUTH STATE
  // =========================
  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();
}