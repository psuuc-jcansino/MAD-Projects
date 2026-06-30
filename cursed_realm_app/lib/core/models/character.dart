import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'skill.dart';
import 'item.dart';

part 'character.g.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

@HiveType(typeId: 0)
enum CharacterClass {
  @HiveField(0)
  knight,
  @HiveField(1)
  necromancer,
  @HiveField(2)
  rogue,
}

extension CharacterClassX on CharacterClass {
  String get displayName {
    switch (this) {
      case CharacterClass.knight:
        return 'Knight';
      case CharacterClass.necromancer:
        return 'Necromancer';
      case CharacterClass.rogue:
        return 'Rogue';
    }
  }

  String get description {
    switch (this) {
      case CharacterClass.knight:
        return 'A stalwart warrior clad in cursed armor. High defense, powerful melee strikes.';
      case CharacterClass.necromancer:
        return 'A dark mage who bends death itself. Commands undead and drains life force.';
      case CharacterClass.rogue:
        return 'A shadow-walker who strikes unseen. High crit chance and evasion.';
    }
  }

  /// Base stats at level 1
  CharacterStats get baseStats {
    switch (this) {
      case CharacterClass.knight:
        return CharacterStats(
          hp: 120,
          maxHp: 120,
          mp: 30,
          maxMp: 30,
          attack: 15,
          defense: 12,
          speed: 8,
          critChance: 0.05,
        );
      case CharacterClass.necromancer:
        return CharacterStats(
          hp: 70,
          maxHp: 70,
          mp: 100,
          maxMp: 100,
          attack: 8,
          defense: 5,
          speed: 10,
          critChance: 0.08,
        );
      case CharacterClass.rogue:
        return CharacterStats(
          hp: 85,
          maxHp: 85,
          mp: 50,
          maxMp: 50,
          attack: 18,
          defense: 6,
          speed: 16,
          critChance: 0.20,
        );
    }
  }

  /// Stat growth per level
  StatGrowth get statGrowth {
    switch (this) {
      case CharacterClass.knight:
        return StatGrowth(hp: 18, mp: 3, attack: 3, defense: 4, speed: 1);
      case CharacterClass.necromancer:
        return StatGrowth(hp: 8, mp: 15, attack: 2, defense: 1, speed: 2);
      case CharacterClass.rogue:
        return StatGrowth(hp: 10, mp: 5, attack: 4, defense: 2, speed: 3);
    }
  }
}

// ─── Stats ────────────────────────────────────────────────────────────────────

@HiveType(typeId: 1)
class CharacterStats extends Equatable {
  @HiveField(0)
  final int hp;
  @HiveField(1)
  final int maxHp;
  @HiveField(2)
  final int mp;
  @HiveField(3)
  final int maxMp;
  @HiveField(4)
  final int attack;
  @HiveField(5)
  final int defense;
  @HiveField(6)
  final int speed;
  @HiveField(7)
  final double critChance;

  const CharacterStats({
    required this.hp,
    required this.maxHp,
    required this.mp,
    required this.maxMp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.critChance,
  });

  CharacterStats copyWith({
    int? hp,
    int? maxHp,
    int? mp,
    int? maxMp,
    int? attack,
    int? defense,
    int? speed,
    double? critChance,
  }) {
    return CharacterStats(
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      mp: mp ?? this.mp,
      maxMp: maxMp ?? this.maxMp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      speed: speed ?? this.speed,
      critChance: critChance ?? this.critChance,
    );
  }

  @override
  List<Object?> get props =>
      [hp, maxHp, mp, maxMp, attack, defense, speed, critChance];
}

@HiveType(typeId: 2)
class StatGrowth {
  @HiveField(0)
  final int hp;
  @HiveField(1)
  final int mp;
  @HiveField(2)
  final int attack;
  @HiveField(3)
  final int defense;
  @HiveField(4)
  final int speed;

  const StatGrowth({
    required this.hp,
    required this.mp,
    required this.attack,
    required this.defense,
    required this.speed,
  });
}

// ─── Character ────────────────────────────────────────────────────────────────

@HiveType(typeId: 3)
class Character extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final CharacterClass characterClass;
  @HiveField(3)
  final CharacterStats stats;
  @HiveField(4)
  final int level;
  @HiveField(5)
  final int experience;
  @HiveField(6)
  final int experienceToNextLevel;
  @HiveField(7)
  final List<String> unlockedSkillIds;
  @HiveField(8)
  final List<String> equippedSkillIds; // max 4 active skills
  @HiveField(9)
  final EquipmentSlots equipment;
  @HiveField(10)
  final int statPoints; // allocatable on level up
  @HiveField(11)
  final int skillPoints;
  @HiveField(12)
  final int gold;

  const Character({
    required this.id,
    required this.name,
    required this.characterClass,
    required this.stats,
    required this.level,
    required this.experience,
    required this.experienceToNextLevel,
    required this.unlockedSkillIds,
    required this.equippedSkillIds,
    required this.equipment,
    required this.statPoints,
    required this.skillPoints,
    required this.gold,
  });

  factory Character.create({
    required String id,
    required String name,
    required CharacterClass characterClass,
  }) {
    return Character(
      id: id,
      name: name,
      characterClass: characterClass,
      stats: characterClass.baseStats,
      level: 1,
      experience: 0,
      experienceToNextLevel: 100,
      unlockedSkillIds: [],
      equippedSkillIds: [],
      equipment: EquipmentSlots.empty(),
      statPoints: 0,
      skillPoints: 1,
      gold: 50,
    );
  }

  /// Returns exp needed to reach next level (scales exponentially)
  static int expForLevel(int level) => (100 * (level * 1.5)).round();

  /// Whether the character can level up
  bool get canLevelUp => experience >= experienceToNextLevel;

  /// Apply level up: increase stats, grant points
  Character levelUp() {
    final growth = characterClass.statGrowth;
    final newStats = stats.copyWith(
      hp: stats.maxHp + growth.hp,
      maxHp: stats.maxHp + growth.hp,
      mp: stats.maxMp + growth.mp,
      maxMp: stats.maxMp + growth.mp,
      attack: stats.attack + growth.attack,
      defense: stats.defense + growth.defense,
      speed: stats.speed + growth.speed,
    );
    final newLevel = level + 1;
    return copyWith(
      level: newLevel,
      stats: newStats,
      experience: experience - experienceToNextLevel,
      experienceToNextLevel: expForLevel(newLevel),
      statPoints: statPoints + 3,
      skillPoints: skillPoints + 1,
    );
  }

  /// Add experience and auto-level if possible
  Character gainExperience(int amount) {
    Character c = copyWith(experience: experience + amount);
    while (c.canLevelUp) {
      c = c.levelUp();
    }
    return c;
  }

  /// Take damage, clamped to 0
  Character takeDamage(int damage) {
    final newHp = (stats.hp - damage).clamp(0, stats.maxHp);
    return copyWith(stats: stats.copyWith(hp: newHp));
  }

  /// Heal HP, clamped to maxHp
  Character heal(int amount) {
    final newHp = (stats.hp + amount).clamp(0, stats.maxHp);
    return copyWith(stats: stats.copyWith(hp: newHp));
  }

  /// Restore MP
  Character restoreMp(int amount) {
    final newMp = (stats.mp + amount).clamp(0, stats.maxMp);
    return copyWith(stats: stats.copyWith(mp: newMp));
  }

  bool get isAlive => stats.hp > 0;

  double get hpPercent => stats.hp / stats.maxHp;
  double get mpPercent => stats.mp / stats.maxMp;
  double get expPercent => experience / experienceToNextLevel;

  Character copyWith({
    String? id,
    String? name,
    CharacterClass? characterClass,
    CharacterStats? stats,
    int? level,
    int? experience,
    int? experienceToNextLevel,
    List<String>? unlockedSkillIds,
    List<String>? equippedSkillIds,
    EquipmentSlots? equipment,
    int? statPoints,
    int? skillPoints,
    int? gold,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      characterClass: characterClass ?? this.characterClass,
      stats: stats ?? this.stats,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      experienceToNextLevel:
          experienceToNextLevel ?? this.experienceToNextLevel,
      unlockedSkillIds: unlockedSkillIds ?? this.unlockedSkillIds,
      equippedSkillIds: equippedSkillIds ?? this.equippedSkillIds,
      equipment: equipment ?? this.equipment,
      statPoints: statPoints ?? this.statPoints,
      skillPoints: skillPoints ?? this.skillPoints,
      gold: gold ?? this.gold,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, characterClass, stats, level, experience];
}

// ─── Equipment Slots ──────────────────────────────────────────────────────────

@HiveType(typeId: 4)
class EquipmentSlots extends Equatable {
  @HiveField(0)
  final String? weaponId;
  @HiveField(1)
  final String? armorId;
  @HiveField(2)
  final String? accessoryId;
  @HiveField(3)
  final String? relicId;

  const EquipmentSlots({
    this.weaponId,
    this.armorId,
    this.accessoryId,
    this.relicId,
  });

  factory EquipmentSlots.empty() => const EquipmentSlots();

  EquipmentSlots copyWith({
    String? weaponId,
    String? armorId,
    String? accessoryId,
    String? relicId,
  }) {
    return EquipmentSlots(
      weaponId: weaponId ?? this.weaponId,
      armorId: armorId ?? this.armorId,
      accessoryId: accessoryId ?? this.accessoryId,
      relicId: relicId ?? this.relicId,
    );
  }

  @override
  List<Object?> get props => [weaponId, armorId, accessoryId, relicId];
}
