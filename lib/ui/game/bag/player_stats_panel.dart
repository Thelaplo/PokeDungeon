import 'package:flutter/material.dart';

import '../../../models/player_stats.dart';
import '../../hub/common/hub_panel.dart';
import '../../hub/hub_style.dart';

class PlayerStatsPanel extends StatelessWidget {
  const PlayerStatsPanel({required this.stats, super.key});

  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    final lines = [
      ('PV max', '${stats.maxHp}'),
      ('Dégâts', '${stats.damage}'),
      ('Tirs/s', stats.shotsPerSecond.toStringAsFixed(1)),
      ('Projectiles', '${stats.projectileCount}'),
      ('Vitesse', '${stats.speed.round()}'),
      ('Réduction', '${(stats.damageReduction * 100).round()} %'),
      ('Régén.', '${stats.regenPerSecond.toStringAsFixed(1)} PV/s'),
      ('Soin/touche', '${stats.healOnHit}'),
      ('Aimant', '${stats.magnetRadius.round()}'),
    ];
    return HubPanel(
      radius: HubStyle.tileRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Statistiques', style: HubStyle.title(fontSize: 18)),
          const SizedBox(height: 8),
          for (final (label, value) in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: HubStyle.body(color: HubStyle.mutedText),
                    ),
                  ),
                  Text(value, style: HubStyle.body(color: HubStyle.white)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
