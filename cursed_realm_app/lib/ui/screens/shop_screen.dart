import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/data/game_data.dart';
import '../../core/models/item.dart';
import '../../core/services/game_state_provider.dart';
import '../../core/services/audio_service.dart';
import '../../ui/theme/app_theme.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  late List<Item> _shopItems;

  @override
  void initState() {
    super.initState();
    _shopItems = _generateShopInventory();
    AudioService.instance.playBgm(GameMusic.dungeon);
  }

  List<Item> _generateShopInventory() {
    final gameState = ref.read(gameStateProvider);
    final floor = gameState?.dungeonProgress.currentFloor ?? 1;

    // Scale shop inventory with floor level
    final all = GameData.items.values.toList()..shuffle();
    final consumables = all.where((i) => i.isConsumable).take(3).toList();
    final equipment = all
        .where((i) => !i.isConsumable)
        .where((i) {
          if (floor < 3)
            return i.rarity == ItemRarity.common ||
                i.rarity == ItemRarity.uncommon;
          if (floor < 6) return i.rarity != ItemRarity.legendary;
          return true;
        })
        .take(4)
        .toList();

    return [...consumables, ...equipment];
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    if (gameState == null) return const SizedBox.shrink();

    final gold = gameState.character.gold;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050508), Color(0xFF0A0805), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ───────────────────────────────────────────────────
              FadeInDown(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          AudioService.instance.playSfx(GameSfx.menuBack);
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back_ios,
                            color: AppTheme.textSecondary),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Text(
                            'THE DARK MERCHANT',
                            style: GoogleFonts.cinzel(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gold,
                              letterSpacing: 3,
                            ),
                          ),
                          Text(
                            '"Trade your gold for power..."',
                            style: GoogleFonts.cinzel(
                                fontSize: 10,
                                color: AppTheme.textMuted,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Gold display
                      Row(
                        children: [
                          const Icon(Icons.monetization_on,
                              color: AppTheme.gold, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$gold',
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

              const SizedBox(height: 16),

              // ── Shop items ───────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _shopItems.length,
                  itemBuilder: (_, i) {
                    final item = _shopItems[i];
                    final canAfford = gold >= item.goldValue;

                    return FadeInUp(
                      delay: Duration(milliseconds: i * 60),
                      child: _ShopItemTile(
                        item: item,
                        canAfford: canAfford,
                        onBuy: () => _buyItem(item),
                      ),
                    );
                  },
                ),
              ),

              // ── Reroll button ─────────────────────────────────────────────
              FadeInUp(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () {
                      if (gold < 30) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: AppTheme.surfaceVariant,
                          content: Text('Need 30 gold to reroll the shop!',
                              style: GoogleFonts.cinzel(color: AppTheme.hpRed)),
                        ));
                        return;
                      }
                      ref.read(gameStateProvider.notifier).gainGold(-30);
                      setState(() => _shopItems = _generateShopInventory());
                      AudioService.instance.playSfx(GameSfx.menuSelect);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh,
                              color: AppTheme.textSecondary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'REROLL SHOP  •  30g',
                            style: GoogleFonts.cinzel(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
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

  void _buyItem(Item item) {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return;

    if (gameState.character.gold < item.goldValue) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.surfaceVariant,
        content: Text('Not enough gold!',
            style: GoogleFonts.cinzel(color: AppTheme.hpRed)),
      ));
      return;
    }

    if (gameState.inventory.isFull && !item.isConsumable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.surfaceVariant,
        content: Text('Inventory is full!',
            style: GoogleFonts.cinzel(color: AppTheme.hpRed)),
      ));
      return;
    }

    ref.read(gameStateProvider.notifier).gainGold(-item.goldValue);
    ref.read(gameStateProvider.notifier).addItem(item);
    ref.read(gameStateProvider.notifier).saveGame();

    AudioService.instance.playSfx(GameSfx.shopBuy);

    setState(() => _shopItems.remove(item));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppTheme.surfaceVariant,
      content: Text('Purchased ${item.name}!',
          style: GoogleFonts.cinzel(color: AppTheme.gold)),
    ));
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _ShopItemTile extends StatelessWidget {
  final Item item;
  final bool canAfford;
  final VoidCallback onBuy;

  const _ShopItemTile({
    required this.item,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(item.rarity.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canAfford ? rarityColor.withOpacity(0.3) : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: rarityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: rarityColor.withOpacity(0.3)),
            ),
            child: Icon(Icons.inventory_2, color: rarityColor, size: 22),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.cinzel(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color:
                        canAfford ? AppTheme.textPrimary : AppTheme.textMuted,
                  ),
                ),
                Text(
                  '${item.rarity.displayName} ${item.type.displayName}',
                  style: GoogleFonts.cinzel(fontSize: 10, color: rarityColor),
                ),
                if (!item.isConsumable) ...[
                  const SizedBox(height: 2),
                  _StatBonusMini(bonus: item.statBonus),
                ],
                if (item.healAmount != null)
                  Text('+${item.healAmount} HP',
                      style: GoogleFonts.cinzel(
                          fontSize: 10, color: AppTheme.hpRed)),
                if (item.mpRestoreAmount != null)
                  Text('+${item.mpRestoreAmount} MP',
                      style: GoogleFonts.cinzel(
                          fontSize: 10, color: AppTheme.mpBlue)),
              ],
            ),
          ),

          // Buy button
          GestureDetector(
            onTap: canAfford ? onBuy : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: canAfford
                    ? AppTheme.gold.withOpacity(0.15)
                    : AppTheme.border.withOpacity(0.1),
                border: Border.all(
                  color: canAfford
                      ? AppTheme.gold.withOpacity(0.5)
                      : AppTheme.border,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.monetization_on,
                      color: canAfford ? AppTheme.gold : AppTheme.textMuted,
                      size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${item.goldValue}',
                    style: GoogleFonts.cinzel(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: canAfford ? AppTheme.gold : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBonusMini extends StatelessWidget {
  final StatBonus bonus;
  const _StatBonusMini({required this.bonus});

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
      style: GoogleFonts.cinzel(fontSize: 10, color: AppTheme.xpGreen),
    );
  }
}
