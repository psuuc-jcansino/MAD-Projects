import 'package:uuid/uuid.dart';
import 'character_model.dart';

enum BattleAction { attack, special, heal }

class BattleMove {
  final BattleAction action;
  final int damage;
  final String description;
  final DateTime timestamp;

  BattleMove({
    required this.action,
    required this.damage,
    required this.description,
    required this.timestamp,
  });
}

class BattleState {
  final String battleId;
  final Character playerCharacter;
  final Character enemyCharacter;

  int playerHp;
  int playerMaxHp;
  int enemyHp;
  int enemyMaxHp;

  int playerAttackBonus = 0;
  int playerDefenseBonus = 0;

  final List<BattleMove> moves = [];
  bool isPlayerTurn = true;
  bool battleEnded = false;
  bool playerWon = false;
  String? battleEndReason;

  BattleState({required this.playerCharacter, required this.enemyCharacter})
    : battleId = const Uuid().v4(),
      playerHp = playerCharacter.hp,
      playerMaxHp = playerCharacter.hp,
      enemyHp = enemyCharacter.hp,
      enemyMaxHp = enemyCharacter.hp;

  void executePlayerAction(BattleAction action) {
    if (battleEnded || !isPlayerTurn) return;

    int damage = 0;
    String description = '';

    switch (action) {
      case BattleAction.attack:
        damage = _calculateDamage(
          attacker: playerCharacter,
          defender: enemyCharacter,
          moveType: 'attack',
        );
        description = '${playerCharacter.name} attacked!';
        enemyHp -= damage;
        break;

      case BattleAction.special:
        damage = _calculateDamage(
          attacker: playerCharacter,
          defender: enemyCharacter,
          moveType: 'special',
        );
        description = '${playerCharacter.name} used Special Attack!';
        enemyHp -= damage;
        break;

      case BattleAction.heal:
        final healAmount = (playerMaxHp * 0.25).toInt(); // 25% of max HP
        playerHp = (playerHp + healAmount).clamp(0, playerMaxHp);
        damage = healAmount;
        description = '${playerCharacter.name} healed for $healAmount HP!';
        break;
    }

    enemyHp = enemyHp.clamp(0, enemyMaxHp);

    moves.add(
      BattleMove(
        action: action,
        damage: damage,
        description: description,
        timestamp: DateTime.now(),
      ),
    );

    _checkBattleEnd();
    if (!battleEnded) {
      isPlayerTurn = false;
    }
  }

  void executeEnemyAction() {
    if (battleEnded || isPlayerTurn) return;

    final rand = DateTime.now().millisecond % 100;
    late BattleAction action;

    if (rand < 60) {
      action = BattleAction.attack;
    } else if (rand < 85) {
      action = BattleAction.special;
    } else {
      action = BattleAction.heal;
    }

    int damage = 0;
    String description = '';

    switch (action) {
      case BattleAction.attack:
        damage = _calculateDamage(
          attacker: enemyCharacter,
          defender: playerCharacter,
          moveType: 'attack',
        );
        description = '${enemyCharacter.name} attacked!';
        playerHp -= damage;
        break;

      case BattleAction.special:
        damage = _calculateDamage(
          attacker: enemyCharacter,
          defender: playerCharacter,
          moveType: 'special',
        );
        description = '${enemyCharacter.name} used Special Attack!';
        playerHp -= damage;
        break;

      case BattleAction.heal:
        final healAmount = (enemyMaxHp * 0.25).toInt();
        enemyHp = (enemyHp + healAmount).clamp(0, enemyMaxHp);
        damage = healAmount;
        description = '${enemyCharacter.name} healed for $healAmount HP!';
        break;
    }

    playerHp = playerHp.clamp(0, playerMaxHp);

    moves.add(
      BattleMove(
        action: action,
        damage: damage,
        description: description,
        timestamp: DateTime.now(),
      ),
    );

    _checkBattleEnd();
    if (!battleEnded) {
      isPlayerTurn = true;
    }
  }

  int _calculateDamage({
    required Character attacker,
    required Character defender,
    required String moveType,
  }) {
    var baseDamage = attacker.attack;

    if (moveType == 'special') {
      baseDamage = (baseDamage * 1.5).toInt();
    }

    final defenseFactor = 1 - (defender.defense / 100);
    final finalDamage = (baseDamage * defenseFactor).toInt();

    final variance = (finalDamage * 0.1).toInt();
    final random = DateTime.now().millisecond % (variance * 2);

    return (finalDamage - variance + random).clamp(1, 999);
  }

  void _checkBattleEnd() {
    if (playerHp <= 0) {
      battleEnded = true;
      playerWon = false;
      battleEndReason = '${playerCharacter.name} was defeated!';
    } else if (enemyHp <= 0) {
      battleEnded = true;
      playerWon = true;
      battleEndReason = 'Victory! ${enemyCharacter.name} was defeated!';
    }
  }

  Map<String, dynamic> toBattleResult() {
    return {
      'battleId': battleId,
      'playerCharacterId': playerCharacter.id,
      'playerCharacterName': playerCharacter.name,
      'enemyCharacterId': enemyCharacter.id,
      'enemyCharacterName': enemyCharacter.name,
      'playerWon': playerWon,
      'playerFinalHp': playerHp,
      'enemyFinalHp': enemyHp,
      'totalMoves': moves.length,
      'battleEndReason': battleEndReason,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
