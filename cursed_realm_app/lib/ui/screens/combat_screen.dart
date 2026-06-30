import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/data/game_data.dart';
import '../../core/models/character.dart';
import '../../core/models/enemy.dart';
import '../../core/models/item.dart';
import '../../core/models/skill.dart';
import '../../core/services/game_state_provider.dart';
import '../../core/services/audio_service.dart';
import '../../ui/theme/app_theme.dart';
import '../../features/combat/combat_engine.dart';
import '../../features/combat/combat_provider.dart';
import 'game_over_screen.dart';
import 'level_up_screen.dart';

class CombatScreen extends ConsumerStatefulWidget {
  const CombatScreen({super.key});

  @override
  ConsumerState<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends ConsumerState<CombatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _showingRewards = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _shake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final combatState = ref.watch(combatStateProvider);
    final gameState = ref.watch(gameStateProvider);

    if (combatState == null || gameState == null) {
      return const Scaffold(backgroundColor: AppTheme.background);
    }

    // React to phase changes
    ref.listen(combatStateProvider, (prev, next) {
      if (next == null) return;
      if (prev?.phase != next.phase) {
        if (next.lastDamageToPlayer != null) _shake();
        if (next.phase == CombatPhase.victory && !_showingRewards) {
          setState(() => _showingRewards = true);
          Future.delayed(
            const Duration(milliseconds: 600),
            () => _showVictoryDialog(context, next),
          );
        }
        if (next.phase == CombatPhase.defeat) {
          Future.delayed(
            const Duration(milliseconds: 600),
            () => _showDefeatDialog(context),
          );
        }
        if (next.phase == CombatPhase.fled) {
          Future.delayed(
            const Duration(milliseconds: 400),
            () => _exitCombat(context),
          );
        }
      }
    });

    final enemy = combatState.enemy;
    final character = combatState.character;
    final isPlayerTurn = combatState.phase == CombatPhase.playerTurn;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050508), Color(0xFF0A0305), Color(0xFF080510)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Enemy section ────────────────────────────────────────────
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    // Enemy name & tier
                    FadeIn(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (enemy.tier == EnemyTier.boss)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.rarityLegendary.withOpacity(0.2),
                                border: Border.all(
                                    color: AppTheme.rarityLegendary
                                        .withOpacity(0.6)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'BOSS',
                                style: GoogleFonts.cinzel(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.rarityLegendary,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          Text(
                            enemy.name.toUpperCase(),
                            style: GoogleFonts.cinzel(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Enemy HP bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: _HpBar(
                        current: enemy.stats.hp,
                        max: enemy.stats.maxHp,
                        color: AppTheme.hpRed,
                        showNumbers: true,
                      ),
                    ),

                    // Status effects on enemy
                    if (enemy.statusEffects.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: enemy.statusEffects
                            .map((e) => _StatusBadge(effect: e.type))
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Enemy sprite placeholder (shake on damage)
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(
                            _shakeAnimation.value *
                                (combatState.lastDamageToPlayer != null
                                    ? 0
                                    : 1),
                            0),
                        child: child,
                      ),
                      child: FadeIn(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary.withOpacity(0.08),
                            border: Border.all(
                              color: AppTheme.primary
                                  .withOpacity(enemy.isAlive ? 0.3 : 0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            _enemyIcon(enemy.name),
                            size: 56,
                            color: AppTheme.primary
                                .withOpacity(enemy.isAlive ? 0.9 : 0.3),
                          ),
                        ),
                      ),
                    ),

                    // Damage number popup
                    if (combatState.lastDamageToEnemy != null)
                      FadeInUp(
                        key: ValueKey(combatState.turnNumber),
                        child: Text(
                          combatState.lastWasCrit
                              ? '💥 ${combatState.lastDamageToEnemy}'
                              : '-${combatState.lastDamageToEnemy}',
                          style: GoogleFonts.cinzel(
                            fontSize: combatState.lastWasCrit ? 22 : 18,
                            fontWeight: FontWeight.bold,
                            color: combatState.lastWasCrit
                                ? AppTheme.rarityLegendary
                                : AppTheme.hpRed,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Battle log ──────────────────────────────────────────────
              Container(
                height: 80,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.border),
                ),
                child: ListView.builder(
                  reverse: true,
                  itemCount: combatState.battleLog.length,
                  itemBuilder: (_, i) {
                    final idx = combatState.battleLog.length - 1 - i;
                    final msg = combatState.battleLog[idx];
                    return Text(
                      msg,
                      style: GoogleFonts.cinzel(
                        fontSize: 11,
                        color: i == 0
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ── Player section ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(top: BorderSide(color: AppTheme.border)),
                ),
                child: Column(
                  children: [
                    // Player HP/MP
                    Row(
                      children: [
                        _ClassIconSmall(cls: character.characterClass),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            children: [
                              _HpBar(
                                current: character.stats.hp,
                                max: character.stats.maxHp,
                                color: AppTheme.hpRed,
                                label: 'HP',
                              ),
                              const SizedBox(height: 4),
                              _HpBar(
                                current: character.stats.mp,
                                max: character.stats.maxMp,
                                color: AppTheme.mpBlue,
                                label: 'MP',
                              ),
                            ],
                          ),
                        ),
                        // Player damage received
                        if (combatState.lastDamageToPlayer != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FadeIn(
                              key: ValueKey('dmg_${combatState.turnNumber}'),
                              child: Text(
                                '-${combatState.lastDamageToPlayer}',
                                style: GoogleFonts.cinzel(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.hpRed,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Action buttons
                    if (isPlayerTurn) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _ActionBtn(
                              label: 'ATTACK',
                              icon: Icons.flash_on,
                              color: AppTheme.primary,
                              onTap: () => _doAction(
                                  const CombatAction(type: ActionType.attack)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ActionBtn(
                              label: 'SKILLS',
                              icon: Icons.auto_awesome,
                              color: AppTheme.accent,
                              onTap: () => _showSkillMenu(context, character),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ActionBtn(
                              label: 'ITEM',
                              icon: Icons.backpack,
                              color: AppTheme.gold,
                              onTap: () =>
                                  _showItemMenu(context, gameState.inventory),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ActionBtn(
                              label: 'FLEE',
                              icon: Icons.directions_run,
                              color: AppTheme.textMuted,
                              onTap: () => _doAction(
                                  const CombatAction(type: ActionType.flee)),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Center(
                        child: Text(
                          '${enemy.name.toUpperCase()} IS ATTACKING...',
                          style: GoogleFonts.cinzel(
                            fontSize: 12,
                            color: AppTheme.primary,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _doAction(CombatAction action) {
    ref.read(combatStateProvider.notifier).performAction(action);
  }

  void _showSkillMenu(BuildContext context, Character character) {
    final equippedSkills = character.equippedSkillIds
        .map((id) => GameData.skills[id])
        .whereType()
        .toList();

    if (equippedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.surfaceVariant,
          content: Text(
            'No skills equipped! Visit the skill tree.',
            style: GoogleFonts.cinzel(color: AppTheme.textPrimary),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => _SkillMenu(
        skills: equippedSkills,
        character: character,
        onSelect: (skillId) {
          Navigator.pop(context);
          _doAction(CombatAction(type: ActionType.skill, skillId: skillId));
        },
      ),
    );
  }

  void _showItemMenu(BuildContext context, inventory) {
    final consumables = inventory.items.where((i) => i.isConsumable).toList();

    if (consumables.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.surfaceVariant,
          content: Text(
            'No consumable items!',
            style: GoogleFonts.cinzel(color: AppTheme.textPrimary),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => _ItemMenu(
        items: consumables,
        onSelect: (itemId) {
          Navigator.pop(context);
          ref.read(gameStateProvider.notifier).removeItem(itemId);
          _doAction(CombatAction(type: ActionType.item, itemId: itemId));
        },
      ),
    );
  }

  void _showVictoryDialog(BuildContext context, CombatState combatState) {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;
    final floorLevel = gameState.dungeonProgress.currentFloor;
    final rewards = ref
        .read(combatEngineProvider)
        .calculateRewards(combatState.enemy, floorLevel);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        title: Text(
          'VICTORY!',
          style: GoogleFonts.cinzel(
            color: AppTheme.gold,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${combatState.enemy.name} has been defeated!',
              style: GoogleFonts.cinzel(
                  color: AppTheme.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _RewardRow(
                icon: Icons.star,
                label: 'EXP',
                value: '+${rewards.expGained}',
                color: AppTheme.xpGreen),
            _RewardRow(
                icon: Icons.monetization_on,
                label: 'Gold',
                value: '+${rewards.goldGained}',
                color: AppTheme.gold),
            if (rewards.itemsDropped.isNotEmpty)
              ...rewards.itemsDropped.map((item) => _RewardRow(
                    icon: Icons.inventory_2,
                    label: item.name,
                    value: '',
                    color: Color(item.rarity.colorValue),
                  )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exitCombat(context);
            },
            child: Text(
              'CONTINUE',
              style: GoogleFonts.cinzel(
                  color: AppTheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDefeatDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        title: Text(
          'DEFEATED',
          style: GoogleFonts.cinzel(
            color: AppTheme.hpRed,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'The darkness claims you...\nYour soul lingers in the cursed realm.',
          style:
              GoogleFonts.cinzel(color: AppTheme.textSecondary, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exitCombat(context);
            },
            child: Text(
              'RETURN',
              style: GoogleFonts.cinzel(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _exitCombat(BuildContext context) {
    final phase = ref.read(combatStateProvider)?.phase;
    ref.read(combatStateProvider.notifier).endCombat();
    setState(() => _showingRewards = false);
    if (!context.mounted) return;

    if (phase == CombatPhase.defeat) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const GameOverScreen()),
        (route) => false,
      );
      return;
    }

    // Check if player leveled up after victory
    final gameState = ref.read(gameStateProvider);
    if (gameState != null && gameState.character.statPoints > 0) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LevelUpScreen(newLevel: gameState.character.level),
        ),
      );
      return;
    }

    Navigator.pop(context);
  }

  IconData _enemyIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('ghost')) return Icons.cloud;
    if (n.contains('hound') || n.contains('wolf')) return Icons.pets;
    if (n.contains('golem')) return Icons.architecture;
    if (n.contains('lich') || n.contains('king')) return Icons.king_bed;
    return Icons.dangerous;
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _HpBar extends StatelessWidget {
  final int current;
  final int max;
  final Color color;
  final String? label;
  final bool showNumbers;

  const _HpBar({
    required this.current,
    required this.max,
    required this.color,
    this.label,
    this.showNumbers = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (current / max).clamp(0.0, 1.0);
    return Row(
      children: [
        if (label != null) ...[
          SizedBox(
            width: 24,
            child: Text(label!,
                style: GoogleFonts.cinzel(
                    fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        if (showNumbers) ...[
          const SizedBox(width: 8),
          Text(
            '$current/$max',
            style:
                GoogleFonts.cinzel(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final StatusEffectType effect;
  const _StatusBadge({required this.effect});

  Color get _color {
    if (!effect.isDebuff) return AppTheme.xpGreen;
    switch (effect) {
      case StatusEffectType.poison:
        return Colors.green;
      case StatusEffectType.bleed:
        return AppTheme.hpRed;
      case StatusEffectType.burn:
        return Colors.orange;
      case StatusEffectType.stun:
        return Colors.yellow;
      default:
        return AppTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        border: Border.all(color: _color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        effect.displayName.toUpperCase(),
        style: GoogleFonts.cinzel(fontSize: 9, color: _color, letterSpacing: 1),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.35)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.cinzel(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassIconSmall extends StatelessWidget {
  final CharacterClass cls;
  const _ClassIconSmall({required this.cls});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (cls) {
      case CharacterClass.knight:
        icon = Icons.shield;
        break;
      case CharacterClass.necromancer:
        icon = Icons.auto_fix_high;
        break;
      case CharacterClass.rogue:
        icon = Icons.visibility_off;
        break;
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.border),
      ),
      child: Icon(icon, color: AppTheme.primary, size: 18),
    );
  }
}

class _SkillMenu extends StatelessWidget {
  final List skills;
  final Character character;
  final Function(String) onSelect;

  const _SkillMenu({
    required this.skills,
    required this.character,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SKILLS',
              style: GoogleFonts.cinzel(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                  letterSpacing: 3)),
          const SizedBox(height: 12),
          ...skills.map((skill) => ListTile(
                onTap: () => onSelect(skill.id),
                leading: Icon(Icons.auto_awesome, color: AppTheme.accent),
                title: Text(skill.name,
                    style: GoogleFonts.cinzel(color: AppTheme.textPrimary)),
                subtitle: Text(skill.description,
                    style: GoogleFonts.cinzel(
                        fontSize: 10, color: AppTheme.textSecondary)),
                trailing: Text(
                  '${skill.mpCost} MP',
                  style: GoogleFonts.cinzel(
                      color: character.stats.mp >= skill.mpCost
                          ? AppTheme.mpBlue
                          : AppTheme.hpRed,
                      fontWeight: FontWeight.bold),
                ),
              )),
        ],
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final List<Item> items;
  final Function(String) onSelect;

  const _ItemMenu({required this.items, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ITEMS',
              style: GoogleFonts.cinzel(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gold,
                  letterSpacing: 3)),
          const SizedBox(height: 12),
          ...items.map((item) => ListTile(
                onTap: () => onSelect(item.id),
                leading: Icon(Icons.inventory_2, color: AppTheme.gold),
                title: Text(item.name,
                    style: GoogleFonts.cinzel(color: AppTheme.textPrimary)),
                subtitle: Text(item.description,
                    style: GoogleFonts.cinzel(
                        fontSize: 10, color: AppTheme.textSecondary)),
                trailing: Text('x${item.quantity}',
                    style: GoogleFonts.cinzel(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold)),
              )),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RewardRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.cinzel(
                  color: AppTheme.textPrimary, fontSize: 12)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.cinzel(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
