// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkillEffectAdapter extends TypeAdapter<SkillEffect> {
  @override
  final int typeId = 23;

  @override
  SkillEffect read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SkillEffect(
      damageMultiplier: fields[0] as double?,
      damageType: fields[1] as DamageType,
      healAmount: fields[2] as int?,
      healPercent: fields[3] as double?,
      statusEffect: fields[4] as StatusEffectType?,
      statusDuration: fields[5] as int?,
      attackBuff: fields[6] as int?,
      defenseBuff: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SkillEffect obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.damageMultiplier)
      ..writeByte(1)
      ..write(obj.damageType)
      ..writeByte(2)
      ..write(obj.healAmount)
      ..writeByte(3)
      ..write(obj.healPercent)
      ..writeByte(4)
      ..write(obj.statusEffect)
      ..writeByte(5)
      ..write(obj.statusDuration)
      ..writeByte(6)
      ..write(obj.attackBuff)
      ..writeByte(7)
      ..write(obj.defenseBuff);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillEffectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SkillAdapter extends TypeAdapter<Skill> {
  @override
  final int typeId = 25;

  @override
  Skill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Skill(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as SkillType,
      targetType: fields[4] as SkillTargetType,
      mpCost: fields[5] as int,
      effect: fields[6] as SkillEffect,
      iconAsset: fields[7] as String,
      characterClassId: fields[8] as String,
      prerequisiteSkillId: fields[9] as String?,
      treeTier: fields[10] as int,
      treeBranch: fields[11] as String,
      skillPointCost: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Skill obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.targetType)
      ..writeByte(5)
      ..write(obj.mpCost)
      ..writeByte(6)
      ..write(obj.effect)
      ..writeByte(7)
      ..write(obj.iconAsset)
      ..writeByte(8)
      ..write(obj.characterClassId)
      ..writeByte(9)
      ..write(obj.prerequisiteSkillId)
      ..writeByte(10)
      ..write(obj.treeTier)
      ..writeByte(11)
      ..write(obj.treeBranch)
      ..writeByte(12)
      ..write(obj.skillPointCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SkillTypeAdapter extends TypeAdapter<SkillType> {
  @override
  final int typeId = 20;

  @override
  SkillType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SkillType.active;
      case 1:
        return SkillType.passive;
      default:
        return SkillType.active;
    }
  }

  @override
  void write(BinaryWriter writer, SkillType obj) {
    switch (obj) {
      case SkillType.active:
        writer.writeByte(0);
        break;
      case SkillType.passive:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SkillTargetTypeAdapter extends TypeAdapter<SkillTargetType> {
  @override
  final int typeId = 21;

  @override
  SkillTargetType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SkillTargetType.singleEnemy;
      case 1:
        return SkillTargetType.allEnemies;
      case 2:
        return SkillTargetType.self;
      case 3:
        return SkillTargetType.ally;
      default:
        return SkillTargetType.singleEnemy;
    }
  }

  @override
  void write(BinaryWriter writer, SkillTargetType obj) {
    switch (obj) {
      case SkillTargetType.singleEnemy:
        writer.writeByte(0);
        break;
      case SkillTargetType.allEnemies:
        writer.writeByte(1);
        break;
      case SkillTargetType.self:
        writer.writeByte(2);
        break;
      case SkillTargetType.ally:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillTargetTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DamageTypeAdapter extends TypeAdapter<DamageType> {
  @override
  final int typeId = 22;

  @override
  DamageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DamageType.physical;
      case 1:
        return DamageType.dark;
      case 2:
        return DamageType.cursed;
      case 3:
        return DamageType.bleed;
      case 4:
        return DamageType.none;
      default:
        return DamageType.physical;
    }
  }

  @override
  void write(BinaryWriter writer, DamageType obj) {
    switch (obj) {
      case DamageType.physical:
        writer.writeByte(0);
        break;
      case DamageType.dark:
        writer.writeByte(1);
        break;
      case DamageType.cursed:
        writer.writeByte(2);
        break;
      case DamageType.bleed:
        writer.writeByte(3);
        break;
      case DamageType.none:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DamageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatusEffectTypeAdapter extends TypeAdapter<StatusEffectType> {
  @override
  final int typeId = 24;

  @override
  StatusEffectType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StatusEffectType.poison;
      case 1:
        return StatusEffectType.burn;
      case 2:
        return StatusEffectType.bleed;
      case 3:
        return StatusEffectType.stun;
      case 4:
        return StatusEffectType.weakened;
      case 5:
        return StatusEffectType.empowered;
      case 6:
        return StatusEffectType.cursed;
      case 7:
        return StatusEffectType.regenerating;
      default:
        return StatusEffectType.poison;
    }
  }

  @override
  void write(BinaryWriter writer, StatusEffectType obj) {
    switch (obj) {
      case StatusEffectType.poison:
        writer.writeByte(0);
        break;
      case StatusEffectType.burn:
        writer.writeByte(1);
        break;
      case StatusEffectType.bleed:
        writer.writeByte(2);
        break;
      case StatusEffectType.stun:
        writer.writeByte(3);
        break;
      case StatusEffectType.weakened:
        writer.writeByte(4);
        break;
      case StatusEffectType.empowered:
        writer.writeByte(5);
        break;
      case StatusEffectType.cursed:
        writer.writeByte(6);
        break;
      case StatusEffectType.regenerating:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusEffectTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
