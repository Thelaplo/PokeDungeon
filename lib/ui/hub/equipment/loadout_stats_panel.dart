import 'package:flutter/material.dart';

import '../../../models/player_stats.dart';
import '../common/hub_panel.dart';
import '../hub_style.dart';

class LoadoutStatsPanel extends StatelessWidget {
  const LoadoutStatsPanel({required this.stats, super.key});

  static const _columnCount = 2;
  static const _spacing = 8.0;

  final PlayerStats stats;

  List<(IconData, String, String)> get _lines => [
    (Icons.favorite_rounded, 'PV max', '${stats.maxHp}'),
    (Icons.flash_on_rounded, 'Dégâts', '${stats.damage}'),
    (Icons.speed_rounded, 'Tirs/s', stats.shotsPerSecond.toStringAsFixed(1)),
    (Icons.scatter_plot_rounded, 'Projectiles', '${stats.projectileCount}'),
    (Icons.directions_run_rounded, 'Vitesse', '${stats.speed.round()}'),
    (
      Icons.security_rounded,
      'Réduction',
      '${(stats.damageReduction * 100).round()} %',
    ),
    (
      Icons.healing_rounded,
      'Régén.',
      '${stats.regenPerSecond.toStringAsFixed(1)}/s',
    ),
    (Icons.bloodtype_rounded, 'Soin/touche', '${stats.healOnHit}'),
    (Icons.radar_rounded, 'Aimant', '${stats.magnetRadius.round()}'),
  ];

  @override
  Widget build(BuildContext context) {
    return HubPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistiques', style: HubStyle.title(fontSize: 18)),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth =
                  (constraints.maxWidth - _spacing * (_columnCount - 1)) /
                  _columnCount;
              return Wrap(
                spacing: _spacing,
                runSpacing: _spacing,
                children: [
                  for (final (icon, label, value) in _lines)
                    SizedBox(
                      width: cellWidth,
                      child: _StatCell(icon: icon, label: label, value: value),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: HubStyle.deepNavy.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: HubStyle.gem),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HubStyle.body(fontSize: 12, color: HubStyle.mutedText),
            ),
          ),
          Text(value, style: HubStyle.title(fontSize: 15)),
        ],
      ),
    );
  }
}
