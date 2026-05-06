import 'package:firebase_auth/firebase_auth.dart';

/// Wraps Firebase Authentication.
/// All methods return simple results so the UI never imports Firebase directly.
/// When migrating to FastAPI: replace method bodies only — signatures stay the same.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Stream of auth state changes ─────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Current user ──────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  String get currentUserEmail => _auth.currentUser?.email ?? '';

  /// Returns initials from the email address for the avatar placeholder
  String get currentUserInitials {
    final email = _auth.currentUser?.email ?? '';
    if (email.isEmpty) return '?';
    return email.substring(0, 2).toUpperCase();
  }

  // ── Sign up ───────────────────────────────────────────────────────────────
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapError(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred.');
    }
  }

  // ── Sign in ───────────────────────────────────────────────────────────────
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapError(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred.');
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Reset password ────────────────────────────────────────────────────────
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapError(e.code));
    }
  }

  // ── Map Firebase error codes to user-friendly messages ───────────────────
  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

// ── Simple result wrapper ─────────────────────────────────────────────────────
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;

  const AuthResult._({required this.isSuccess, this.errorMessage});

  factory AuthResult.success()               => const AuthResult._(isSuccess: true);
  factory AuthResult.failure(String message) => AuthResult._(isSuccess: false, errorMessage: message);
}