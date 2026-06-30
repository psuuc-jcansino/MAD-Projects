// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CharacterStatsAdapter extends TypeAdapter<CharacterStats> {
  @override
  final int typeId = 1;

  @override
  CharacterStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CharacterStats(
      hp: fields[0] as int,
      maxHp: fields[1] as int,
      mp: fields[2] as int,
      maxMp: fields[3] as int,
      attack: fields[4] as int,
      defense: fields[5] as int,
      speed: fields[6] as int,
      critChance: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CharacterStats obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.hp)
      ..writeByte(1)
      ..write(obj.maxHp)
      ..writeByte(2)
      ..write(obj.mp)
      ..writeByte(3)
      ..write(obj.maxMp)
      ..writeByte(4)
      ..write(obj.attack)
      ..writeByte(5)
      ..write(obj.defense)
      ..writeByte(6)
      ..write(obj.speed)
      ..writeByte(7)
      ..write(obj.critChance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatGrowthAdapter extends TypeAdapter<StatGrowth> {
  @override
  final int typeId = 2;

  @override
  StatGrowth read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatGrowth(
      hp: fields[0] as int,
      mp: fields[1] as int,
      attack: fields[2] as int,
      defense: fields[3] as int,
      speed: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StatGrowth obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.hp)
      ..writeByte(1)
      ..write(obj.mp)
      ..writeByte(2)
      ..write(obj.attack)
      ..writeByte(3)
      ..write(obj.defense)
      ..writeByte(4)
      ..write(obj.speed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatGrowthAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CharacterAdapter extends TypeAdapter<Character> {
  @override
  final int typeId = 3;

  @override
  Character read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Character(
      id: fields[0] as String,
      name: fields[1] as String,
      characterClass: fields[2] as CharacterClass,
      stats: fields[3] as CharacterStats,
      level: fields[4] as int,
      experience: fields[5] as int,
      experienceToNextLevel: fields[6] as int,
      unlockedSkillIds: (fields[7] as List).cast<String>(),
      equippedSkillIds: (fields[8] as List).cast<String>(),
      equipment: fields[9] as EquipmentSlots,
      statPoints: fields[10] as int,
      skillPoints: fields[11] as int,
      gold: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Character obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.characterClass)
      ..writeByte(3)
      ..write(obj.stats)
      ..writeByte(4)
      ..write(obj.level)
      ..writeByte(5)
      ..write(obj.experience)
      ..writeByte(6)
      ..write(obj.experienceToNextLevel)
      ..writeByte(7)
      ..write(obj.unlockedSkillIds)
      ..writeByte(8)
      ..write(obj.equippedSkillIds)
      ..writeByte(9)
      ..write(obj.equipment)
      ..writeByte(10)
      ..write(obj.statPoints)
      ..writeByte(11)
      ..write(obj.skillPoints)
      ..writeByte(12)
      ..write(obj.gold);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EquipmentSlotsAdapter extends TypeAdapter<EquipmentSlots> {
  @override
  final int typeId = 4;

  @override
  EquipmentSlots read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EquipmentSlots(
      weaponId: fields[0] as String?,
      armorId: fields[1] as String?,
      accessoryId: fields[2] as String?,
      relicId: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EquipmentSlots obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.weaponId)
      ..writeByte(1)
      ..write(obj.armorId)
      ..writeByte(2)
      ..write(obj.accessoryId)
      ..writeByte(3)
      ..write(obj.relicId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentSlotsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CharacterClassAdapter extends TypeAdapter<CharacterClass> {
  @override
  final int typeId = 0;

  @override
  CharacterClass read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CharacterClass.knight;
      case 1:
        return CharacterClass.necromancer;
      case 2:
        return CharacterClass.rogue;
      default:
        return CharacterClass.knight;
    }
  }

  @override
  void write(BinaryWriter writer, CharacterClass obj) {
    switch (obj) {
      case CharacterClass.knight:
        writer.writeByte(0);
        break;
      case CharacterClass.necromancer:
        writer.writeByte(1);
        break;
      case CharacterClass.rogue:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
