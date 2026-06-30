import 'package:cursed_realm/ui/screens/char_select_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/save_service.dart';
import '../../core/services/game_state_provider.dart';
import '../../ui/theme/app_theme.dart';
// import 'character_select_screen.dart';
import 'dungeon_hub_screen.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSave = SaveService.hasSave();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050508), Color(0xFF0A0A0F), Color(0xFF0D0510)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Title
                FadeInDown(
                  duration: const Duration(milliseconds: 1200),
                  child: Column(
                    children: [
                      Text(
                        'CURSED',
                        style: GoogleFonts.cinzel(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                          letterSpacing: 12,
                          shadows: [
                            const Shadow(
                                color: AppTheme.primary, blurRadius: 20),
                            const Shadow(
                                color: AppTheme.primary, blurRadius: 40),
                          ],
                        ),
                      ),
                      Text(
                        'REALM',
                        style: GoogleFonts.cinzel(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                          letterSpacing: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                FadeIn(
                  delay: const Duration(milliseconds: 800),
                  child: Text(
                    '— A Dark Gothic RPG —',
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                      letterSpacing: 3,
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Buttons
                FadeInUp(
                  delay: const Duration(milliseconds: 1000),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (hasSave) ...[
                          _MenuButton(
                            label: 'CONTINUE',
                            icon: Icons.play_arrow,
                            onTap: () {
                              ref.read(gameStateProvider.notifier).loadGame();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DungeonHubScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        _MenuButton(
                          label: 'NEW GAME',
                          icon: Icons.add,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CharacterSelectScreen(),
                            ),
                          ),
                        ),
                        if (hasSave) ...[
                          const SizedBox(height: 16),
                          _MenuButton(
                            label: 'DELETE SAVE',
                            icon: Icons.delete_forever,
                            isDestructive: true,
                            onTap: () => _confirmDeleteSave(context),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                FadeIn(
                  delay: const Duration(milliseconds: 1400),
                  child: Text(
                    'v1.0.0',
                    style: GoogleFonts.cinzel(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteSave(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        title: Text(
          'Delete Save?',
          style: GoogleFonts.cinzel(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Your progress will be lost forever.',
          style:
              GoogleFonts.cinzel(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: GoogleFonts.cinzel(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await SaveService.deleteSave();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('DELETE',
                style: GoogleFonts.cinzel(color: AppTheme.hpRed)),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppTheme.textMuted : AppTheme.primary;
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
