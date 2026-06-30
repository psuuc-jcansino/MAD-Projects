import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/models/character.dart';
import '../../core/services/game_state_provider.dart';
import '../../core/services/audio_service.dart';
import '../../ui/theme/app_theme.dart';

class LevelUpScreen extends ConsumerStatefulWidget {
  final int newLevel;
  const LevelUpScreen({super.key, required this.newLevel});

  @override
  ConsumerState<LevelUpScreen> createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends ConsumerState<LevelUpScreen> {
  int _hpPoints = 0;
  int _mpPoints = 0;
  int _atkPoints = 0;
  int _defPoints = 0;
  int _spdPoints = 0;

  int get _totalSpent =>
      _hpPoints + _mpPoints + _atkPoints + _defPoints + _spdPoints;

  @override
  void initState() {
    super.initState();
    AudioService.instance.playSfx(GameSfx.levelUp);
  }

  int get _availablePoints {
    final gs = ref.read(gameStateProvider);
    return (gs?.character.statPoints ?? 0) - _totalSpent;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == null) return const SizedBox.shrink();
    final character = gameState.character;
    final remaining = character.statPoints - _totalSpent;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050508), Color(0xFF0D0820), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────────
              const SizedBox(height: 24),
              FadeInDown(
                child: Column(
                  children: [
                    Text(
                      'LEVEL UP!',
                      style: GoogleFonts.cinzel(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gold,
                        letterSpacing: 6,
                        shadows: [
                          Shadow(
                              color: AppTheme.gold.withOpacity(0.5),
                              blurRadius: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${character.name} reached level ${widget.newLevel}',
                      style: GoogleFonts.cinzel(
                          fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Points remaining badge ────────────────────────────────────
              FadeIn(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$remaining stat point${remaining == 1 ? '' : 's'} remaining',
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Stat allocators ───────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _StatAllocator(
                        label: 'HP',
                        icon: Icons.favorite,
                        color: AppTheme.hpRed,
                        currentValue: character.stats.maxHp,
                        allocated: _hpPoints,
                        perPoint: 10,
                        canAdd: remaining > 0,
                        onAdd: () => setState(() => _hpPoints++),
                        onRemove: _hpPoints > 0
                            ? () => setState(() => _hpPoints--)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _StatAllocator(
                        label: 'MP',
                        icon: Icons.water_drop,
                        color: AppTheme.mpBlue,
                        currentValue: character.stats.maxMp,
                        allocated: _mpPoints,
                        perPoint: 8,
                        canAdd: remaining > 0,
                        onAdd: () => setState(() => _mpPoints++),
                        onRemove: _mpPoints > 0
                            ? () => setState(() => _mpPoints--)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _StatAllocator(
                        label: 'Attack',
                        icon: Icons.flash_on,
                        color: AppTheme.primary,
                        currentValue: character.stats.attack,
                        allocated: _atkPoints,
                        perPoint: 2,
                        canAdd: remaining > 0,
                        onAdd: () => setState(() => _atkPoints++),
                        onRemove: _atkPoints > 0
                            ? () => setState(() => _atkPoints--)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _StatAllocator(
                        label: 'Defense',
                        icon: Icons.shield,
                        color: AppTheme.textSecondary,
                        currentValue: character.stats.defense,
                        allocated: _defPoints,
                        perPoint: 2,
                        canAdd: remaining > 0,
                        onAdd: () => setState(() => _defPoints++),
                        onRemove: _defPoints > 0
                            ? () => setState(() => _defPoints--)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _StatAllocator(
                        label: 'Speed',
                        icon: Icons.speed,
                        color: AppTheme.xpGreen,
                        currentValue: character.stats.speed,
                        allocated: _spdPoints,
                        perPoint: 1,
                        canAdd: remaining > 0,
                        onAdd: () => setState(() => _spdPoints++),
                        onRemove: _spdPoints > 0
                            ? () => setState(() => _spdPoints--)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Confirm button ────────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _totalSpent > 0 || remaining == 0
                          ? _confirmAllocation
                          : null,
                      child: Text(
                        remaining > 0 ? 'CONFIRM ($remaining LEFT)' : 'CONFIRM',
                        style: GoogleFonts.cinzel(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmAllocation() {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;
    final character = gameState.character;

    final newStats = character.stats.copyWith(
      maxHp: character.stats.maxHp + (_hpPoints * 10),
      hp: character.stats.hp + (_hpPoints * 10),
      maxMp: character.stats.maxMp + (_mpPoints * 8),
      mp: character.stats.mp + (_mpPoints * 8),
      attack: character.stats.attack + (_atkPoints * 2),
      defense: character.stats.defense + (_defPoints * 2),
      speed: character.stats.speed + (_spdPoints * 1),
    );

    final updatedChar = character.copyWith(
      stats: newStats,
      statPoints: character.statPoints - _totalSpent,
    );

    ref.read(gameStateProvider.notifier).updateCharacter(updatedChar);
    ref.read(gameStateProvider.notifier).saveGame();

    AudioService.instance.playSfx(GameSfx.menuSelect);
    Navigator.pop(context);
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _StatAllocator extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int currentValue;
  final int allocated;
  final int perPoint;
  final bool canAdd;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;

  const _StatAllocator({
    required this.label,
    required this.icon,
    required this.color,
    required this.currentValue,
    required this.allocated,
    required this.perPoint,
    required this.canAdd,
    required this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final newValue = currentValue + (allocated * perPoint);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:
            allocated > 0 ? color.withOpacity(0.08) : AppTheme.surfaceVariant,
        border: Border.all(
          color: allocated > 0 ? color.withOpacity(0.4) : AppTheme.border,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
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
                  ),
                ),
                Text(
                  '+$perPoint per point',
                  style: GoogleFonts.cinzel(
                      fontSize: 10, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),

          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: onRemove != null
                    ? color.withOpacity(0.1)
                    : AppTheme.border.withOpacity(0.1),
                border: Border.all(
                  color: onRemove != null
                      ? color.withOpacity(0.4)
                      : AppTheme.border,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.remove,
                size: 16,
                color: onRemove != null ? color : AppTheme.textMuted,
              ),
            ),
          ),

          // Value display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$currentValue',
                    style: GoogleFonts.cinzel(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold),
                  ),
                  if (allocated > 0)
                    TextSpan(
                      text: ' → $newValue',
                      style: GoogleFonts.cinzel(
                          fontSize: 16,
                          color: color,
                          fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ),

          // Add button
          GestureDetector(
            onTap: canAdd ? onAdd : null,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: canAdd
                    ? color.withOpacity(0.1)
                    : AppTheme.border.withOpacity(0.1),
                border: Border.all(
                  color: canAdd ? color.withOpacity(0.4) : AppTheme.border,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.add,
                size: 16,
                color: canAdd ? color : AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
