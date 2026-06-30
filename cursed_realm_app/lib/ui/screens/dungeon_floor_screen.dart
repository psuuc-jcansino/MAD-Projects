import 'dart:math';
import 'package:cursed_realm/core/models/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/data/game_data.dart';
import '../../core/models/enemy.dart';
import '../../core/services/game_state_provider.dart';
import '../../features/combat/combat_provider.dart';
import '../../ui/theme/app_theme.dart';
import 'combat_screen.dart';
import 'game_over_screen.dart';

// ─── Room types ───────────────────────────────────────────────────────────────

enum RoomType { combat, elite, treasure, rest, boss }

class DungeonRoom {
  final String id;
  final RoomType type;
  final int position;
  bool isCleared;
  bool isLocked;

  DungeonRoom({
    required this.id,
    required this.type,
    required this.position,
    this.isCleared = false,
    this.isLocked = true,
  });
}

// ─── Floor generator ─────────────────────────────────────────────────────────

List<DungeonRoom> generateFloor(int floorNumber, {int roomCount = 6}) {
  final rng = Random(floorNumber * 31);
  final rooms = <DungeonRoom>[];

  for (int i = 0; i < roomCount; i++) {
    RoomType type;
    if (i == 0) {
      type = RoomType.combat;
    } else if (i == roomCount - 1) {
      type = floorNumber % 5 == 0 ? RoomType.boss : RoomType.combat;
    } else {
      final roll = rng.nextDouble();
      if (roll < 0.50)
        type = RoomType.combat;
      else if (roll < 0.70)
        type = RoomType.elite;
      else if (roll < 0.85)
        type = RoomType.treasure;
      else
        type = RoomType.rest;
    }

    rooms.add(DungeonRoom(
      id: 'floor${floorNumber}_room$i',
      type: type,
      position: i,
      isLocked: i != 0,
      isCleared: false,
    ));
  }

  return rooms;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class DungeonFloorScreen extends ConsumerStatefulWidget {
  const DungeonFloorScreen({super.key});

  @override
  ConsumerState<DungeonFloorScreen> createState() => _DungeonFloorScreenState();
}

class _DungeonFloorScreenState extends ConsumerState<DungeonFloorScreen> {
  late List<DungeonRoom> _rooms;
  int _currentRoomIndex = 0;

  @override
  void initState() {
    super.initState();
    final gameState = ref.read(gameStateProvider);
    final floor = gameState?.dungeonProgress.currentFloor ?? 1;
    _rooms = generateFloor(floor);
    _rooms[0].isLocked = false;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == null) return const SizedBox.shrink();

    final character = gameState.character;
    final floor = gameState.dungeonProgress.currentFloor;
    final currentRoom = _rooms[_currentRoomIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050508), Color(0xFF08040E), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios,
                          color: AppTheme.textSecondary),
                    ),
                    const Spacer(),
                    Text(
                      'FLOOR $floor',
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        letterSpacing: 3,
                      ),
                    ),
                    const Spacer(),
                    // HP mini display
                    Row(
                      children: [
                        const Icon(Icons.favorite,
                            color: AppTheme.hpRed, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${character.stats.hp}',
                          style: GoogleFonts.cinzel(
                              fontSize: 12,
                              color: AppTheme.hpRed,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Room path ──────────────────────────────────────────────
              FadeInDown(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _rooms.asMap().entries.map((entry) {
                      final i = entry.key;
                      final room = entry.value;
                      final isCurrent = i == _currentRoomIndex;

                      return Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _RoomNode(
                                room: room,
                                isCurrent: isCurrent,
                                onTap: !room.isLocked
                                    ? () =>
                                        setState(() => _currentRoomIndex = i)
                                    : null,
                              ),
                            ),
                            if (i < _rooms.length - 1)
                              Container(
                                height: 2,
                                width: 8,
                                color: room.isCleared
                                    ? AppTheme.xpGreen.withOpacity(0.5)
                                    : AppTheme.border,
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Current room card ──────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FadeInUp(
                    key: ValueKey(_currentRoomIndex),
                    child: _RoomCard(
                      room: currentRoom,
                      floorLevel: floor,
                      onEnter: () => _enterRoom(context, currentRoom, floor),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _enterRoom(
      BuildContext context, DungeonRoom room, int floorLevel) async {
    switch (room.type) {
      case RoomType.combat:
      case RoomType.elite:
      case RoomType.boss:
        await _startCombat(context, room, floorLevel);
        break;
      case RoomType.treasure:
        _openTreasure(context, room);
        break;
      case RoomType.rest:
        _restAtCampfire(context, room);
        break;
    }
  }

  Future<void> _startCombat(
      BuildContext context, DungeonRoom room, int floorLevel) async {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    // Pick enemy based on room type
    EnemyDefinition enemyDef;
    if (room.type == RoomType.boss) {
      enemyDef = GameData.enemies['the_lich_king']!;
    } else if (room.type == RoomType.elite) {
      final elites = GameData.enemies.values
          .where(
              (e) => e.tier == EnemyTier.elite && e.minFloorLevel <= floorLevel)
          .toList();
      elites.shuffle();
      enemyDef =
          elites.isNotEmpty ? elites.first : GameData.enemies.values.first;
    } else {
      final minions = GameData.enemies.values
          .where((e) =>
              e.tier == EnemyTier.minion && e.minFloorLevel <= floorLevel)
          .toList();
      minions.shuffle();
      enemyDef =
          minions.isNotEmpty ? minions.first : GameData.enemies.values.first;
    }

    ref.read(combatStateProvider.notifier).startCombat(
          character: gameState.character,
          enemyDef: enemyDef,
          floorLevel: floorLevel,
        );

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CombatScreen()),
    );

    // After combat returns, check if won
    final updatedState = ref.read(gameStateProvider);
    if (updatedState == null) return;

    // Check if it was the Lich King — trigger Victory screen
    if (room.type == RoomType.boss && enemyDef.id == 'the_lich_king') {
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const VictoryScreen()),
          (route) => false,
        );
      }
      return;
    }

    setState(() {
      room.isCleared = true;
      ref.read(gameStateProvider.notifier).markRoomCleared(room.id);

      // Unlock next room
      final nextIdx = _currentRoomIndex + 1;
      if (nextIdx < _rooms.length) {
        _rooms[nextIdx].isLocked = false;
        _currentRoomIndex = nextIdx;
      }

      // If all rooms cleared, advance floor
      if (_rooms.every((r) => r.isCleared)) {
        _showFloorClearDialog(context, floorLevel);
      }
    });
  }

  void _openTreasure(BuildContext context, DungeonRoom room) {
    if (room.isCleared) return;

    // Roll for random item from loot pool
    final items = GameData.items.values.where((i) => !i.isConsumable).toList()
      ..shuffle();
    final reward = items.isNotEmpty ? items.first : null;

    setState(() {
      room.isCleared = true;
      ref.read(gameStateProvider.notifier).markRoomCleared(room.id);
      if (reward != null) {
        ref.read(gameStateProvider.notifier).addItem(reward);
      }
      // Unlock next room
      final nextIdx = _currentRoomIndex + 1;
      if (nextIdx < _rooms.length) {
        _rooms[nextIdx].isLocked = false;
        _currentRoomIndex = nextIdx;
      }
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        title: Text('TREASURE!',
            style: GoogleFonts.cinzel(
                color: AppTheme.gold,
                fontWeight: FontWeight.bold,
                letterSpacing: 3),
            textAlign: TextAlign.center),
        content: reward != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2,
                      color: Color(reward.rarity.colorValue), size: 40),
                  const SizedBox(height: 8),
                  Text(reward.name,
                      style: GoogleFonts.cinzel(
                          color: Color(reward.rarity.colorValue),
                          fontWeight: FontWeight.bold)),
                  Text(reward.description,
                      style: GoogleFonts.cinzel(
                          color: AppTheme.textSecondary, fontSize: 11),
                      textAlign: TextAlign.center),
                ],
              )
            : Text('The chest was empty...',
                style: GoogleFonts.cinzel(color: AppTheme.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('TAKE IT',
                style: GoogleFonts.cinzel(
                    color: AppTheme.gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _restAtCampfire(BuildContext context, DungeonRoom room) {
    if (room.isCleared) return;

    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    // Restore 30% HP and 50% MP
    final character = gameState.character;
    final healAmt = (character.stats.maxHp * 0.3).round();
    final mpAmt = (character.stats.maxMp * 0.5).round();
    final healed = character.heal(healAmt).restoreMp(mpAmt);

    ref.read(gameStateProvider.notifier).updateCharacter(healed);
    ref.read(gameStateProvider.notifier).saveGame();

    setState(() {
      room.isCleared = true;
      ref.read(gameStateProvider.notifier).markRoomCleared(room.id);
      final nextIdx = _currentRoomIndex + 1;
      if (nextIdx < _rooms.length) {
        _rooms[nextIdx].isLocked = false;
        _currentRoomIndex = nextIdx;
      }
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        title: Text('REST',
            style: GoogleFonts.cinzel(
                color: AppTheme.xpGreen,
                fontWeight: FontWeight.bold,
                letterSpacing: 3),
            textAlign: TextAlign.center),
        content: Text(
          'You rest by a flickering flame.\n+$healAmt HP  •  +$mpAmt MP',
          style:
              GoogleFonts.cinzel(color: AppTheme.textSecondary, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CONTINUE',
                style: GoogleFonts.cinzel(color: AppTheme.xpGreen)),
          ),
        ],
      ),
    );
  }

  void _showFloorClearDialog(BuildContext context, int floorLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        title: Text('FLOOR $floorLevel CLEARED!',
            style: GoogleFonts.cinzel(
                color: AppTheme.gold,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
            textAlign: TextAlign.center),
        content: Text(
          'You descend deeper into the Cursed Realm...',
          style:
              GoogleFonts.cinzel(color: AppTheme.textSecondary, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(gameStateProvider.notifier).advanceFloor();
              setState(() {
                final newFloor =
                    ref.read(gameStateProvider)!.dungeonProgress.currentFloor;
                _rooms = generateFloor(newFloor);
                _rooms[0].isLocked = false;
                _currentRoomIndex = 0;
              });
            },
            child: Text('DESCEND',
                style: GoogleFonts.cinzel(
                    color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _RoomNode extends StatelessWidget {
  final DungeonRoom room;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _RoomNode({
    required this.room,
    required this.isCurrent,
    this.onTap,
  });

  IconData get _icon {
    switch (room.type) {
      case RoomType.combat:
        return Icons.dangerous;
      case RoomType.elite:
        return Icons.local_fire_department;
      case RoomType.treasure:
        return Icons.workspace_premium;
      case RoomType.rest:
        return Icons.local_cafe;
      case RoomType.boss:
        return Icons.warning_amber;
    }
  }

  Color get _color {
    if (room.isCleared) return AppTheme.xpGreen;
    if (room.isLocked) return AppTheme.textMuted;
    switch (room.type) {
      case RoomType.combat:
        return AppTheme.primary;
      case RoomType.elite:
        return Colors.orange;
      case RoomType.treasure:
        return AppTheme.gold;
      case RoomType.rest:
        return AppTheme.mpBlue;
      case RoomType.boss:
        return AppTheme.rarityLegendary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isCurrent ? color.withOpacity(0.2) : color.withOpacity(0.05),
          border: Border.all(
            color: isCurrent ? color : color.withOpacity(0.3),
            width: isCurrent ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Icon(
              room.isCleared ? Icons.check_circle : _icon,
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final DungeonRoom room;
  final int floorLevel;
  final VoidCallback onEnter;

  const _RoomCard({
    required this.room,
    required this.floorLevel,
    required this.onEnter,
  });

  String get _title {
    switch (room.type) {
      case RoomType.combat:
        return 'ENEMY ENCOUNTER';
      case RoomType.elite:
        return 'ELITE ENEMY';
      case RoomType.treasure:
        return 'TREASURE CHEST';
      case RoomType.rest:
        return 'CAMPFIRE';
      case RoomType.boss:
        return 'BOSS CHAMBER';
    }
  }

  String get _description {
    switch (room.type) {
      case RoomType.combat:
        return 'A shadowy creature lurks ahead. Steel yourself for battle.';
      case RoomType.elite:
        return 'A powerful foe guards this path. Defeat it for greater rewards.';
      case RoomType.treasure:
        return 'A chest gleams in the darkness. Riches await the bold.';
      case RoomType.rest:
        return 'A dying flame offers brief respite. Rest to recover HP and MP.';
      case RoomType.boss:
        return 'An ancient evil awakens. This is the true test of your power.';
    }
  }

  Color get _color {
    switch (room.type) {
      case RoomType.combat:
        return AppTheme.primary;
      case RoomType.elite:
        return Colors.orange;
      case RoomType.treasure:
        return AppTheme.gold;
      case RoomType.rest:
        return AppTheme.mpBlue;
      case RoomType.boss:
        return AppTheme.rarityLegendary;
    }
  }

  IconData get _icon {
    switch (room.type) {
      case RoomType.combat:
        return Icons.dangerous;
      case RoomType.elite:
        return Icons.local_fire_department;
      case RoomType.treasure:
        return Icons.workspace_premium;
      case RoomType.rest:
        return Icons.local_cafe;
      case RoomType.boss:
        return Icons.warning_amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeIn(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              border: Border.all(color: color.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(_icon, color: color, size: 52),
                const SizedBox(height: 16),
                Text(
                  _title,
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _description,
                  style: GoogleFonts.cinzel(
                      fontSize: 12, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (room.isCleared)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.xpGreen.withOpacity(0.1),
                      border:
                          Border.all(color: AppTheme.xpGreen.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'CLEARED',
                      style: GoogleFonts.cinzel(
                        color: AppTheme.xpGreen,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onEnter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color.withOpacity(0.2),
                        side: BorderSide(color: color.withOpacity(0.6)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        room.type == RoomType.rest
                            ? 'REST HERE'
                            : room.type == RoomType.treasure
                                ? 'OPEN CHEST'
                                : 'ENTER ROOM',
                        style: GoogleFonts.cinzel(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
