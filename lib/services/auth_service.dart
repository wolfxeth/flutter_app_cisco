import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config.dart';

/// Wraps Firebase Authentication and keeps [AppConfig.authToken] in sync with
/// the current user's ID token so the API layer can attach it as a Bearer token.
class AuthService {
  AuthService._() {
    _auth.idTokenChanges().listen(_onIdTokenChanged);
    AppConfig.onUnauthorized = _refreshToken;
  }

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> _onIdTokenChanged(User? user) async {
    AppConfig.authToken = user == null ? null : await user.getIdToken();
  }

  /// Forces a fresh ID token; returns true when a new token was obtained.
  Future<bool> _refreshToken() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final token = await user.getIdToken(true);
    AppConfig.authToken = token;
    return token != null && token.isNotEmpty;
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  Future<void> registerWithEmail(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // user cancelled
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    // Google sign-out can throw when the user logged in via email/password or
    // on web where the plugin isn't initialized; never let it block Firebase sign-out.
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}
