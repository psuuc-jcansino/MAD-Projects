import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/models/character.dart';
import '../../core/services/game_state_provider.dart';
import '../../ui/theme/app_theme.dart';
import 'dungeon_hub_screen.dart';

class CharacterSelectScreen extends ConsumerStatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  ConsumerState<CharacterSelectScreen> createState() =>
      _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends ConsumerState<CharacterSelectScreen> {
  CharacterClass _selected = CharacterClass.knight;
  final _nameController = TextEditingController(text: 'Cursed One');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050508), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios,
                          color: AppTheme.textSecondary),
                    ),
                    const Spacer(),
                    Text(
                      'CHOOSE YOUR FATE',
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: 3,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 24),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Class cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ...CharacterClass.values.map((cls) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FadeInLeft(
                            delay: Duration(
                                milliseconds:
                                    100 * CharacterClass.values.indexOf(cls)),
                            child: _ClassCard(
                              cls: cls,
                              isSelected: _selected == cls,
                              onTap: () => setState(() => _selected = cls),
                            ),
                          ),
                        )),

                    const SizedBox(height: 24),

                    // Name field
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NAME YOUR WARRIOR',
                            style: GoogleFonts.cinzel(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            style: GoogleFonts.cinzel(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                            ),
                            maxLength: 20,
                            decoration: InputDecoration(
                              counterStyle: GoogleFonts.cinzel(
                                  color: AppTheme.textMuted, fontSize: 10),
                              filled: true,
                              fillColor: AppTheme.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    const BorderSide(color: AppTheme.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    const BorderSide(color: AppTheme.primary),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    const BorderSide(color: AppTheme.border),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Begin button
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: ElevatedButton(
                        onPressed: _startGame,
                        child: Text(
                          'BEGIN YOUR DESCENT',
                          style: GoogleFonts.cinzel(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    ref.read(gameStateProvider.notifier).startNewGame(
          characterName: name,
          characterClass: _selected,
        );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DungeonHubScreen()),
      (route) => false,
    );
  }
}

class _ClassCard extends StatelessWidget {
  final CharacterClass cls;
  final bool isSelected;
  final VoidCallback onTap;

  const _ClassCard({
    required this.cls,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _classIcon {
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
    final borderColor = isSelected ? AppTheme.primary : AppTheme.border;
    final bgColor = isSelected
        ? AppTheme.primary.withOpacity(0.12)
        : AppTheme.surfaceVariant;
    final stats = cls.baseStats;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: (isSelected ? AppTheme.primary : AppTheme.textMuted)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _classIcon,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cls.displayName.toUpperCase(),
                    style: GoogleFonts.cinzel(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? AppTheme.primary : AppTheme.textPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cls.description,
                    style: GoogleFonts.cinzel(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatBadge('HP', stats.maxHp, AppTheme.hpRed),
                      const SizedBox(width: 8),
                      _StatBadge('MP', stats.maxMp, AppTheme.mpBlue),
                      const SizedBox(width: 8),
                      _StatBadge('ATK', stats.attack, AppTheme.gold),
                    ],
                  ),
                ],
              ),
            ),

            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child:
                    Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatBadge(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label $value',
        style: GoogleFonts.cinzel(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
