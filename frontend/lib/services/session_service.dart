/// Simple in-memory session holder. Replace with `shared_preferences` /
/// secure storage when you wire the real API.
///
/// ⚠️ HUMAN INPUT NEEDED:
///   - Decide whether you want persistent login (app reopens logged in).
///     If yes, add the `shared_preferences` or `flutter_secure_storage`
///     package to pubspec.yaml and persist [currentRole] + [userId] here.
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  String? currentRole; // 'CUSTOMER' | 'PROVIDER' | 'ADMIN'
  int? userId;
  String? displayName;
  String? email;

  bool get isLoggedIn => currentRole != null;

  void saveSession({
    required String role,
    int? userId,
    String? displayName,
    String? email,
  }) {
    currentRole = role.toUpperCase();
    this.userId = userId;
    this.displayName = displayName;
    this.email = email;
  }

  void clear() {
    currentRole = null;
    userId = null;
    displayName = null;
    email = null;
  }
}
