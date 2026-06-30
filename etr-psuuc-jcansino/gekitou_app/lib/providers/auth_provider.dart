import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _authService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser != null) {
        if (_currentUser == null) {
          _loadUserData(firebaseUser.uid);
        }
      } else {
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
      }
    });
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      await _firestoreService.createUserDocument(user.uid, user);

      final userData = await _firestoreService.getUserData(user.uid);
      _currentUser = userData ?? user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.login(email: email, password: password);

      await _firestoreService.updateLastLogin(user.uid);

      final userData = await _firestoreService.getUserData(user.uid);
      _currentUser = userData ?? user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.logout();

      _currentUser = null;
      _isAuthenticated = false;
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final userData = await _firestoreService.getUserData(uid);
      if (userData != null) {
        _currentUser = userData;
        _isAuthenticated = true;
      }
      notifyListeners();
    } catch (e) {
      print('❌ _loadUserData error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (_currentUser == null) return;
    try {
      final userData = await _firestoreService.getUserData(_currentUser!.uid);
      if (userData != null) {
        _currentUser = userData;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
