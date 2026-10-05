import 'package:flutter/material.dart';

import '../../../models/hero_definition.dart';
import '../common/hero_on_pedestal.dart';
import '../common/hub_button.dart';
import '../common/hub_dialog_frame.dart';
import '../hub_style.dart';

class NewHeroDialog extends StatelessWidget {
  const NewHeroDialog({required this.heroes, super.key});

  static const _pedestalSize = 104.0;

  final List<HeroDefinition> heroes;

  @override
  Widget build(BuildContext context) {
    return HubDialogFrame(
      borderColor: HubStyle.accent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            liveRegion: true,
            child: Text(
              heroes.length > 1 ? 'Nouveaux héros !' : 'Nouveau héros !',
              textAlign: TextAlign.center,
              style: HubStyle.title(fontSize: 30, color: HubStyle.accent),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              for (final hero in heroes)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HeroOnPedestal(hero: hero, size: _pedestalSize),
                    const SizedBox(height: 6),
                    Text(hero.name, style: HubStyle.title(fontSize: 20)),
                    Text(
                      hero.ability.label,
                      style: HubStyle.body(
                        fontSize: 12,
                        color: HubStyle.mutedText,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Choisis ton héros depuis l\'onglet Équipement.',
            textAlign: TextAlign.center,
            style: HubStyle.body(),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: HubButton(
              label: 'GÉNIAL !',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
