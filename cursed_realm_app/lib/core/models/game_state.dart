import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'character.dart';
import 'item.dart';

part 'game_state.g.dart';

@HiveType(typeId: 40)
enum GamePhase {
  @HiveField(0)
  mainMenu,
  @HiveField(1)
  characterSelect,
  @HiveField(2)
  dungeon,
  @HiveField(3)
  combat,
  @HiveField(4)
  inventory,
  @HiveField(5)
  skillTree,
  @HiveField(6)
  gameOver,
  @HiveField(7)
  victory,
}

@HiveType(typeId: 41)
class DungeonProgress {
  @HiveField(0)
  final int currentFloor;
  @HiveField(1)
  final int deepestFloor;
  @HiveField(2)
  final int totalEnemiesDefeated;
  @HiveField(3)
  final int totalBossesDefeated;
  @HiveField(4)
  final List<String> clearedRoomIds;

  const DungeonProgress({
    required this.currentFloor,
    required this.deepestFloor,
    required this.totalEnemiesDefeated,
    required this.totalBossesDefeated,
    required this.clearedRoomIds,
  });

  factory DungeonProgress.initial() => const DungeonProgress(
        currentFloor: 1,
        deepestFloor: 1,
        totalEnemiesDefeated: 0,
        totalBossesDefeated: 0,
        clearedRoomIds: [],
      );

  DungeonProgress copyWith({
    int? currentFloor,
    int? deepestFloor,
    int? totalEnemiesDefeated,
    int? totalBossesDefeated,
    List<String>? clearedRoomIds,
  }) {
    return DungeonProgress(
      currentFloor: currentFloor ?? this.currentFloor,
      deepestFloor: deepestFloor ?? this.deepestFloor,
      totalEnemiesDefeated: totalEnemiesDefeated ?? this.totalEnemiesDefeated,
      totalBossesDefeated: totalBossesDefeated ?? this.totalBossesDefeated,
      clearedRoomIds: clearedRoomIds ?? this.clearedRoomIds,
    );
  }
}

@HiveType(typeId: 42)
class GameState extends Equatable {
  @HiveField(0)
  final Character character;
  @HiveField(1)
  final Inventory inventory;
  @HiveField(2)
  final DungeonProgress dungeonProgress;
  @HiveField(3)
  final GamePhase phase;
  @HiveField(4)
  final int playTimeSeconds;
  @HiveField(5)
  final DateTime lastSaved;

  const GameState({
    required this.character,
    required this.inventory,
    required this.dungeonProgress,
    required this.phase,
    required this.playTimeSeconds,
    required this.lastSaved,
  });

  factory GameState.newGame({
    required Character character,
    required Inventory startingInventory,
  }) {
    return GameState(
      character: character,
      inventory: startingInventory,
      dungeonProgress: DungeonProgress.initial(),
      phase: GamePhase.dungeon,
      playTimeSeconds: 0,
      lastSaved: DateTime.now(),
    );
  }

  GameState copyWith({
    Character? character,
    Inventory? inventory,
    DungeonProgress? dungeonProgress,
    GamePhase? phase,
    int? playTimeSeconds,
    DateTime? lastSaved,
  }) {
    return GameState(
      character: character ?? this.character,
      inventory: inventory ?? this.inventory,
      dungeonProgress: dungeonProgress ?? this.dungeonProgress,
      phase: phase ?? this.phase,
      playTimeSeconds: playTimeSeconds ?? this.playTimeSeconds,
      lastSaved: lastSaved ?? this.lastSaved,
    );
  }

  @override
  List<Object?> get props => [character, inventory, dungeonProgress, phase];
}
