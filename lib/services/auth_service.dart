import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  String get currentUserId => _auth.currentUser?.uid ?? '';
  String get currentUserEmail => _auth.currentUser?.email ?? '';
  String get currentUserInitials {
    final email = _auth.currentUser?.email ?? '';
    if (email.isEmpty) return '?';
    return email.substring(0, 2).toUpperCase();
  }

  Future<AuthResult> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password.trim());
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapError(e.code));
    } catch (_) {
      return AuthResult.failure('An unexpected error occurred.');
    }
  }

  Future<AuthResult> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapError(e.code));
    } catch (_) {
      return AuthResult.failure('An unexpected error occurred.');
    }
  }

  Future<void> signOut() async => _auth.signOut();

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':        return 'No account found with this email.';
      case 'wrong-password':        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':  return 'This email is already registered.';
      case 'invalid-email':         return 'Please enter a valid email address.';
      case 'weak-password':         return 'Password must be at least 6 characters.';
      case 'network-request-failed':return 'No internet connection.';
      case 'too-many-requests':     return 'Too many attempts. Try again later.';
      default:                      return 'Something went wrong. Please try again.';
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  const AuthResult._({required this.isSuccess, this.errorMessage});
  factory AuthResult.success() => const AuthResult._(isSuccess: true);
  factory AuthResult.failure(String msg) => AuthResult._(isSuccess: false, errorMessage: msg);
}
