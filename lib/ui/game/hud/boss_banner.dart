import 'package:flutter/material.dart';

import '../../../models/boss_status.dart';
import '../../../models/pokemon_type.dart';
import '../../hub/common/hub_progress_bar.dart';
import '../../hub/hub_style.dart';
import '../common/type_badge.dart';

class BossBanner extends StatelessWidget {
  const BossBanner({required this.bossStatus, required this.types, super.key});

  static const _maxWidth = 420.0;
  static const _bossHpGradient = LinearGradient(
    colors: [Color(0xFFFF8A75), Color(0xFFF2554A), Color(0xFFD93A3A)],
  );

  final BossStatus bossStatus;
  final List<PokemonType> types;

  @override
  Widget build(BuildContext context) {
    final isDailyEvent = bossStatus.isDailyEvent;
    final accentColor = isDailyEvent ? HubStyle.eventBorder : HubStyle.accent;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          decoration: HubStyle.panelDecoration(
            borderColor: accentColor,
            radius: 16,
            gradient: isDailyEvent
                ? HubStyle.eventGradient
                : HubStyle.panelGradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                bossStatus.title,
                textAlign: TextAlign.center,
                style: HubStyle.body(fontSize: 10, color: accentColor),
              ),
              Text(
                bossStatus.name,
                textAlign: TextAlign.center,
                style: HubStyle.title(fontSize: 18),
              ),
              if (types.isNotEmpty) ...[
                const SizedBox(height: 4),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  children: [for (final type in types) TypeBadge(type: type)],
                ),
              ],
              const SizedBox(height: 6),
              HubProgressBar(
                ratio: bossStatus.hpRatio,
                gradient: _bossHpGradient,
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
