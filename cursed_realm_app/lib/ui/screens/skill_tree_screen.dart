import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/data/game_data.dart';
import '../../core/models/skill.dart';
import '../../core/services/game_state_provider.dart';
import '../../ui/theme/app_theme.dart';

class SkillTreeScreen extends ConsumerWidget {
  const SkillTreeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == null) return const SizedBox.shrink();

    final character = gameState.character;
    final classId = character.characterClass.name;

    // Get all skills for this class, grouped by branch
    final classSkills = GameData.skills.values
        .where((s) => s.characterClassId == classId)
        .toList();

    final branches = classSkills.map((s) => s.treeBranch).toSet().toList();

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
              // ── Header ───────────────────────────────────────────────────
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
                      'SKILL TREE',
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: 3,
                      ),
                    ),
                    const Spacer(),
                    // Skill points badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.15),
                        border:
                            Border.all(color: AppTheme.accent.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${character.skillPoints} SP',
                        style: GoogleFonts.cinzel(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Equipped skills row ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EQUIPPED SKILLS (MAX 4)',
                      style: GoogleFonts.cinzel(
                          fontSize: 10,
                          color: AppTheme.textMuted,
                          letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(4, (i) {
                        final skillId = i < character.equippedSkillIds.length
                            ? character.equippedSkillIds[i]
                            : null;
                        final skill =
                            skillId != null ? GameData.skills[skillId] : null;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                            child: _EquippedSlot(
                              skill: skill,
                              slotIndex: i,
                              onUnequip: skill != null
                                  ? () => _unequipSkill(ref, skillId!)
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Skill branches ───────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: branches.map((branch) {
                    final branchSkills = classSkills
                        .where((s) => s.treeBranch == branch)
                        .toList()
                      ..sort((a, b) => a.treeTier.compareTo(b.treeTier));

                    return FadeInUp(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Branch header
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppTheme.accent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                branch.toUpperCase(),
                                style: GoogleFonts.cinzel(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accent,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Skills in this branch
                          ...branchSkills.map((skill) => _SkillNode(
                                skill: skill,
                                character: character,
                                onUnlock: () =>
                                    _unlockSkill(context, ref, skill),
                                onEquip: () =>
                                    _equipSkill(context, ref, skill.id),
                              )),

                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _unlockSkill(BuildContext context, WidgetRef ref, Skill skill) {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;
    final character = gameState.character;

    if (character.skillPoints < skill.skillPointCost) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.surfaceVariant,
        content: Text('Not enough skill points!',
            style: GoogleFonts.cinzel(color: AppTheme.hpRed)),
      ));
      return;
    }

    // Check prerequisite
    if (skill.prerequisiteSkillId != null &&
        !character.unlockedSkillIds.contains(skill.prerequisiteSkillId)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.surfaceVariant,
        content: Text('Unlock the prerequisite skill first!',
            style: GoogleFonts.cinzel(color: AppTheme.hpRed)),
      ));
      return;
    }

    final updatedChar = character.copyWith(
      unlockedSkillIds: [...character.unlockedSkillIds, skill.id],
      skillPoints: character.skillPoints - skill.skillPointCost,
    );
    ref.read(gameStateProvider.notifier).updateCharacter(updatedChar);
    ref.read(gameStateProvider.notifier).saveGame();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppTheme.surfaceVariant,
      content: Text('${skill.name} unlocked!',
          style: GoogleFonts.cinzel(color: AppTheme.accent)),
    ));
  }

  void _equipSkill(BuildContext context, WidgetRef ref, String skillId) {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;
    final character = gameState.character;

    if (character.equippedSkillIds.contains(skillId)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.surfaceVariant,
        content: Text('Skill already equipped!',
            style: GoogleFonts.cinzel(color: AppTheme.textMuted)),
      ));
      return;
    }

    if (character.equippedSkillIds.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.surfaceVariant,
        content: Text('Unequip a skill first! (Max 4)',
            style: GoogleFonts.cinzel(color: AppTheme.hpRed)),
      ));
      return;
    }

    final updatedChar = character.copyWith(
      equippedSkillIds: [...character.equippedSkillIds, skillId],
    );
    ref.read(gameStateProvider.notifier).updateCharacter(updatedChar);
    ref.read(gameStateProvider.notifier).saveGame();
  }

  void _unequipSkill(WidgetRef ref, String skillId) {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;
    final character = gameState.character;

    final updatedChar = character.copyWith(
      equippedSkillIds:
          character.equippedSkillIds.where((id) => id != skillId).toList(),
    );
    ref.read(gameStateProvider.notifier).updateCharacter(updatedChar);
    ref.read(gameStateProvider.notifier).saveGame();
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _EquippedSlot extends StatelessWidget {
  final Skill? skill;
  final int slotIndex;
  final VoidCallback? onUnequip;

  const _EquippedSlot({
    required this.skill,
    required this.slotIndex,
    this.onUnequip,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = skill == null;
    return GestureDetector(
      onTap: onUnequip,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEmpty
              ? AppTheme.surfaceVariant
              : AppTheme.accent.withOpacity(0.1),
          border: Border.all(
            color: isEmpty ? AppTheme.border : AppTheme.accent.withOpacity(0.4),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Icon(
              isEmpty ? Icons.add : Icons.auto_awesome,
              color: isEmpty ? AppTheme.textMuted : AppTheme.accent,
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              isEmpty ? 'EMPTY' : skill!.name,
              style: GoogleFonts.cinzel(
                fontSize: 8,
                color: isEmpty ? AppTheme.textMuted : AppTheme.accent,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillNode extends StatelessWidget {
  final Skill skill;
  final character;
  final VoidCallback onUnlock;
  final VoidCallback onEquip;

  const _SkillNode({
    required this.skill,
    required this.character,
    required this.onUnlock,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = character.unlockedSkillIds.contains(skill.id);
    final isEquipped = character.equippedSkillIds.contains(skill.id);
    final hasPrereq = skill.prerequisiteSkillId == null ||
        character.unlockedSkillIds.contains(skill.prerequisiteSkillId);
    final canAfford = character.skillPoints >= skill.skillPointCost;

    Color nodeColor;
    if (isEquipped)
      nodeColor = AppTheme.accent;
    else if (isUnlocked)
      nodeColor = AppTheme.xpGreen;
    else if (!hasPrereq)
      nodeColor = AppTheme.textMuted;
    else
      nodeColor = AppTheme.gold;

    return Container(
      margin: EdgeInsets.only(
        bottom: 8,
        left: (skill.treeTier - 1) * 16.0,
      ),
      child: GestureDetector(
        onTap: isUnlocked ? onEquip : (hasPrereq ? onUnlock : null),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: nodeColor.withOpacity(0.07),
            border: Border.all(color: nodeColor.withOpacity(0.35)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              // Tier indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: nodeColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: nodeColor.withOpacity(0.4)),
                ),
                child: Center(
                  child: Text(
                    '${skill.treeTier}',
                    style: GoogleFonts.cinzel(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: nodeColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Skill info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          skill.name,
                          style: GoogleFonts.cinzel(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: nodeColor,
                          ),
                        ),
                        if (skill.type == SkillType.passive) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.textMuted.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text('PASSIVE',
                                style: GoogleFonts.cinzel(
                                    fontSize: 8, color: AppTheme.textMuted)),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      skill.description,
                      style: GoogleFonts.cinzel(
                          fontSize: 10, color: AppTheme.textSecondary),
                    ),
                    if (skill.isActive)
                      Text(
                        '${skill.mpCost} MP',
                        style: GoogleFonts.cinzel(
                            fontSize: 10, color: AppTheme.mpBlue),
                      ),
                  ],
                ),
              ),

              // Action button
              const SizedBox(width: 8),
              if (isEquipped)
                _TagBadge(label: 'EQUIPPED', color: AppTheme.accent)
              else if (isUnlocked)
                GestureDetector(
                  onTap: onEquip,
                  child: _TagBadge(label: 'EQUIP', color: AppTheme.xpGreen),
                )
              else if (!hasPrereq)
                _TagBadge(label: 'LOCKED', color: AppTheme.textMuted)
              else
                GestureDetector(
                  onTap: canAfford ? onUnlock : null,
                  child: _TagBadge(
                    label: '${skill.skillPointCost} SP',
                    color: canAfford ? AppTheme.gold : AppTheme.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TagBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.cinzel(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
