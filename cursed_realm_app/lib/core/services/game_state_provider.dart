import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/game_state.dart';
import '../models/character.dart';
import '../models/item.dart';
import '../data/game_data.dart';
import 'save_service.dart';

const _uuid = Uuid();

// ─── Provider ─────────────────────────────────────────────────────────────────

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState?>((ref) {
  return GameStateNotifier();
});

// ─── Notifier ─────────────────────────────────────────────────────────────────

class GameStateNotifier extends StateNotifier<GameState?> {
  GameStateNotifier() : super(null);

  // ── Lifecycle ───────────────────────────────────────────────────────────

  void loadGame() {
    final saved = SaveService.loadGame();
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> saveGame() async {
    final current = state;
    if (current == null) return;
    await SaveService.saveGame(current.copyWith(lastSaved: DateTime.now()));
  }

  // ── New Game ────────────────────────────────────────────────────────────

  void startNewGame({
    required String characterName,
    required CharacterClass characterClass,
  }) {
    final character = Character.create(
      id: _uuid.v4(),
      name: characterName,
      characterClass: characterClass,
    );

    final startingInventory = _buildStartingInventory(characterClass);

    state = GameState.newGame(
      character: character,
      startingInventory: startingInventory,
    );
    saveGame();
  }

  Inventory _buildStartingInventory(CharacterClass cls) {
    var inv = Inventory.empty();
    // Everyone starts with a couple health potions
    inv =
        inv.addItem(GameData.items['health_potion_sm']!.copyWith(quantity: 3));
    inv = inv.addItem(GameData.items['mana_potion']!.copyWith(quantity: 2));

    // Class-specific starting weapon
    switch (cls) {
      case CharacterClass.knight:
        inv = inv.addItem(GameData.items['rusted_sword']!);
        inv = inv.addItem(GameData.items['leather_armor']!);
        break;
      case CharacterClass.necromancer:
        inv = inv.addItem(GameData.items['necro_staff']!);
        break;
      case CharacterClass.rogue:
        inv = inv.addItem(GameData.items['shadow_dagger']!);
        break;
    }

    return inv;
  }

  // ── Character ───────────────────────────────────────────────────────────

  void updateCharacter(Character character) {
    state = state?.copyWith(character: character);
  }

  void gainExperience(int amount) {
    final current = state;
    if (current == null) return;
    final updatedChar = current.character.gainExperience(amount);
    state = current.copyWith(character: updatedChar);
  }

  void gainGold(int amount) {
    final current = state;
    if (current == null) return;
    final updatedChar = current.character.copyWith(
      gold: current.character.gold + amount,
    );
    state = current.copyWith(character: updatedChar);
  }

  // ── Inventory ───────────────────────────────────────────────────────────

  void addItem(Item item) {
    final current = state;
    if (current == null) return;
    final updatedInv = current.inventory.addItem(item);
    state = current.copyWith(inventory: updatedInv);
  }

  void removeItem(String itemId, {int quantity = 1}) {
    final current = state;
    if (current == null) return;
    final updatedInv = current.inventory.removeItem(itemId, quantity: quantity);
    state = current.copyWith(inventory: updatedInv);
  }

  // ── Phase ───────────────────────────────────────────────────────────────

  void setPhase(GamePhase phase) {
    state = state?.copyWith(phase: phase);
  }

  // ── Dungeon ─────────────────────────────────────────────────────────────

  void advanceFloor() {
    final current = state;
    if (current == null) return;
    final dp = current.dungeonProgress;
    final newFloor = dp.currentFloor + 1;
    state = current.copyWith(
      dungeonProgress: dp.copyWith(
        currentFloor: newFloor,
        deepestFloor: newFloor > dp.deepestFloor ? newFloor : dp.deepestFloor,
      ),
    );
  }

  void markRoomCleared(String roomId) {
    final current = state;
    if (current == null) return;
    final dp = current.dungeonProgress;
    if (dp.clearedRoomIds.contains(roomId)) return;
    state = current.copyWith(
      dungeonProgress: dp.copyWith(
        clearedRoomIds: [...dp.clearedRoomIds, roomId],
      ),
    );
  }

  void recordEnemyDefeated({bool isBoss = false}) {
    final current = state;
    if (current == null) return;
    final dp = current.dungeonProgress;
    state = current.copyWith(
      dungeonProgress: dp.copyWith(
        totalEnemiesDefeated: dp.totalEnemiesDefeated + 1,
        totalBossesDefeated:
            isBoss ? dp.totalBossesDefeated + 1 : dp.totalBossesDefeated,
      ),
    );
  }
}
