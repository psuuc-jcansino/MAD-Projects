// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatBonusAdapter extends TypeAdapter<StatBonus> {
  @override
  final int typeId = 12;

  @override
  StatBonus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatBonus(
      hp: fields[0] as int,
      mp: fields[1] as int,
      attack: fields[2] as int,
      defense: fields[3] as int,
      speed: fields[4] as int,
      critChance: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, StatBonus obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.hp)
      ..writeByte(1)
      ..write(obj.mp)
      ..writeByte(2)
      ..write(obj.attack)
      ..writeByte(3)
      ..write(obj.defense)
      ..writeByte(4)
      ..write(obj.speed)
      ..writeByte(5)
      ..write(obj.critChance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatBonusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 13;

  @override
  Item read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Item(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as ItemType,
      rarity: fields[4] as ItemRarity,
      statBonus: fields[5] as StatBonus,
      goldValue: fields[6] as int,
      iconAsset: fields[7] as String,
      healAmount: fields[8] as int?,
      mpRestoreAmount: fields[9] as int?,
      quantity: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.rarity)
      ..writeByte(5)
      ..write(obj.statBonus)
      ..writeByte(6)
      ..write(obj.goldValue)
      ..writeByte(7)
      ..write(obj.iconAsset)
      ..writeByte(8)
      ..write(obj.healAmount)
      ..writeByte(9)
      ..write(obj.mpRestoreAmount)
      ..writeByte(10)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InventoryAdapter extends TypeAdapter<Inventory> {
  @override
  final int typeId = 14;

  @override
  Inventory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Inventory(
      items: (fields[0] as List).cast<Item>(),
    );
  }

  @override
  void write(BinaryWriter writer, Inventory obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemTypeAdapter extends TypeAdapter<ItemType> {
  @override
  final int typeId = 10;

  @override
  ItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemType.weapon;
      case 1:
        return ItemType.armor;
      case 2:
        return ItemType.accessory;
      case 3:
        return ItemType.relic;
      case 4:
        return ItemType.consumable;
      default:
        return ItemType.weapon;
    }
  }

  @override
  void write(BinaryWriter writer, ItemType obj) {
    switch (obj) {
      case ItemType.weapon:
        writer.writeByte(0);
        break;
      case ItemType.armor:
        writer.writeByte(1);
        break;
      case ItemType.accessory:
        writer.writeByte(2);
        break;
      case ItemType.relic:
        writer.writeByte(3);
        break;
      case ItemType.consumable:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemRarityAdapter extends TypeAdapter<ItemRarity> {
  @override
  final int typeId = 11;

  @override
  ItemRarity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemRarity.common;
      case 1:
        return ItemRarity.uncommon;
      case 2:
        return ItemRarity.rare;
      case 3:
        return ItemRarity.epic;
      case 4:
        return ItemRarity.legendary;
      default:
        return ItemRarity.common;
    }
  }

  @override
  void write(BinaryWriter writer, ItemRarity obj) {
    switch (obj) {
      case ItemRarity.common:
        writer.writeByte(0);
        break;
      case ItemRarity.uncommon:
        writer.writeByte(1);
        break;
      case ItemRarity.rare:
        writer.writeByte(2);
        break;
      case ItemRarity.epic:
        writer.writeByte(3);
        break;
      case ItemRarity.legendary:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemRarityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
