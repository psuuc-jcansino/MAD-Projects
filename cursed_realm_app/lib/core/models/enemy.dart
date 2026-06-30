import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'skill.dart';

part 'enemy.g.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

@HiveType(typeId: 30)
enum EnemyTier {
  @HiveField(0)
  minion, // weak, filler
  @HiveField(1)
  elite, // stronger, rare
  @HiveField(2)
  boss, // floor boss, unique
}

@HiveType(typeId: 31)
enum EnemyAIPattern {
  @HiveField(0)
  aggressive, // always attacks
  @HiveField(1)
  strategic, // uses skills when HP low
  @HiveField(2)
  defensive, // buffs defense first
  @HiveField(3)
  berserker, // stronger when low HP
}

// ─── Loot Entry ───────────────────────────────────────────────────────────────

@HiveType(typeId: 32)
class LootEntry {
  @HiveField(0)
  final String itemId;
  @HiveField(1)
  final double dropChance; // 0.0 - 1.0
  @HiveField(2)
  final int minQuantity;
  @HiveField(3)
  final int maxQuantity;

  const LootEntry({
    required this.itemId,
    required this.dropChance,
    this.minQuantity = 1,
    this.maxQuantity = 1,
  });
}

// ─── Enemy Stats ──────────────────────────────────────────────────────────────

@HiveType(typeId: 33)
class EnemyStats {
  @HiveField(0)
  final int hp;
  @HiveField(1)
  final int maxHp;
  @HiveField(2)
  final int attack;
  @HiveField(3)
  final int defense;
  @HiveField(4)
  final int speed;
  @HiveField(5)
  final double critChance;

  const EnemyStats({
    required this.hp,
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.critChance,
  });

  EnemyStats copyWith({int? hp}) {
    return EnemyStats(
      hp: hp ?? this.hp,
      maxHp: maxHp,
      attack: attack,
      defense: defense,
      speed: speed,
      critChance: critChance,
    );
  }

  double get hpPercent => hp / maxHp;
  bool get isAlive => hp > 0;
}

// ─── Enemy Definition (template) ─────────────────────────────────────────────

@HiveType(typeId: 34)
class EnemyDefinition extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final EnemyTier tier;
  @HiveField(4)
  final EnemyAIPattern aiPattern;
  @HiveField(5)
  final EnemyStats baseStats;
  @HiveField(6)
  final List<String> skillIds; // skills this enemy can use
  @HiveField(7)
  final List<LootEntry> lootTable;
  @HiveField(8)
  final int baseExpReward;
  @HiveField(9)
  final int baseGoldReward;
  @HiveField(10)
  final String spriteAsset;
  @HiveField(11)
  final int minFloorLevel; // first appears on this floor

  const EnemyDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.aiPattern,
    required this.baseStats,
    required this.skillIds,
    required this.lootTable,
    required this.baseExpReward,
    required this.baseGoldReward,
    required this.spriteAsset,
    required this.minFloorLevel,
  });

  @override
  List<Object?> get props => [id, name, tier];
}

// ─── Combat Enemy (instance during battle) ───────────────────────────────────

class CombatEnemy {
  final EnemyDefinition definition;
  EnemyStats stats;
  List<ActiveStatusEffect> statusEffects;
  int turnsSurvived;

  CombatEnemy({
    required this.definition,
    required this.stats,
    List<ActiveStatusEffect>? statusEffects,
  })  : statusEffects = statusEffects ?? [],
        turnsSurvived = 0;

  factory CombatEnemy.fromDefinition(EnemyDefinition def,
      {int floorBonus = 0}) {
    // Scale stats slightly based on floor depth
    final scale = 1.0 + (floorBonus * 0.05);
    final scaledStats = EnemyStats(
      hp: (def.baseStats.maxHp * scale).round(),
      maxHp: (def.baseStats.maxHp * scale).round(),
      attack: (def.baseStats.attack * scale).round(),
      defense: (def.baseStats.defense * scale).round(),
      speed: def.baseStats.speed,
      critChance: def.baseStats.critChance,
    );
    return CombatEnemy(definition: def, stats: scaledStats);
  }

  bool get isAlive => stats.isAlive;
  String get name => definition.name;
  EnemyTier get tier => definition.tier;
  EnemyAIPattern get aiPattern => definition.aiPattern;

  void takeDamage(int damage) {
    final newHp = (stats.hp - damage).clamp(0, stats.maxHp);
    stats = stats.copyWith(hp: newHp);
  }

  bool hasStatusEffect(StatusEffectType type) {
    return statusEffects.any((e) => e.type == type);
  }

  void applyStatusEffect(StatusEffectType type, int duration) {
    final existing = statusEffects.where((e) => e.type == type).toList();
    if (existing.isNotEmpty) {
      existing.first.remainingTurns = duration;
    } else {
      statusEffects
          .add(ActiveStatusEffect(type: type, remainingTurns: duration));
    }
  }

  void tickStatusEffects() {
    statusEffects.removeWhere((e) {
      e.remainingTurns--;
      return e.remainingTurns <= 0;
    });
  }

  int get expReward => definition.baseExpReward;
  int get goldReward => definition.baseGoldReward;
}
