// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DungeonProgressAdapter extends TypeAdapter<DungeonProgress> {
  @override
  final int typeId = 41;

  @override
  DungeonProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DungeonProgress(
      currentFloor: fields[0] as int,
      deepestFloor: fields[1] as int,
      totalEnemiesDefeated: fields[2] as int,
      totalBossesDefeated: fields[3] as int,
      clearedRoomIds: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DungeonProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.currentFloor)
      ..writeByte(1)
      ..write(obj.deepestFloor)
      ..writeByte(2)
      ..write(obj.totalEnemiesDefeated)
      ..writeByte(3)
      ..write(obj.totalBossesDefeated)
      ..writeByte(4)
      ..write(obj.clearedRoomIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DungeonProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GameStateAdapter extends TypeAdapter<GameState> {
  @override
  final int typeId = 42;

  @override
  GameState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameState(
      character: fields[0] as Character,
      inventory: fields[1] as Inventory,
      dungeonProgress: fields[2] as DungeonProgress,
      phase: fields[3] as GamePhase,
      playTimeSeconds: fields[4] as int,
      lastSaved: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GameState obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.character)
      ..writeByte(1)
      ..write(obj.inventory)
      ..writeByte(2)
      ..write(obj.dungeonProgress)
      ..writeByte(3)
      ..write(obj.phase)
      ..writeByte(4)
      ..write(obj.playTimeSeconds)
      ..writeByte(5)
      ..write(obj.lastSaved);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GamePhaseAdapter extends TypeAdapter<GamePhase> {
  @override
  final int typeId = 40;

  @override
  GamePhase read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GamePhase.mainMenu;
      case 1:
        return GamePhase.characterSelect;
      case 2:
        return GamePhase.dungeon;
      case 3:
        return GamePhase.combat;
      case 4:
        return GamePhase.inventory;
      case 5:
        return GamePhase.skillTree;
      case 6:
        return GamePhase.gameOver;
      case 7:
        return GamePhase.victory;
      default:
        return GamePhase.mainMenu;
    }
  }

  @override
  void write(BinaryWriter writer, GamePhase obj) {
    switch (obj) {
      case GamePhase.mainMenu:
        writer.writeByte(0);
        break;
      case GamePhase.characterSelect:
        writer.writeByte(1);
        break;
      case GamePhase.dungeon:
        writer.writeByte(2);
        break;
      case GamePhase.combat:
        writer.writeByte(3);
        break;
      case GamePhase.inventory:
        writer.writeByte(4);
        break;
      case GamePhase.skillTree:
        writer.writeByte(5);
        break;
      case GamePhase.gameOver:
        writer.writeByte(6);
        break;
      case GamePhase.victory:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamePhaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
