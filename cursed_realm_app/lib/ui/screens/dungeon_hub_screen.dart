import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/models/character.dart';
import '../../core/services/game_state_provider.dart';
import '../../ui/theme/app_theme.dart';
import 'inventory_screen.dart';
import 'skill_tree_screen.dart';
import 'dungeon_floor_screen.dart';
import 'shop_screen.dart';
import 'level_up_screen.dart';

class DungeonHubScreen extends ConsumerWidget {
  const DungeonHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == null) return const SizedBox.shrink();

    final character = gameState.character;
    final dungeon = gameState.dungeonProgress;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050508), Color(0xFF0A0A0F), Color(0xFF08050D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────────────────
              FadeInDown(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      // Floor badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.12),
                          border: Border.all(
                              color: AppTheme.primary.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.layers,
                                color: AppTheme.primary, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'FLOOR ${dungeon.currentFloor}',
                              style: GoogleFonts.cinzel(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Gold
                      Row(
                        children: [
                          const Icon(Icons.monetization_on,
                              color: AppTheme.gold, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${character.gold}',
                            style: GoogleFonts.cinzel(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Character card ────────────────────────────────────────────
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _ClassIcon(cls: character.characterClass),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    character.name,
                                    style: GoogleFonts.cinzel(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${character.characterClass.displayName}  •  Level ${character.level}',
                                    style: GoogleFonts.cinzel(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Level badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withOpacity(0.15),
                                border: Border.all(
                                    color: AppTheme.accent.withOpacity(0.4)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'LV ${character.level}',
                                style: GoogleFonts.cinzel(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accent,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // HP bar
                        _StatBar(
                          label: 'HP',
                          current: character.stats.hp,
                          max: character.stats.maxHp,
                          color: AppTheme.hpRed,
                        ),
                        const SizedBox(height: 6),
                        // MP bar
                        _StatBar(
                          label: 'MP',
                          current: character.stats.mp,
                          max: character.stats.maxMp,
                          color: AppTheme.mpBlue,
                        ),
                        const SizedBox(height: 6),
                        // EXP bar
                        _StatBar(
                          label: 'XP',
                          current: character.experience,
                          max: character.experienceToNextLevel,
                          color: AppTheme.xpGreen,
                        ),

                        const SizedBox(height: 14),

                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatChip(
                                label: 'ATK', value: character.stats.attack),
                            _StatChip(
                                label: 'DEF', value: character.stats.defense),
                            _StatChip(
                                label: 'SPD', value: character.stats.speed),
                            _StatChip(
                              label: 'CRIT',
                              value: (character.stats.critChance * 100).round(),
                              suffix: '%',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Action buttons ────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _ActionButton(
                          icon: Icons.bolt,
                          label: 'DESCEND INTO DARKNESS',
                          subtitle: 'Enter floor ${dungeon.currentFloor}',
                          color: AppTheme.primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DungeonFloorScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeInUp(
                        delay: const Duration(milliseconds: 280),
                        child: _ActionButton(
                          icon: Icons.backpack,
                          label: 'INVENTORY',
                          subtitle:
                              '${gameState.inventory.items.length} / 30 items',
                          color: AppTheme.gold,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const InventoryScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeInUp(
                        delay: const Duration(milliseconds: 360),
                        child: _ActionButton(
                          icon: Icons.auto_awesome,
                          label: 'SKILL TREE',
                          subtitle:
                              '${character.skillPoints} skill point(s) available',
                          color: AppTheme.accent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SkillTreeScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeInUp(
                        delay: const Duration(milliseconds: 440),
                        child: _ActionButton(
                          icon: Icons.storefront,
                          label: 'DARK MERCHANT',
                          subtitle: 'Spend gold on gear & potions',
                          color: const Color(0xFF7C3AED),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ShopScreen()),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Level up notification
                      Consumer(
                        builder: (context, ref, _) {
                          final gs = ref.watch(gameStateProvider);
                          if (gs == null || gs.character.statPoints == 0)
                            return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LevelUpScreen(
                                      newLevel: gs.character.level),
                                ),
                              ),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.gold.withOpacity(0.1),
                                  border: Border.all(
                                      color: AppTheme.gold.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.star,
                                        color: AppTheme.gold, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${gs.character.statPoints} STAT POINTS AVAILABLE — TAP TO ALLOCATE',
                                      style: GoogleFonts.cinzel(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.gold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      FadeIn(
                        delay: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.sports_martial_arts,
                                  color: AppTheme.textMuted, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                '${dungeon.totalEnemiesDefeated} enemies slain  •  deepest: floor ${dungeon.deepestFloor}',
                                style: GoogleFonts.cinzel(
                                  fontSize: 10,
                                  color: AppTheme.textMuted,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────────────────────

class _ClassIcon extends StatelessWidget {
  final CharacterClass cls;
  const _ClassIcon({required this.cls});

  IconData get icon {
    switch (cls) {
      case CharacterClass.knight:
        return Icons.shield;
      case CharacterClass.necromancer:
        return Icons.auto_fix_high;
      case CharacterClass.rogue:
        return Icons.visibility_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Icon(icon, color: AppTheme.primary, size: 24),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;

  const _StatBar({
    required this.label,
    required this.current,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (current / max).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: GoogleFonts.cinzel(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$current / $max',
          style: GoogleFonts.cinzel(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;

  const _StatChip({
    required this.label,
    required this.value,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value$suffix',
          style: GoogleFonts.cinzel(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cinzel(
            fontSize: 9,
            color: AppTheme.textMuted,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cinzel(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }
}
