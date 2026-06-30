import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'item.g.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

@HiveType(typeId: 10)
enum ItemType {
  @HiveField(0)
  weapon,
  @HiveField(1)
  armor,
  @HiveField(2)
  accessory,
  @HiveField(3)
  relic,
  @HiveField(4)
  consumable,
}

@HiveType(typeId: 11)
enum ItemRarity {
  @HiveField(0)
  common,
  @HiveField(1)
  uncommon,
  @HiveField(2)
  rare,
  @HiveField(3)
  epic,
  @HiveField(4)
  legendary,
}

extension ItemRarityX on ItemRarity {
  String get displayName {
    switch (this) {
      case ItemRarity.common:
        return 'Common';
      case ItemRarity.uncommon:
        return 'Uncommon';
      case ItemRarity.rare:
        return 'Rare';
      case ItemRarity.epic:
        return 'Epic';
      case ItemRarity.legendary:
        return 'Legendary';
    }
  }

  /// Hex color string for rarity display
  int get colorValue {
    switch (this) {
      case ItemRarity.common:
        return 0xFFAAAAAA;
      case ItemRarity.uncommon:
        return 0xFF4CAF50;
      case ItemRarity.rare:
        return 0xFF2196F3;
      case ItemRarity.epic:
        return 0xFF9C27B0;
      case ItemRarity.legendary:
        return 0xFFFF9800;
    }
  }
}

extension ItemTypeX on ItemType {
  String get displayName {
    switch (this) {
      case ItemType.weapon:
        return 'Weapon';
      case ItemType.armor:
        return 'Armor';
      case ItemType.accessory:
        return 'Accessory';
      case ItemType.relic:
        return 'Relic';
      case ItemType.consumable:
        return 'Consumable';
    }
  }

  bool get isEquippable => this != ItemType.consumable;
}

// ─── Stat Bonus ───────────────────────────────────────────────────────────────

@HiveType(typeId: 12)
class StatBonus extends Equatable {
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
  @HiveField(5)
  final double critChance;

  const StatBonus({
    this.hp = 0,
    this.mp = 0,
    this.attack = 0,
    this.defense = 0,
    this.speed = 0,
    this.critChance = 0,
  });

  static const empty = StatBonus();

  @override
  List<Object?> get props => [hp, mp, attack, defense, speed, critChance];
}

// ─── Item ─────────────────────────────────────────────────────────────────────

@HiveType(typeId: 13)
class Item extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final ItemType type;
  @HiveField(4)
  final ItemRarity rarity;
  @HiveField(5)
  final StatBonus statBonus;
  @HiveField(6)
  final int goldValue;
  @HiveField(7)
  final String iconAsset;
  @HiveField(8)
  final int? healAmount; // for consumables
  @HiveField(9)
  final int? mpRestoreAmount; // for consumables
  @HiveField(10)
  final int quantity;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.statBonus,
    required this.goldValue,
    required this.iconAsset,
    this.healAmount,
    this.mpRestoreAmount,
    this.quantity = 1,
  });

  bool get isConsumable => type == ItemType.consumable;

  Item copyWith({int? quantity}) {
    return Item(
      id: id,
      name: name,
      description: description,
      type: type,
      rarity: rarity,
      statBonus: statBonus,
      goldValue: goldValue,
      iconAsset: iconAsset,
      healAmount: healAmount,
      mpRestoreAmount: mpRestoreAmount,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, name, type, rarity, quantity];
}

// ─── Inventory ────────────────────────────────────────────────────────────────

@HiveType(typeId: 14)
class Inventory extends Equatable {
  @HiveField(0)
  final List<Item> items;
  static const int maxSlots = 30;

  const Inventory({required this.items});

  factory Inventory.empty() => const Inventory(items: []);

  bool get isFull => items.length >= maxSlots;

  Inventory addItem(Item item) {
    // Stack consumables
    if (item.isConsumable) {
      final idx = items.indexWhere((i) => i.id == item.id);
      if (idx != -1) {
        final updated = List<Item>.from(items);
        updated[idx] = updated[idx]
            .copyWith(quantity: updated[idx].quantity + item.quantity);
        return Inventory(items: updated);
      }
    }
    if (isFull) return this;
    return Inventory(items: [...items, item]);
  }

  Inventory removeItem(String itemId, {int quantity = 1}) {
    final idx = items.indexWhere((i) => i.id == itemId);
    if (idx == -1) return this;
    final item = items[idx];
    final updated = List<Item>.from(items);
    if (item.quantity <= quantity) {
      updated.removeAt(idx);
    } else {
      updated[idx] = item.copyWith(quantity: item.quantity - quantity);
    }
    return Inventory(items: updated);
  }

  Item? getItem(String itemId) {
    try {
      return items.firstWhere((i) => i.id == itemId);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [items];
}
