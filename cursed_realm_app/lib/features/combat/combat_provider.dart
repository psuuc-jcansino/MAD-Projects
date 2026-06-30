import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/character.dart';
import '../../core/models/enemy.dart';
import '../../core/services/game_state_provider.dart';
import 'combat_engine.dart';

final combatEngineProvider = Provider<CombatEngine>((ref) => CombatEngine());

final combatStateProvider =
    StateNotifierProvider<CombatNotifier, CombatState?>((ref) {
  return CombatNotifier(ref);
});

class CombatNotifier extends StateNotifier<CombatState?> {
  final Ref _ref;
  CombatNotifier(this._ref) : super(null);

  CombatEngine get _engine => _ref.read(combatEngineProvider);

  void startCombat({
    required Character character,
    required EnemyDefinition enemyDef,
    required int floorLevel,
  }) {
    state = _engine.initCombat(
      character: character,
      enemyDef: enemyDef,
      floorLevel: floorLevel,
    );
  }

  void performAction(CombatAction action) {
    final current = state;
    if (current == null) return;
    state = _engine.processPlayerAction(current, action);

    // If victory/defeat, apply rewards to game state
    if (state?.phase == CombatPhase.victory) {
      _applyVictoryRewards();
    }
  }

  void _applyVictoryRewards() {
    final combatState = state;
    if (combatState == null) return;

    final gameNotifier = _ref.read(gameStateProvider.notifier);
    final gameState = _ref.read(gameStateProvider);
    if (gameState == null) return;

    final floorLevel = gameState.dungeonProgress.currentFloor;
    final rewards = _engine.calculateRewards(combatState.enemy, floorLevel);

    // Apply exp & gold
    gameNotifier.gainExperience(rewards.expGained);
    gameNotifier.gainGold(rewards.goldGained);

    // Add dropped items
    for (final item in rewards.itemsDropped) {
      gameNotifier.addItem(item);
    }

    // Record enemy defeated
    gameNotifier.recordEnemyDefeated(
      isBoss: combatState.enemy.tier == EnemyTier.boss,
    );

    // Sync character HP/MP from combat back to game state
    gameNotifier.updateCharacter(combatState.character);

    gameNotifier.saveGame();
  }

  void endCombat() {
    // Sync final character state (e.g. after fleeing)
    final combatState = state;
    if (combatState != null) {
      _ref
          .read(gameStateProvider.notifier)
          .updateCharacter(combatState.character);
      _ref.read(gameStateProvider.notifier).saveGame();
    }
    state = null;
  }
}
