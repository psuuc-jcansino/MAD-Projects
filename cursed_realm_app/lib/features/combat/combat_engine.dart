import 'dart:math';
import '../../core/models/character.dart';
import '../../core/models/enemy.dart';
import '../../core/models/skill.dart';
import '../../core/models/item.dart';
import '../../core/data/game_data.dart';

// ─── Combat State ─────────────────────────────────────────────────────────────

enum CombatPhase {
  playerTurn,
  enemyTurn,
  victory,
  defeat,
  fled,
}

enum ActionType { attack, skill, item, flee }

class CombatAction {
  final ActionType type;
  final String? skillId;
  final String? itemId;
  const CombatAction({required this.type, this.skillId, this.itemId});
}

class CombatResult {
  final String message;
  final int? damageDealt;
  final int? damageReceived;
  final int? healAmount;
  final int? mpUsed;
  final bool isCrit;
  final bool enemyDefeated;
  final StatusEffectType? statusApplied;

  const CombatResult({
    required this.message,
    this.damageDealt,
    this.damageReceived,
    this.healAmount,
    this.mpUsed,
    this.isCrit = false,
    this.enemyDefeated = false,
    this.statusApplied,
  });
}

class CombatState {
  final Character character;
  final CombatEnemy enemy;
  final CombatPhase phase;
  final List<String> battleLog;
  final int turnNumber;
  final List<ActiveStatusEffect> playerStatusEffects;
  final int? lastDamageToEnemy;
  final int? lastDamageToPlayer;
  final bool lastWasCrit;

  const CombatState({
    required this.character,
    required this.enemy,
    required this.phase,
    required this.battleLog,
    required this.turnNumber,
    required this.playerStatusEffects,
    this.lastDamageToEnemy,
    this.lastDamageToPlayer,
    this.lastWasCrit = false,
  });

  CombatState copyWith({
    Character? character,
    CombatEnemy? enemy,
    CombatPhase? phase,
    List<String>? battleLog,
    int? turnNumber,
    List<ActiveStatusEffect>? playerStatusEffects,
    int? lastDamageToEnemy,
    int? lastDamageToPlayer,
    bool? lastWasCrit,
  }) {
    return CombatState(
      character: character ?? this.character,
      enemy: enemy ?? this.enemy,
      phase: phase ?? this.phase,
      battleLog: battleLog ?? this.battleLog,
      turnNumber: turnNumber ?? this.turnNumber,
      playerStatusEffects: playerStatusEffects ?? this.playerStatusEffects,
      lastDamageToEnemy: lastDamageToEnemy,
      lastDamageToPlayer: lastDamageToPlayer,
      lastWasCrit: lastWasCrit ?? this.lastWasCrit,
    );
  }
}

// ─── Victory Rewards ──────────────────────────────────────────────────────────

class VictoryRewards {
  final int expGained;
  final int goldGained;
  final List<Item> itemsDropped;

  const VictoryRewards({
    required this.expGained,
    required this.goldGained,
    required this.itemsDropped,
  });
}

// ─── Combat Engine ────────────────────────────────────────────────────────────

class CombatEngine {
  final Random _rng = Random();

  // ── Initialize ──────────────────────────────────────────────────────────

  CombatState initCombat({
    required Character character,
    required EnemyDefinition enemyDef,
    required int floorLevel,
  }) {
    final enemy =
        CombatEnemy.fromDefinition(enemyDef, floorBonus: floorLevel - 1);
    final playerGoesFirst = character.stats.speed >= enemy.stats.speed;

    final initialState = CombatState(
      character: character,
      enemy: enemy,
      phase: CombatPhase.playerTurn,
      battleLog: [
        'A ${enemy.name} appears from the darkness!',
        playerGoesFirst ? 'You move first!' : '${enemy.name} strikes first!',
      ],
      turnNumber: 1,
      playerStatusEffects: [],
    );

    // If enemy is faster, immediately process their opening attack
    if (!playerGoesFirst) {
      return _processEnemyTurn(initialState);
    }

    return initialState;
  }

  // ── Player Turn ─────────────────────────────────────────────────────────

  CombatState processPlayerAction(CombatState state, CombatAction action) {
    if (state.phase != CombatPhase.playerTurn) return state;

    switch (action.type) {
      case ActionType.attack:
        return _playerAttack(state);
      case ActionType.skill:
        return _playerUseSkill(state, action.skillId!);
      case ActionType.item:
        return _playerUseItem(state, action.itemId!);
      case ActionType.flee:
        return _playerFlee(state);
    }
  }

  CombatState _playerAttack(CombatState state) {
    final char = state.character;
    final enemy = state.enemy;
    final log = List<String>.from(state.battleLog);

    // Calculate damage
    final result = _calculateDamage(
      attack: char.stats.attack,
      defense: enemy.stats.defense,
      critChance: char.stats.critChance,
    );

    enemy.takeDamage(result.damage);
    log.add(result.isCrit
        ? '💥 CRITICAL HIT! You deal ${result.damage} damage to ${enemy.name}!'
        : 'You strike ${enemy.name} for ${result.damage} damage.');

    if (!enemy.isAlive) {
      log.add('${enemy.name} has been defeated!');
      return state.copyWith(
        enemy: enemy,
        phase: CombatPhase.victory,
        battleLog: log,
        lastDamageToEnemy: result.damage,
        lastWasCrit: result.isCrit,
      );
    }

    // Transition to enemy turn
    var newState = state.copyWith(
      enemy: enemy,
      battleLog: log,
      lastDamageToEnemy: result.damage,
      lastWasCrit: result.isCrit,
    );
    return _processEnemyTurn(newState);
  }

  CombatState _playerUseSkill(CombatState state, String skillId) {
    final skill = GameData.skills[skillId];
    if (skill == null) return state;

    final char = state.character;
    final enemy = state.enemy;
    final log = List<String>.from(state.battleLog);

    // Check MP
    if (char.stats.mp < skill.mpCost) {
      log.add('Not enough MP to use ${skill.name}!');
      return state.copyWith(battleLog: log);
    }

    // Deduct MP
    var updatedChar = char.restoreMp(-skill.mpCost);
    int? damageDealt;

    // Apply skill effect
    final effect = skill.effect;

    if (effect.damageMultiplier != null) {
      int baseDmg = (char.stats.attack * effect.damageMultiplier!).round();

      // Dark/cursed damage ignores some defense
      final defReduction = effect.damageType == DamageType.physical
          ? enemy.stats.defense
          : (enemy.stats.defense * 0.5).round();

      final result = _calculateDamage(
        attack: baseDmg,
        defense: defReduction,
        critChance: char.stats.critChance,
        isSkill: true,
      );

      enemy.takeDamage(result.damage);
      damageDealt = result.damage;

      log.add(result.isCrit
          ? '💥 ${skill.name} — CRITICAL! ${result.damage} ${effect.damageType.name} damage!'
          : '✨ ${skill.name} deals ${result.damage} ${effect.damageType.name} damage to ${enemy.name}!');
    }

    // Heal effect
    if (effect.healAmount != null) {
      updatedChar = updatedChar.heal(effect.healAmount!);
      log.add('You recover ${effect.healAmount} HP!');
    }
    if (effect.healPercent != null) {
      final healAmt = (damageDealt ?? 0) * effect.healPercent!;
      updatedChar = updatedChar.heal(healAmt.round());
      log.add('You drain ${healAmt.round()} life from ${enemy.name}!');
    }

    // Status effect
    if (effect.statusEffect != null) {
      enemy.applyStatusEffect(effect.statusEffect!, effect.statusDuration ?? 2);
      log.add('${enemy.name} is now ${effect.statusEffect!.displayName}!');
    }

    if (!enemy.isAlive) {
      log.add('${enemy.name} has been defeated!');
      return state.copyWith(
        character: updatedChar,
        enemy: enemy,
        phase: CombatPhase.victory,
        battleLog: log,
        lastDamageToEnemy: damageDealt,
      );
    }

    var newState = state.copyWith(
      character: updatedChar,
      enemy: enemy,
      battleLog: log,
      lastDamageToEnemy: damageDealt,
    );
    return _processEnemyTurn(newState);
  }

  CombatState _playerUseItem(CombatState state, String itemId) {
    final item = GameData.items[itemId];
    if (item == null) return state;

    final log = List<String>.from(state.battleLog);
    var updatedChar = state.character;

    if (item.healAmount != null) {
      updatedChar = updatedChar.heal(item.healAmount!);
      log.add('🧪 You use ${item.name} and recover ${item.healAmount} HP!');
    }
    if (item.mpRestoreAmount != null) {
      updatedChar = updatedChar.restoreMp(item.mpRestoreAmount!);
      log.add(
          '🔵 You use ${item.name} and restore ${item.mpRestoreAmount} MP!');
    }

    var newState = state.copyWith(
      character: updatedChar,
      battleLog: log,
    );
    return _processEnemyTurn(newState);
  }

  CombatState _playerFlee(CombatState state) {
    final log = List<String>.from(state.battleLog);
    // 50% chance to flee, lower if enemy is faster
    final speedRatio = state.character.stats.speed / state.enemy.stats.speed;
    final fleeChance = (0.5 * speedRatio).clamp(0.2, 0.8);

    if (_rng.nextDouble() < fleeChance) {
      log.add('You escape into the shadows...');
      return state.copyWith(phase: CombatPhase.fled, battleLog: log);
    } else {
      log.add('${state.enemy.name} blocks your escape!');
      return _processEnemyTurn(state.copyWith(battleLog: log));
    }
  }

  // ── Enemy Turn ──────────────────────────────────────────────────────────

  CombatState _processEnemyTurn(CombatState state) {
    if (!state.enemy.isAlive) return state;

    final enemy = state.enemy;
    final log = List<String>.from(state.battleLog);
    var updatedChar = state.character;
    int? damageToPlayer;

    // Tick status effects on enemy
    _tickEnemyStatus(enemy, log);

    if (!enemy.isAlive) {
      log.add('${enemy.name} succumbs to their wounds!');
      return state.copyWith(
        character: updatedChar,
        enemy: enemy,
        phase: CombatPhase.victory,
        battleLog: log,
      );
    }

    // Enemy is stunned — skip turn
    if (enemy.hasStatusEffect(StatusEffectType.stun)) {
      log.add('${enemy.name} is stunned and cannot act!');
      return state.copyWith(
        character: updatedChar,
        enemy: enemy,
        phase: CombatPhase.playerTurn,
        battleLog: log,
        turnNumber: state.turnNumber + 1,
      );
    }

    // Choose enemy action based on AI pattern
    final action = _chooseEnemyAction(enemy);

    switch (action) {
      case _EnemyAction.attack:
        final result = _calculateDamage(
          attack: enemy.stats.attack,
          defense: updatedChar.stats.defense,
          critChance: enemy.stats.critChance,
        );
        updatedChar = updatedChar.takeDamage(result.damage);
        damageToPlayer = result.damage;
        log.add(result.isCrit
            ? '💥 ${enemy.name} lands a CRITICAL blow for ${result.damage} damage!'
            : '${enemy.name} attacks you for ${result.damage} damage.');
        break;

      case _EnemyAction.heavyAttack:
        final dmg = (enemy.stats.attack * 1.6).round();
        final result = _calculateDamage(
          attack: dmg,
          defense: updatedChar.stats.defense,
          critChance: enemy.stats.critChance,
        );
        updatedChar = updatedChar.takeDamage(result.damage);
        damageToPlayer = result.damage;
        log.add(
            '⚠️ ${enemy.name} unleashes a heavy strike for ${result.damage} damage!');
        break;

      case _EnemyAction.curse:
        log.add('${enemy.name} places a dark curse upon you!');
        // Apply weakened status to player (handled in next player turn)
        break;
    }

    if (!updatedChar.isAlive) {
      log.add('You have fallen in battle...');
      return state.copyWith(
        character: updatedChar,
        enemy: enemy,
        phase: CombatPhase.defeat,
        battleLog: log,
        lastDamageToPlayer: damageToPlayer,
      );
    }

    return state.copyWith(
      character: updatedChar,
      enemy: enemy,
      phase: CombatPhase.playerTurn,
      battleLog: log,
      turnNumber: state.turnNumber + 1,
      lastDamageToPlayer: damageToPlayer,
    );
  }

  // ── Enemy AI ────────────────────────────────────────────────────────────

  _EnemyAction _chooseEnemyAction(CombatEnemy enemy) {
    final hpPercent = enemy.stats.hpPercent;

    switch (enemy.aiPattern) {
      case EnemyAIPattern.aggressive:
        return _EnemyAction.attack;

      case EnemyAIPattern.strategic:
        if (hpPercent < 0.4 && _rng.nextDouble() < 0.4) {
          return _EnemyAction.curse;
        }
        return _EnemyAction.attack;

      case EnemyAIPattern.berserker:
        // More aggressive when low HP
        if (hpPercent < 0.3) {
          return _EnemyAction.heavyAttack;
        }
        return _EnemyAction.attack;

      case EnemyAIPattern.defensive:
        if (_rng.nextDouble() < 0.3) {
          return _EnemyAction.heavyAttack;
        }
        return _EnemyAction.attack;
    }
  }

  void _tickEnemyStatus(CombatEnemy enemy, List<String> log) {
    for (final effect in List.from(enemy.statusEffects)) {
      switch (effect.type) {
        case StatusEffectType.poison:
          final dmg = (enemy.stats.maxHp * 0.05).round().clamp(1, 999);
          enemy.takeDamage(dmg);
          log.add('☠️ ${enemy.name} takes $dmg poison damage.');
          break;
        case StatusEffectType.bleed:
          final dmg = (enemy.stats.maxHp * 0.07).round().clamp(1, 999);
          enemy.takeDamage(dmg);
          log.add('🩸 ${enemy.name} bleeds for $dmg damage.');
          break;
        case StatusEffectType.burn:
          final dmg = (enemy.stats.maxHp * 0.06).round().clamp(1, 999);
          enemy.takeDamage(dmg);
          log.add('🔥 ${enemy.name} burns for $dmg damage.');
          break;
        default:
          break;
      }
    }
    enemy.tickStatusEffects();
  }

  // ── Damage Formula ──────────────────────────────────────────────────────

  _DamageResult _calculateDamage({
    required int attack,
    required int defense,
    required double critChance,
    bool isSkill = false,
  }) {
    // Base damage with variance ±15%
    final variance = 0.85 + (_rng.nextDouble() * 0.30);
    int damage = ((attack - defense * 0.5) * variance).round().clamp(1, 9999);

    // Crit
    final isCrit = _rng.nextDouble() < critChance;
    if (isCrit) damage = (damage * 1.75).round();

    return _DamageResult(damage: damage, isCrit: isCrit);
  }

  // ── Rewards ─────────────────────────────────────────────────────────────

  VictoryRewards calculateRewards(CombatEnemy enemy, int floorLevel) {
    final expGained = (enemy.expReward * (1 + floorLevel * 0.1)).round();
    final goldGained =
        enemy.goldReward + _rng.nextInt(enemy.goldReward ~/ 2 + 1);

    final droppedItemIds = GameData.rollLoot(enemy.definition);
    final items = droppedItemIds
        .map((id) => GameData.items[id])
        .whereType<Item>()
        .toList();

    return VictoryRewards(
      expGained: expGained,
      goldGained: goldGained,
      itemsDropped: items,
    );
  }
}

// ─── Internal helpers ─────────────────────────────────────────────────────────

enum _EnemyAction { attack, heavyAttack, curse }

class _DamageResult {
  final int damage;
  final bool isCrit;
  const _DamageResult({required this.damage, required this.isCrit});
}
