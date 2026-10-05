import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../game/dungeon_game.dart';
import '../../hub/common/hub_icon_button.dart';
import '../../hub/hub_style.dart';
import '../common/game_overlay_frame.dart';
import '../hud/coins_pill.dart';
import 'consumables_tab.dart';
import 'equipment_tab.dart';

class BagOverlay extends StatelessWidget {
  const BagOverlay({required this.game, required this.onClosed, super.key});

  static const _maxWidth = 640.0;
  static const _maxHeight = 820.0;
  static const _radius = 24.0;
  static const _tabCount = 2;

  final DungeonGame game;
  final VoidCallback onClosed;

  void _close() {
    game.closeInventory();
    onClosed();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _close,
        const SingleActivator(LogicalKeyboardKey.keyI): _close,
      },
      child: Focus(
        autofocus: true,
        child: ColoredBox(
          color: GameOverlayFrame.scrimColor,
          child: SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: _maxWidth,
                  maxHeight: _maxHeight,
                ),
                margin: const EdgeInsets.all(12),
                decoration: HubStyle.panelDecoration(radius: _radius),
                child: DefaultTabController(
                  length: _tabCount,
                  child: Column(
                    children: [
                      _BagHeader(game: game, onClose: _close),
                      const _BagTabBar(),
                      Expanded(
                        child: ListenableBuilder(
                          listenable: Listenable.merge([
                            game.inventory,
                            game.activeBoosts,
                            game.playerHp,
                          ]),
                          builder: (context, _) => TabBarView(
                            children: [
                              EquipmentTab(game: game),
                              ConsumablesTab(game: game),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BagHeader extends StatelessWidget {
  const _BagHeader({required this.game, required this.onClose});

  final DungeonGame game;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 6),
      child: Row(
        children: [
          const Icon(Icons.backpack_rounded, color: HubStyle.accent, size: 28),
          const SizedBox(width: 8),
          Text('Sac', style: HubStyle.title(fontSize: 26)),
          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([game.playerHp, game.playerMaxHp]),
              builder: (context, _) => Text(
                'PV ${game.playerHp.value}/${game.playerMaxHp.value}',
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HubStyle.body(color: HubStyle.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CoinsPill(coins: game.coins),
          const SizedBox(width: 8),
          HubIconButton(
            icon: Icons.close_rounded,
            semanticLabel: 'Fermer le sac',
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _BagTabBar extends StatelessWidget {
  const _BagTabBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: HubStyle.navigationBar,
          borderRadius: BorderRadius.circular(18),
        ),
        child: TabBar(
          labelStyle: HubStyle.title(fontSize: 16),
          unselectedLabelStyle: HubStyle.plainTitle(
            fontSize: 16,
            color: HubStyle.mutedText,
          ),
          labelColor: HubStyle.white,
          unselectedLabelColor: HubStyle.mutedText,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            gradient: HubStyle.activeTabGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: HubStyle.panelBorder, width: 1.5),
          ),
          tabs: const [
            Tab(text: 'Équipement'),
            Tab(text: 'Objets'),
          ],
        ),
      ),
    );
  }
}
