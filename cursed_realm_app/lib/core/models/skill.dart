import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'skill.g.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

@HiveType(typeId: 20)
enum SkillType {
  @HiveField(0)
  active, // costs MP, used in battle
  @HiveField(1)
  passive, // always active stat boost
}

@HiveType(typeId: 21)
enum SkillTargetType {
  @HiveField(0)
  singleEnemy,
  @HiveField(1)
  allEnemies,
  @HiveField(2)
  self,
  @HiveField(3)
  ally,
}

@HiveType(typeId: 22)
enum DamageType {
  @HiveField(0)
  physical,
  @HiveField(1)
  dark,
  @HiveField(2)
  cursed,
  @HiveField(3)
  bleed,
  @HiveField(4)
  none, // for heals/buffs
}

// ─── Skill Effect ─────────────────────────────────────────────────────────────

@HiveType(typeId: 23)
class SkillEffect {
  /// Damage multiplier (e.g. 1.5 = 150% of attack)
  @HiveField(0)
  final double? damageMultiplier;
  @HiveField(1)
  final DamageType damageType;

  /// Flat heal amount
  @HiveField(2)
  final int? healAmount;

  /// % of max HP to heal (e.g. 0.2 = 20%)
  @HiveField(3)
  final double? healPercent;

  /// Apply a status effect
  @HiveField(4)
  final StatusEffectType? statusEffect;
  @HiveField(5)
  final int? statusDuration; // turns

  /// Stat buff/debuff (temporary)
  @HiveField(6)
  final int? attackBuff;
  @HiveField(7)
  final int? defenseBuff;

  const SkillEffect({
    this.damageMultiplier,
    this.damageType = DamageType.none,
    this.healAmount,
    this.healPercent,
    this.statusEffect,
    this.statusDuration,
    this.attackBuff,
    this.defenseBuff,
  });
}

@HiveType(typeId: 24)
enum StatusEffectType {
  @HiveField(0)
  poison,
  @HiveField(1)
  burn,
  @HiveField(2)
  bleed,
  @HiveField(3)
  stun,
  @HiveField(4)
  weakened, // -20% defense
  @HiveField(5)
  empowered, // +20% attack
  @HiveField(6)
  cursed, // -20% all stats
  @HiveField(7)
  regenerating, // +HP per turn
}

extension StatusEffectTypeX on StatusEffectType {
  String get displayName {
    switch (this) {
      case StatusEffectType.poison:
        return 'Poisoned';
      case StatusEffectType.burn:
        return 'Burning';
      case StatusEffectType.bleed:
        return 'Bleeding';
      case StatusEffectType.stun:
        return 'Stunned';
      case StatusEffectType.weakened:
        return 'Weakened';
      case StatusEffectType.empowered:
        return 'Empowered';
      case StatusEffectType.cursed:
        return 'Cursed';
      case StatusEffectType.regenerating:
        return 'Regenerating';
    }
  }

  bool get isDebuff {
    return [
      StatusEffectType.poison,
      StatusEffectType.burn,
      StatusEffectType.bleed,
      StatusEffectType.stun,
      StatusEffectType.weakened,
      StatusEffectType.cursed,
    ].contains(this);
  }
}

// ─── Active Status Effect (applied during combat) ─────────────────────────────

class ActiveStatusEffect {
  final StatusEffectType type;
  int remainingTurns;

  ActiveStatusEffect({required this.type, required this.remainingTurns});
}

// ─── Skill ────────────────────────────────────────────────────────────────────

@HiveType(typeId: 25)
class Skill extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final SkillType type;
  @HiveField(4)
  final SkillTargetType targetType;
  @HiveField(5)
  final int mpCost;
  @HiveField(6)
  final SkillEffect effect;
  @HiveField(7)
  final String iconAsset;
  @HiveField(8)
  final String characterClassId; // which class can learn this
  @HiveField(9)
  final String? prerequisiteSkillId; // skill tree dependency
  @HiveField(10)
  final int treeTier; // 1 = basic, 3 = advanced
  @HiveField(11)
  final String treeBranch; // e.g. 'warrior', 'guardian', 'paladin'
  @HiveField(12)
  final int skillPointCost;

  const Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.targetType,
    required this.mpCost,
    required this.effect,
    required this.iconAsset,
    required this.characterClassId,
    this.prerequisiteSkillId,
    required this.treeTier,
    required this.treeBranch,
    this.skillPointCost = 1,
  });

  bool get isActive => type == SkillType.active;
  bool get isPassive => type == SkillType.passive;

  @override
  List<Object?> get props => [id, name, characterClassId, treeBranch, treeTier];
}
