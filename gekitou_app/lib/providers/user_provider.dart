import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  User? _user;
  List<Map<String, dynamic>> _battleHistory = [];
  Map<String, dynamic> _battleStats = {};
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  List<Map<String, dynamic>> get battleHistory => _battleHistory;
  Map<String, dynamic> get battleStats => _battleStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get winRate => _user?.getWinRate() ?? 0.0;

  Future<void> loadUserData(String uid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _firestoreService.getUserData(uid);
      await loadBattleHistory(uid);
      await loadBattleStats(uid);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBattleHistory(String uid, {int limit = 50}) async {
    try {
      _battleHistory = await _firestoreService.getBattleHistory(
        uid,
        limit: limit,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadBattleStats(String uid) async {
    try {
      _battleStats = await _firestoreService.getBattleStats(uid);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> saveBattleResult(
    String uid,
    Map<String, dynamic> battleResult,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.saveBattleResult(
        uid: uid,
        battleResult: battleResult,
      );

      await loadUserData(uid);

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

  Future<bool> updateUserProfile({
    required String uid,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.updateUserProfile(
        uid: uid,
        displayName: displayName,
      );

      if (_user != null) {
        _user = _user!.copyWith(displayName: displayName);
      }

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

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 50}) async {
    try {
      return await _firestoreService.getLeaderboard(limit: limit);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<String?> getMostUsedCharacter(String uid) async {
    try {
      return await _firestoreService.getMostUsedCharacter(uid);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getBattleHistoryStream(String uid) {
    return _firestoreService.getBattleHistoryStream(uid);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String getFormattedWinRate() {
    return '${winRate.toStringAsFixed(1)}%';
  }

  int get totalBattles => _user?.totalBattles ?? 0;
  int get wins => _user?.wins ?? 0;
  int get losses => _user?.losses ?? 0;
}
