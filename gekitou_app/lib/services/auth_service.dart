import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  User? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;

    return User(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: user.metadata.lastSignInTime,
    );
  }

  bool get isAuthenticated => _auth.currentUser != null;

  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();

      final user = credential.user;
      if (user == null) throw Exception('User creation failed');

      return User(
        uid: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<User> login({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Login failed');

      return User(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: user.metadata.lastSignInTime,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  Future<String?> getIdToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'Email already registered. Please login or use another email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
