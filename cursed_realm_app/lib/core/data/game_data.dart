import '../models/enemy.dart';
import '../models/item.dart';
import '../models/skill.dart';

/// Central registry for all game data.
/// In production this could be loaded from JSON files.
class GameData {
  GameData._();

  // ── Items ──────────────────────────────────────────────────────────────────

  static final Map<String, Item> items = {
    // Consumables
    'health_potion_sm': const Item(
      id: 'health_potion_sm',
      name: 'Small Health Potion',
      description: 'Restores 50 HP. Smells of rot and copper.',
      type: ItemType.consumable,
      rarity: ItemRarity.common,
      statBonus: StatBonus.empty,
      goldValue: 20,
      iconAsset: 'assets/images/items/health_potion_sm.png',
      healAmount: 50,
    ),
    'health_potion_lg': const Item(
      id: 'health_potion_lg',
      name: 'Large Health Potion',
      description: 'Restores 150 HP. Glows faintly crimson.',
      type: ItemType.consumable,
      rarity: ItemRarity.uncommon,
      statBonus: StatBonus.empty,
      goldValue: 60,
      iconAsset: 'assets/images/items/health_potion_lg.png',
      healAmount: 150,
    ),
    'mana_potion': const Item(
      id: 'mana_potion',
      name: 'Mana Potion',
      description: 'Restores 40 MP. Tastes like ash and starlight.',
      type: ItemType.consumable,
      rarity: ItemRarity.common,
      statBonus: StatBonus.empty,
      goldValue: 25,
      iconAsset: 'assets/images/items/mana_potion.png',
      mpRestoreAmount: 40,
    ),

    // Weapons
    'rusted_sword': const Item(
      id: 'rusted_sword',
      name: 'Rusted Blade',
      description: 'A corroded sword found among bones. Still deadly.',
      type: ItemType.weapon,
      rarity: ItemRarity.common,
      statBonus: StatBonus(attack: 5),
      goldValue: 30,
      iconAsset: 'assets/images/items/rusted_sword.png',
    ),
    'cursed_greatsword': const Item(
      id: 'cursed_greatsword',
      name: 'Cursed Greatsword',
      description: 'Whispers your name. Grants dark power.',
      type: ItemType.weapon,
      rarity: ItemRarity.rare,
      statBonus: StatBonus(attack: 18, critChance: 0.05),
      goldValue: 300,
      iconAsset: 'assets/images/items/cursed_greatsword.png',
    ),
    'shadow_dagger': const Item(
      id: 'shadow_dagger',
      name: 'Shadow Dagger',
      description: 'Forged from solidified darkness. Strikes unseen.',
      type: ItemType.weapon,
      rarity: ItemRarity.rare,
      statBonus: StatBonus(attack: 12, speed: 5, critChance: 0.10),
      goldValue: 280,
      iconAsset: 'assets/images/items/shadow_dagger.png',
    ),
    'necro_staff': const Item(
      id: 'necro_staff',
      name: 'Staff of the Damned',
      description: 'Carved from a lich\'s femur. Amplifies dark magic.',
      type: ItemType.weapon,
      rarity: ItemRarity.epic,
      statBonus: StatBonus(attack: 10, mp: 30, critChance: 0.08),
      goldValue: 500,
      iconAsset: 'assets/images/items/necro_staff.png',
    ),

    // Armor
    'leather_armor': const Item(
      id: 'leather_armor',
      name: 'Tattered Leather',
      description: 'Worn and bloodstained. Better than nothing.',
      type: ItemType.armor,
      rarity: ItemRarity.common,
      statBonus: StatBonus(defense: 4, hp: 10),
      goldValue: 25,
      iconAsset: 'assets/images/items/leather_armor.png',
    ),
    'bone_armor': const Item(
      id: 'bone_armor',
      name: 'Bone Plate',
      description: 'Crafted from the remains of fallen warriors.',
      type: ItemType.armor,
      rarity: ItemRarity.uncommon,
      statBonus: StatBonus(defense: 10, hp: 25),
      goldValue: 120,
      iconAsset: 'assets/images/items/bone_armor.png',
    ),
    'shadow_robe': const Item(
      id: 'shadow_robe',
      name: 'Shadow Robe',
      description: 'Woven from darkness itself. Enhances arcane power.',
      type: ItemType.armor,
      rarity: ItemRarity.rare,
      statBonus: StatBonus(defense: 6, mp: 40, speed: 3),
      goldValue: 250,
      iconAsset: 'assets/images/items/shadow_robe.png',
    ),

    // Accessories
    'blood_ring': const Item(
      id: 'blood_ring',
      name: 'Ring of Blood',
      description: 'Pulses with stolen life force.',
      type: ItemType.accessory,
      rarity: ItemRarity.uncommon,
      statBonus: StatBonus(hp: 20, attack: 3),
      goldValue: 90,
      iconAsset: 'assets/images/items/blood_ring.png',
    ),

    // Relics
    'cursed_amulet': const Item(
      id: 'cursed_amulet',
      name: 'Cursed Amulet',
      description: 'A relic of immense and terrible power.',
      type: ItemType.relic,
      rarity: ItemRarity.legendary,
      statBonus: StatBonus(attack: 15, defense: 5, hp: 50, critChance: 0.10),
      goldValue: 999,
      iconAsset: 'assets/images/items/cursed_amulet.png',
    ),
  };

  // ── Enemies ────────────────────────────────────────────────────────────────

  static final Map<String, EnemyDefinition> enemies = {
    'skeleton_warrior': EnemyDefinition(
      id: 'skeleton_warrior',
      name: 'Skeleton Warrior',
      description: 'An ancient warrior cursed to fight forever.',
      tier: EnemyTier.minion,
      aiPattern: EnemyAIPattern.aggressive,
      baseStats: const EnemyStats(
        hp: 40,
        maxHp: 40,
        attack: 8,
        defense: 4,
        speed: 7,
        critChance: 0.05,
      ),
      skillIds: [],
      lootTable: [
        const LootEntry(itemId: 'health_potion_sm', dropChance: 0.3),
        const LootEntry(itemId: 'rusted_sword', dropChance: 0.15),
      ],
      baseExpReward: 25,
      baseGoldReward: 10,
      spriteAsset: 'assets/images/enemies/skeleton_warrior.png',
      minFloorLevel: 1,
    ),
    'cursed_ghost': EnemyDefinition(
      id: 'cursed_ghost',
      name: 'Cursed Ghost',
      description: 'A tormented spirit that drains life force.',
      tier: EnemyTier.minion,
      aiPattern: EnemyAIPattern.strategic,
      baseStats: const EnemyStats(
        hp: 30,
        maxHp: 30,
        attack: 12,
        defense: 2,
        speed: 12,
        critChance: 0.10,
      ),
      skillIds: [],
      lootTable: [
        const LootEntry(itemId: 'mana_potion', dropChance: 0.35),
      ],
      baseExpReward: 30,
      baseGoldReward: 8,
      spriteAsset: 'assets/images/enemies/cursed_ghost.png',
      minFloorLevel: 1,
    ),
    'shadow_hound': EnemyDefinition(
      id: 'shadow_hound',
      name: 'Shadow Hound',
      description: 'A beast born of pure darkness. Hungers endlessly.',
      tier: EnemyTier.elite,
      aiPattern: EnemyAIPattern.berserker,
      baseStats: const EnemyStats(
        hp: 80,
        maxHp: 80,
        attack: 16,
        defense: 6,
        speed: 14,
        critChance: 0.15,
      ),
      skillIds: [],
      lootTable: [
        const LootEntry(itemId: 'shadow_dagger', dropChance: 0.10),
        const LootEntry(itemId: 'health_potion_lg', dropChance: 0.4),
      ],
      baseExpReward: 75,
      baseGoldReward: 30,
      spriteAsset: 'assets/images/enemies/shadow_hound.png',
      minFloorLevel: 3,
    ),
    'bone_golem': EnemyDefinition(
      id: 'bone_golem',
      name: 'Bone Golem',
      description: 'Hundreds of skeletons fused into a single horror.',
      tier: EnemyTier.elite,
      aiPattern: EnemyAIPattern.defensive,
      baseStats: const EnemyStats(
        hp: 150,
        maxHp: 150,
        attack: 14,
        defense: 18,
        speed: 4,
        critChance: 0.03,
      ),
      skillIds: [],
      lootTable: [
        const LootEntry(itemId: 'bone_armor', dropChance: 0.25),
        const LootEntry(itemId: 'health_potion_lg', dropChance: 0.5),
      ],
      baseExpReward: 100,
      baseGoldReward: 45,
      spriteAsset: 'assets/images/enemies/bone_golem.png',
      minFloorLevel: 5,
    ),
    'the_lich_king': EnemyDefinition(
      id: 'the_lich_king',
      name: 'The Lich King',
      description:
          'The ancient ruler of the Cursed Realm. Source of all darkness.',
      tier: EnemyTier.boss,
      aiPattern: EnemyAIPattern.strategic,
      baseStats: const EnemyStats(
        hp: 500,
        maxHp: 500,
        attack: 30,
        defense: 20,
        speed: 10,
        critChance: 0.12,
      ),
      skillIds: [],
      lootTable: [
        const LootEntry(itemId: 'cursed_amulet', dropChance: 1.0),
        const LootEntry(itemId: 'necro_staff', dropChance: 0.5),
      ],
      baseExpReward: 500,
      baseGoldReward: 500,
      spriteAsset: 'assets/images/enemies/lich_king.png',
      minFloorLevel: 10,
    ),
  };

  // ── Skills ─────────────────────────────────────────────────────────────────

  static final Map<String, Skill> skills = {
    // ── Knight Skills ──────────────────────────────────────────────────────

    // Warrior Branch
    'shield_bash': const Skill(
      id: 'shield_bash',
      name: 'Shield Bash',
      description:
          'Bash with your shield, dealing damage and stunning the enemy.',
      type: SkillType.active,
      targetType: SkillTargetType.singleEnemy,
      mpCost: 10,
      effect: SkillEffect(
        damageMultiplier: 0.8,
        damageType: DamageType.physical,
        statusEffect: StatusEffectType.stun,
        statusDuration: 1,
      ),
      iconAsset: 'assets/images/skills/shield_bash.png',
      characterClassId: 'knight',
      treeTier: 1,
      treeBranch: 'warrior',
    ),
    'mighty_strike': const Skill(
      id: 'mighty_strike',
      name: 'Mighty Strike',
      description: 'A devastating blow that deals 200% damage.',
      type: SkillType.active,
      targetType: SkillTargetType.singleEnemy,
      mpCost: 20,
      effect: SkillEffect(
        damageMultiplier: 2.0,
        damageType: DamageType.physical,
      ),
      iconAsset: 'assets/images/skills/mighty_strike.png',
      characterClassId: 'knight',
      prerequisiteSkillId: 'shield_bash',
      treeTier: 2,
      treeBranch: 'warrior',
    ),

    // Guardian Branch
    'iron_will': const Skill(
      id: 'iron_will',
      name: 'Iron Will',
      description: 'Passive: +15% max HP.',
      type: SkillType.passive,
      targetType: SkillTargetType.self,
      mpCost: 0,
      effect: SkillEffect(defenseBuff: 15),
      iconAsset: 'assets/images/skills/iron_will.png',
      characterClassId: 'knight',
      treeTier: 1,
      treeBranch: 'guardian',
    ),

    // ── Necromancer Skills ─────────────────────────────────────────────────

    'shadow_bolt': const Skill(
      id: 'shadow_bolt',
      name: 'Shadow Bolt',
      description: 'Hurls a bolt of pure darkness, dealing dark damage.',
      type: SkillType.active,
      targetType: SkillTargetType.singleEnemy,
      mpCost: 12,
      effect: SkillEffect(
        damageMultiplier: 1.4,
        damageType: DamageType.dark,
      ),
      iconAsset: 'assets/images/skills/shadow_bolt.png',
      characterClassId: 'necromancer',
      treeTier: 1,
      treeBranch: 'darkness',
    ),
    'life_drain': const Skill(
      id: 'life_drain',
      name: 'Life Drain',
      description:
          'Drain enemy life force, dealing damage and healing yourself.',
      type: SkillType.active,
      targetType: SkillTargetType.singleEnemy,
      mpCost: 18,
      effect: SkillEffect(
        damageMultiplier: 1.0,
        damageType: DamageType.dark,
        healPercent: 0.3,
      ),
      iconAsset: 'assets/images/skills/life_drain.png',
      characterClassId: 'necromancer',
      prerequisiteSkillId: 'shadow_bolt',
      treeTier: 2,
      treeBranch: 'darkness',
    ),
    'death_nova': const Skill(
      id: 'death_nova',
      name: 'Death Nova',
      description:
          'Releases an explosion of necrotic energy hitting all enemies.',
      type: SkillType.active,
      targetType: SkillTargetType.allEnemies,
      mpCost: 35,
      effect: SkillEffect(
        damageMultiplier: 1.2,
        damageType: DamageType.cursed,
        statusEffect: StatusEffectType.cursed,
        statusDuration: 3,
      ),
      iconAsset: 'assets/images/skills/death_nova.png',
      characterClassId: 'necromancer',
      prerequisiteSkillId: 'life_drain',
      treeTier: 3,
      treeBranch: 'darkness',
      skillPointCost: 2,
    ),

    // ── Rogue Skills ───────────────────────────────────────────────────────

    'backstab': const Skill(
      id: 'backstab',
      name: 'Backstab',
      description:
          'Strike from the shadows for massive damage. High crit chance.',
      type: SkillType.active,
      targetType: SkillTargetType.singleEnemy,
      mpCost: 15,
      effect: SkillEffect(
        damageMultiplier: 1.8,
        damageType: DamageType.physical,
      ),
      iconAsset: 'assets/images/skills/backstab.png',
      characterClassId: 'rogue',
      treeTier: 1,
      treeBranch: 'shadow',
    ),
    'hemorrhage': const Skill(
      id: 'hemorrhage',
      name: 'Hemorrhage',
      description: 'Apply a deep wound that causes bleeding for 3 turns.',
      type: SkillType.active,
      targetType: SkillTargetType.singleEnemy,
      mpCost: 12,
      effect: SkillEffect(
        damageMultiplier: 0.7,
        damageType: DamageType.bleed,
        statusEffect: StatusEffectType.bleed,
        statusDuration: 3,
      ),
      iconAsset: 'assets/images/skills/hemorrhage.png',
      characterClassId: 'rogue',
      treeTier: 1,
      treeBranch: 'shadow',
    ),
    'shadow_step': const Skill(
      id: 'shadow_step',
      name: 'Shadow Step',
      description:
          'Vanish into shadow, boosting evasion and next attack damage.',
      type: SkillType.active,
      targetType: SkillTargetType.self,
      mpCost: 20,
      effect: SkillEffect(
        attackBuff: 10,
        defenseBuff: 5,
      ),
      iconAsset: 'assets/images/skills/shadow_step.png',
      characterClassId: 'rogue',
      prerequisiteSkillId: 'backstab',
      treeTier: 2,
      treeBranch: 'shadow',
    ),
  };

  // ── Loot helper ────────────────────────────────────────────────────────────

  /// Returns item IDs to drop based on an enemy's loot table
  static List<String> rollLoot(EnemyDefinition enemy) {
    final drops = <String>[];
    for (final entry in enemy.lootTable) {
      final roll = _random();
      if (roll <= entry.dropChance) {
        drops.add(entry.itemId);
      }
    }
    return drops;
  }

  static double _random() {
    return DateTime.now().microsecondsSinceEpoch % 1000 / 1000.0;
  }
}
