import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/models/character.dart';
import '../../core/models/item.dart';
import '../../core/services/game_state_provider.dart';
import '../../ui/theme/app_theme.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  ItemType? _filter;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == null) return const SizedBox.shrink();

    final character = gameState.character;
    final inventory = gameState.inventory;
    final equipment = character.equipment;

    final filteredItems = _filter == null
        ? inventory.items
        : inventory.items.where((i) => i.type == _filter).toList();

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
                      'INVENTORY',
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: 3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${inventory.items.length}/30',
                      style: GoogleFonts.cinzel(
                          fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Equipment slots ──────────────────────────────────────────
              FadeInDown(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EQUIPPED',
                        style: GoogleFonts.cinzel(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                            letterSpacing: 3),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _EquipSlot(
                            label: 'WEAPON',
                            icon: Icons.flash_on,
                            itemId: equipment.weaponId,
                            inventory: inventory,
                            onTap: () => _showEquipMenu(
                                context, character, ItemType.weapon),
                          ),
                          const SizedBox(width: 8),
                          _EquipSlot(
                            label: 'ARMOR',
                            icon: Icons.shield,
                            itemId: equipment.armorId,
                            inventory: inventory,
                            onTap: () => _showEquipMenu(
                                context, character, ItemType.armor),
                          ),
                          const SizedBox(width: 8),
                          _EquipSlot(
                            label: 'ACCESS',
                            icon: Icons.circle,
                            itemId: equipment.accessoryId,
                            inventory: inventory,
                            onTap: () => _showEquipMenu(
                                context, character, ItemType.accessory),
                          ),
                          const SizedBox(width: 8),
                          _EquipSlot(
                            label: 'RELIC',
                            icon: Icons.auto_fix_high,
                            itemId: equipment.relicId,
                            inventory: inventory,
                            onTap: () => _showEquipMenu(
                                context, character, ItemType.relic),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Filter tabs ──────────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'ALL',
                      selected: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    const SizedBox(width: 8),
                    ...ItemType.values.map((t) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: t.displayName.toUpperCase(),
                            selected: _filter == t,
                            onTap: () => setState(() => _filter = t),
                          ),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Item list ────────────────────────────────────────────────
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          'No items found.',
                          style: GoogleFonts.cinzel(
                              color: AppTheme.textMuted, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredItems.length,
                        itemBuilder: (_, i) => FadeInUp(
                          delay: Duration(milliseconds: i * 40),
                          child: _ItemTile(
                            item: filteredItems[i],
                            character: character,
                            onTap: () => _showItemDetail(
                                context, filteredItems[i], character),
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

  void _showEquipMenu(
      BuildContext context, Character character, ItemType type) {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    // Check if something is already equipped in this slot
    final equippedId = _getEquippedId(character.equipment, type);
    final availableItems =
        gameState.inventory.items.where((i) => i.type == type).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EQUIP ${type.displayName.toUpperCase()}',
              style: GoogleFonts.cinzel(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.gold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            if (equippedId != null)
              ListTile(
                leading: const Icon(Icons.remove_circle, color: AppTheme.hpRed),
                title: Text('Unequip',
                    style: GoogleFonts.cinzel(color: AppTheme.hpRed)),
                onTap: () {
                  Navigator.pop(context);
                  _unequip(type);
                },
              ),
            if (availableItems.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('No ${type.displayName} in inventory.',
                    style: GoogleFonts.cinzel(color: AppTheme.textMuted)),
              ),
            ...availableItems.map((item) => ListTile(
                  leading: Icon(Icons.inventory_2,
                      color: Color(item.rarity.colorValue)),
                  title: Text(item.name,
                      style: GoogleFonts.cinzel(color: AppTheme.textPrimary)),
                  subtitle: _StatBonusText(bonus: item.statBonus),
                  onTap: () {
                    Navigator.pop(context);
                    _equip(item, type);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showItemDetail(BuildContext context, Item item, Character character) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2,
                    color: Color(item.rarity.colorValue), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: GoogleFonts.cinzel(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text(
                        '${item.rarity.displayName} ${item.type.displayName}',
                        style: GoogleFonts.cinzel(
                            color: Color(item.rarity.colorValue), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (item.quantity > 1)
                  Text('x${item.quantity}',
                      style: GoogleFonts.cinzel(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.description,
                style: GoogleFonts.cinzel(
                    color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 12),
            if (!item.isConsumable) _StatBonusText(bonus: item.statBonus),
            if (item.healAmount != null)
              Text('Restores ${item.healAmount} HP',
                  style:
                      GoogleFonts.cinzel(color: AppTheme.hpRed, fontSize: 12)),
            if (item.mpRestoreAmount != null)
              Text('Restores ${item.mpRestoreAmount} MP',
                  style:
                      GoogleFonts.cinzel(color: AppTheme.mpBlue, fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Value: ${item.goldValue}g',
                    style:
                        GoogleFonts.cinzel(color: AppTheme.gold, fontSize: 12)),
                const Spacer(),
                if (item.isConsumable)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _useItem(item);
                    },
                    child: const Text('USE'),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _equip(item, item.type);
                    },
                    child: const Text('EQUIP'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _equip(Item item, ItemType type) {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;
    final character = gameState.character;

    // Unequip old item first if any
    final oldId = _getEquippedId(character.equipment, type);
    // No need to add back to inventory since we track by ID

    final newEquipment = _setEquippedId(character.equipment, type, item.id);
    final updatedChar = character.copyWith(
      equipment: newEquipment,
      stats: _applyEquipmentStats(character),
    );
    ref.read(gameStateProvider.notifier).updateCharacter(updatedChar);
    ref.read(gameStateProvider.notifier).saveGame();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppTheme.surfaceVariant,
      content: Text('${item.name} equipped!',
          style: GoogleFonts.cinzel(color: AppTheme.textPrimary)),
    ));
  }

  void _unequip(ItemType type) {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;
    final character = gameState.character;
    final newEquipment = _setEquippedId(character.equipment, type, null);
    final updatedChar = character.copyWith(
      equipment: newEquipment,
      stats: _applyEquipmentStats(character),
    );
    ref.read(gameStateProvider.notifier).updateCharacter(updatedChar);
    ref.read(gameStateProvider.notifier).saveGame();
  }

  void _useItem(Item item) {
    final notifier = ref.read(gameStateProvider.notifier);
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    var character = gameState.character;
    if (item.healAmount != null) {
      character = character.heal(item.healAmount!);
    }
    if (item.mpRestoreAmount != null) {
      character = character.restoreMp(item.mpRestoreAmount!);
    }
    notifier.updateCharacter(character);
    notifier.removeItem(item.id);
    notifier.saveGame();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppTheme.surfaceVariant,
      content: Text('Used ${item.name}!',
          style: GoogleFonts.cinzel(color: AppTheme.textPrimary)),
    ));
  }

  String? _getEquippedId(EquipmentSlots slots, ItemType type) {
    switch (type) {
      case ItemType.weapon:
        return slots.weaponId;
      case ItemType.armor:
        return slots.armorId;
      case ItemType.accessory:
        return slots.accessoryId;
      case ItemType.relic:
        return slots.relicId;
      default:
        return null;
    }
  }

  EquipmentSlots _setEquippedId(
      EquipmentSlots slots, ItemType type, String? id) {
    switch (type) {
      case ItemType.weapon:
        return slots.copyWith(weaponId: id);
      case ItemType.armor:
        return slots.copyWith(armorId: id);
      case ItemType.accessory:
        return slots.copyWith(accessoryId: id);
      case ItemType.relic:
        return slots.copyWith(relicId: id);
      default:
        return slots;
    }
  }

  CharacterStats _applyEquipmentStats(Character character) {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return character.stats;

    final inventory = gameState.inventory;
    final equipment = character.equipment;
    final base = character.characterClass.baseStats.copyWith(
      hp: character.stats.hp,
      mp: character.stats.mp,
    );

    int atkBonus = 0, defBonus = 0, spdBonus = 0, hpBonus = 0, mpBonus = 0;
    double critBonus = 0;

    for (final id in [
      equipment.weaponId,
      equipment.armorId,
      equipment.accessoryId,
      equipment.relicId,
    ]) {
      if (id == null) continue;
      final item = inventory.getItem(id);
      if (item == null) continue;
      atkBonus += item.statBonus.attack;
      defBonus += item.statBonus.defense;
      spdBonus += item.statBonus.speed;
      hpBonus += item.statBonus.hp;
      mpBonus += item.statBonus.mp;
      critBonus += item.statBonus.critChance;
    }

    return base.copyWith(
      attack: base.attack + atkBonus,
      defense: base.defense + defBonus,
      speed: base.speed + spdBonus,
      maxHp: base.maxHp + hpBonus,
      maxMp: base.maxMp + mpBonus,
      critChance: base.critChance + critBonus,
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _EquipSlot extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? itemId;
  final Inventory inventory;
  final VoidCallback onTap;

  const _EquipSlot({
    required this.label,
    required this.icon,
    required this.itemId,
    required this.inventory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final item = itemId != null ? inventory.getItem(itemId!) : null;
    final isEquipped = item != null;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isEquipped
                ? AppTheme.gold.withOpacity(0.08)
                : AppTheme.surfaceVariant,
            border: Border.all(
              color:
                  isEquipped ? AppTheme.gold.withOpacity(0.4) : AppTheme.border,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isEquipped ? AppTheme.gold : AppTheme.textMuted,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                isEquipped ? item.name : label,
                style: GoogleFonts.cinzel(
                  fontSize: 8,
                  color: isEquipped ? AppTheme.gold : AppTheme.textMuted,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withOpacity(0.2)
              : AppTheme.surfaceVariant,
          border: Border.all(
            color:
                selected ? AppTheme.primary.withOpacity(0.6) : AppTheme.border,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.cinzel(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: selected ? AppTheme.primary : AppTheme.textMuted,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final Item item;
  final Character character;
  final VoidCallback onTap;

  const _ItemTile({
    required this.item,
    required this.character,
    required this.onTap,
  });

  bool get _isEquipped {
    final eq = character.equipment;
    return eq.weaponId == item.id ||
        eq.armorId == item.id ||
        eq.accessoryId == item.id ||
        eq.relicId == item.id;
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(item.rarity.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _isEquipped
                ? AppTheme.gold.withOpacity(0.5)
                : rarityColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: rarityColor.withOpacity(0.3)),
              ),
              child: Icon(Icons.inventory_2, color: rarityColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.cinzel(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (_isEquipped) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                                color: AppTheme.gold.withOpacity(0.4)),
                          ),
                          child: Text(
                            'EQ',
                            style: GoogleFonts.cinzel(
                                fontSize: 8,
                                color: AppTheme.gold,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    item.rarity.displayName,
                    style: GoogleFonts.cinzel(fontSize: 10, color: rarityColor),
                  ),
                ],
              ),
            ),
            if (item.quantity > 1)
              Text(
                'x${item.quantity}',
                style: GoogleFonts.cinzel(
                    color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
              )
            else
              const Icon(Icons.chevron_right,
                  color: AppTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _StatBonusText extends StatelessWidget {
  final StatBonus bonus;
  const _StatBonusText({required this.bonus});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (bonus.attack > 0) parts.add('+${bonus.attack} ATK');
    if (bonus.defense > 0) parts.add('+${bonus.defense} DEF');
    if (bonus.speed > 0) parts.add('+${bonus.speed} SPD');
    if (bonus.hp > 0) parts.add('+${bonus.hp} HP');
    if (bonus.mp > 0) parts.add('+${bonus.mp} MP');
    if (bonus.critChance > 0)
      parts.add('+${(bonus.critChance * 100).round()}% CRIT');

    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join('  '),
      style: GoogleFonts.cinzel(fontSize: 11, color: AppTheme.xpGreen),
    );
  }
}
