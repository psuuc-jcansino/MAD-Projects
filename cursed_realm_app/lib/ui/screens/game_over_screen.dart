import 'package:cursed_realm/core/models/character.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/services/game_state_provider.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/save_service.dart';
import '../../ui/theme/app_theme.dart';
import 'main_menu_screen.dart';
import 'dungeon_hub_screen.dart';

// ─── Game Over Screen ─────────────────────────────────────────────────────────

class GameOverScreen extends ConsumerWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final character = gameState?.character;
    final dungeon = gameState?.dungeonProgress;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.playBgm(GameMusic.gameOver);
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0000), Color(0xFF050508), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── Title ─────────────────────────────────────────────────
              FadeInDown(
                child: Column(
                  children: [
                    Text(
                      'YOU DIED',
                      style: GoogleFonts.cinzel(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.hpRed,
                        letterSpacing: 8,
                        shadows: [
                          Shadow(
                              color: AppTheme.hpRed.withOpacity(0.6),
                              blurRadius: 30),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The darkness has claimed your soul.',
                      style: GoogleFonts.cinzel(
                          fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Stats ─────────────────────────────────────────────────
              if (character != null && dungeon != null)
                FadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        border:
                            Border.all(color: AppTheme.hpRed.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _StatRow(
                              label: 'Warrior',
                              value: character.name,
                              color: AppTheme.textPrimary),
                          _StatRow(
                              label: 'Level reached',
                              value: '${character.level}',
                              color: AppTheme.accent),
                          _StatRow(
                              label: 'Floor reached',
                              value: '${dungeon.deepestFloor}',
                              color: AppTheme.primary),
                          _StatRow(
                              label: 'Enemies slain',
                              value: '${dungeon.totalEnemiesDefeated}',
                              color: AppTheme.gold),
                          _StatRow(
                              label: 'Bosses defeated',
                              value: '${dungeon.totalBossesDefeated}',
                              color: AppTheme.rarityLegendary),
                        ],
                      ),
                    ),
                  ),
                ),

              const Spacer(flex: 2),

              // ── Buttons ───────────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _GameOverButton(
                        label: 'TRY AGAIN',
                        icon: Icons.replay,
                        color: AppTheme.primary,
                        onTap: () => _retryGame(context, ref),
                      ),
                      const SizedBox(height: 12),
                      _GameOverButton(
                        label: 'MAIN MENU',
                        icon: Icons.home,
                        color: AppTheme.textMuted,
                        onTap: () => _goToMainMenu(context, ref),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _retryGame(BuildContext context, WidgetRef ref) {
    // Keep same character, reset to floor 1 with full HP
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    final healed = gameState.character.copyWith(
      stats: gameState.character.characterClass.baseStats,
    );
    ref.read(gameStateProvider.notifier).updateCharacter(healed);
    ref.read(gameStateProvider.notifier).saveGame();

    AudioService.instance.playBgm(GameMusic.dungeon);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DungeonHubScreen()),
      (route) => false,
    );
  }

  void _goToMainMenu(BuildContext context, WidgetRef ref) async {
    await SaveService.deleteSave();
    AudioService.instance.playBgm(GameMusic.mainMenu);
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        (route) => false,
      );
    }
  }
}

// ─── Victory Screen ───────────────────────────────────────────────────────────

class VictoryScreen extends ConsumerWidget {
  const VictoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final character = gameState?.character;
    final dungeon = gameState?.dungeonProgress;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.playBgm(GameMusic.victory);
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0800), Color(0xFF050508), Color(0xFF08050D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── Title ─────────────────────────────────────────────────
              FadeInDown(
                child: Column(
                  children: [
                    Text(
                      'VICTORY',
                      style: GoogleFonts.cinzel(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.gold,
                        letterSpacing: 8,
                        shadows: [
                          Shadow(
                              color: AppTheme.gold.withOpacity(0.6),
                              blurRadius: 30),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The Lich King has fallen. The curse is broken.',
                      style: GoogleFonts.cinzel(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Stars decoration ──────────────────────────────────────
              FadeIn(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.star,
                        color: AppTheme.gold.withOpacity(0.3 + i * 0.15),
                        size: 24 + i * 4.0,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Final stats ───────────────────────────────────────────
              if (character != null && dungeon != null)
                FadeIn(
                  delay: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        border:
                            Border.all(color: AppTheme.gold.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'HERO OF THE REALM',
                            style: GoogleFonts.cinzel(
                              fontSize: 11,
                              color: AppTheme.gold,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _StatRow(
                              label: 'Champion',
                              value: character.name,
                              color: AppTheme.textPrimary),
                          _StatRow(
                              label: 'Final level',
                              value: '${character.level}',
                              color: AppTheme.accent),
                          _StatRow(
                              label: 'Floors cleared',
                              value: '${dungeon.deepestFloor}',
                              color: AppTheme.primary),
                          _StatRow(
                              label: 'Enemies slain',
                              value: '${dungeon.totalEnemiesDefeated}',
                              color: AppTheme.gold),
                          _StatRow(
                              label: 'Bosses defeated',
                              value: '${dungeon.totalBossesDefeated}',
                              color: AppTheme.rarityLegendary),
                        ],
                      ),
                    ),
                  ),
                ),

              const Spacer(flex: 2),

              // ── Buttons ───────────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _GameOverButton(
                        label: 'CONTINUE EXPLORING',
                        icon: Icons.explore,
                        color: AppTheme.primary,
                        onTap: () {
                          AudioService.instance.playBgm(GameMusic.dungeon);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DungeonHubScreen()),
                            (route) => false,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _GameOverButton(
                        label: 'MAIN MENU',
                        icon: Icons.home,
                        color: AppTheme.textMuted,
                        onTap: () async {
                          await SaveService.deleteSave();
                          AudioService.instance.playBgm(GameMusic.mainMenu);
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MainMenuScreen()),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.cinzel(
                  fontSize: 12, color: AppTheme.textSecondary)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.cinzel(
                  fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _GameOverButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameOverButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.cinzel(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
