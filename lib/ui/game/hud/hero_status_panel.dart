import 'package:flutter/material.dart';

import '../../../game/dungeon_game.dart';
import '../../hub/common/hub_progress_bar.dart';
import '../../hub/hub_style.dart';
import '../common/hero_ability_icons.dart';
import '../common/hero_avatar.dart';
import '../common/type_badge.dart';

class HeroStatusPanel extends StatelessWidget {
  const HeroStatusPanel({required this.game, super.key});

  static const _maxWidth = 210.0;
  static const _hpGradient = HubStyle.successGradient;

  final DungeonGame game;

  @override
  Widget build(BuildContext context) {
    final hero = game.hero;
    return Container(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      decoration: HubStyle.panelDecoration(radius: 18),
      child: Row(
        children: [
          HeroAvatar(hero: hero, side: 42),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        hero.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: HubStyle.title(fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TypeBadge(type: hero.type, fontSize: 9),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      HeroAbilityIcons.of(hero.ability),
                      size: 12,
                      color: hero.accentColor,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        hero.ability.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: HubStyle.body(
                          fontSize: 10,
                          color: HubStyle.mutedText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ListenableBuilder(
                  listenable: Listenable.merge([
                    game.playerHp,
                    game.playerMaxHp,
                  ]),
                  builder: (context, _) => _HitPoints(
                    hp: game.playerHp.value,
                    maxHp: game.playerMaxHp.value,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HitPoints extends StatelessWidget {
  const _HitPoints({required this.hp, required this.maxHp});

  final int hp;
  final int maxHp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HubProgressBar(
          ratio: maxHp <= 0 ? 0 : hp / maxHp,
          gradient: HeroStatusPanel._hpGradient,
          height: 10,
        ),
        const SizedBox(height: 2),
        Text(
          'PV $hp/$maxHp',
          style: HubStyle.body(fontSize: 10, color: HubStyle.white),
        ),
      ],
    );
  }
}
