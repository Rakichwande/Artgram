import '../services/auth_service.dart';

/// AuthRepository sits between screens and AuthService.
/// 
/// WHY THIS EXISTS:
///   Screens call AuthRepository — never AuthService directly.
///   When Phase 2 arrives, only AuthService changes.
///   AuthRepository and all screens stay exactly the same.
/// 
/// Phase 1: delegates to Firebase AuthService
/// Phase 2: AuthService will call FastAPI instead — zero screen changes
class AuthRepository {
  final AuthService _service;

  AuthRepository({AuthService? service}) : _service = service ?? AuthService();

  Future<AuthResult> signIn({required String email, required String password}) {
    return _service.signIn(email: email, password: password);
  }

  Future<AuthResult> signUp({required String email, required String password}) {
    return _service.signUp(email: email, password: password);
  }

  Future<void> signOut() => _service.signOut();

  String get currentUserId      => _service.currentUserId;
  String get currentUserEmail   => _service.currentUserEmail;
  String get currentUserInitials => _service.currentUserInitials;

  Stream<dynamic> get authStateChanges => _service.authStateChanges;
}
