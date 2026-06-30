// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enemy.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LootEntryAdapter extends TypeAdapter<LootEntry> {
  @override
  final int typeId = 32;

  @override
  LootEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LootEntry(
      itemId: fields[0] as String,
      dropChance: fields[1] as double,
      minQuantity: fields[2] as int,
      maxQuantity: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LootEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.itemId)
      ..writeByte(1)
      ..write(obj.dropChance)
      ..writeByte(2)
      ..write(obj.minQuantity)
      ..writeByte(3)
      ..write(obj.maxQuantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LootEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnemyStatsAdapter extends TypeAdapter<EnemyStats> {
  @override
  final int typeId = 33;

  @override
  EnemyStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnemyStats(
      hp: fields[0] as int,
      maxHp: fields[1] as int,
      attack: fields[2] as int,
      defense: fields[3] as int,
      speed: fields[4] as int,
      critChance: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, EnemyStats obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.hp)
      ..writeByte(1)
      ..write(obj.maxHp)
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
      other is EnemyStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnemyDefinitionAdapter extends TypeAdapter<EnemyDefinition> {
  @override
  final int typeId = 34;

  @override
  EnemyDefinition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnemyDefinition(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      tier: fields[3] as EnemyTier,
      aiPattern: fields[4] as EnemyAIPattern,
      baseStats: fields[5] as EnemyStats,
      skillIds: (fields[6] as List).cast<String>(),
      lootTable: (fields[7] as List).cast<LootEntry>(),
      baseExpReward: fields[8] as int,
      baseGoldReward: fields[9] as int,
      spriteAsset: fields[10] as String,
      minFloorLevel: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, EnemyDefinition obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.tier)
      ..writeByte(4)
      ..write(obj.aiPattern)
      ..writeByte(5)
      ..write(obj.baseStats)
      ..writeByte(6)
      ..write(obj.skillIds)
      ..writeByte(7)
      ..write(obj.lootTable)
      ..writeByte(8)
      ..write(obj.baseExpReward)
      ..writeByte(9)
      ..write(obj.baseGoldReward)
      ..writeByte(10)
      ..write(obj.spriteAsset)
      ..writeByte(11)
      ..write(obj.minFloorLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnemyDefinitionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnemyTierAdapter extends TypeAdapter<EnemyTier> {
  @override
  final int typeId = 30;

  @override
  EnemyTier read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EnemyTier.minion;
      case 1:
        return EnemyTier.elite;
      case 2:
        return EnemyTier.boss;
      default:
        return EnemyTier.minion;
    }
  }

  @override
  void write(BinaryWriter writer, EnemyTier obj) {
    switch (obj) {
      case EnemyTier.minion:
        writer.writeByte(0);
        break;
      case EnemyTier.elite:
        writer.writeByte(1);
        break;
      case EnemyTier.boss:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnemyTierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnemyAIPatternAdapter extends TypeAdapter<EnemyAIPattern> {
  @override
  final int typeId = 31;

  @override
  EnemyAIPattern read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EnemyAIPattern.aggressive;
      case 1:
        return EnemyAIPattern.strategic;
      case 2:
        return EnemyAIPattern.defensive;
      case 3:
        return EnemyAIPattern.berserker;
      default:
        return EnemyAIPattern.aggressive;
    }
  }

  @override
  void write(BinaryWriter writer, EnemyAIPattern obj) {
    switch (obj) {
      case EnemyAIPattern.aggressive:
        writer.writeByte(0);
        break;
      case EnemyAIPattern.strategic:
        writer.writeByte(1);
        break;
      case EnemyAIPattern.defensive:
        writer.writeByte(2);
        break;
      case EnemyAIPattern.berserker:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnemyAIPatternAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
