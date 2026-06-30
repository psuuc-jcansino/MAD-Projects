import 'package:flutter/material.dart';
import '../models/battle_model.dart';
import '../models/character_model.dart';

class BattleProvider extends ChangeNotifier {
  BattleState? _currentBattle;
  bool _isProcessing = false;
  String? _error;

  BattleState? get currentBattle => _currentBattle;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  bool get isBattleActive =>
      _currentBattle != null && !_currentBattle!.battleEnded;

  void initiateBattle({
    required Character playerCharacter,
    required Character enemyCharacter,
  }) {
    try {
      _currentBattle = BattleState(
        playerCharacter: playerCharacter,
        enemyCharacter: enemyCharacter,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> executePlayerAction(BattleAction action) async {
    if (_currentBattle == null || _isProcessing) return;

    try {
      _isProcessing = true;
      notifyListeners();

      _currentBattle!.executePlayerAction(action);
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 800));

      if (!_currentBattle!.battleEnded) {
        _currentBattle!.executeEnemyAction();
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 500));
      }

      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isProcessing = false;
      notifyListeners();
    }
  }

  List<BattleMove> getBattleHistory() {
    return _currentBattle?.moves ?? [];
  }

  double getPlayerHPPercentage() {
    if (_currentBattle == null) return 1.0;
    return _currentBattle!.playerHp / _currentBattle!.playerMaxHp;
  }

  double getEnemyHPPercentage() {
    if (_currentBattle == null) return 1.0;
    return _currentBattle!.enemyHp / _currentBattle!.enemyMaxHp;
  }

  bool get isPlayerTurn {
    if (_currentBattle == null) return true;
    return _currentBattle!.isPlayerTurn;
  }

  Map<String, dynamic>? getBattleResult() {
    if (_currentBattle == null) return null;
    return _currentBattle!.toBattleResult();
  }

  void endBattle() {
    _currentBattle = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String? getLastMoveDescription() {
    if (_currentBattle == null || _currentBattle!.moves.isEmpty) return null;
    return _currentBattle!.moves.last.description;
  }

  int getTotalMovesMade() {
    if (_currentBattle == null) return 0;
    return _currentBattle!.moves.length;
  }

  @override
  void dispose() {
    _currentBattle = null;
    super.dispose();
  }
}
