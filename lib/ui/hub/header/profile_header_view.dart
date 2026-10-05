import 'package:flutter/material.dart';

import '../../../profile/player_profile.dart';
import '../common/hub_currency.dart';
import 'currency_pill.dart';
import 'hero_avatar.dart';
import 'trainer_level_panel.dart';

class ProfileHeaderView extends StatelessWidget {
  const ProfileHeaderView({
    required this.profile,
    required this.onShopRequested,
    super.key,
  });

  final PlayerProfile profile;
  final VoidCallback onShopRequested;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profile,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 6),
        child: Row(
          children: [
            HeroAvatar(hero: profile.selectedHero, level: profile.trainerLevel),
            const SizedBox(width: 12),
            Expanded(
              child: TrainerLevelPanel(
                level: profile.trainerLevel,
                experienceIntoLevel: profile.xpIntoLevel,
                experienceForNextLevel: profile.xpForNextLevel,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                CurrencyPill(
                  currency: HubCurrency.coins,
                  amount: profile.coins,
                  onAddPressed: onShopRequested,
                ),
                CurrencyPill(
                  currency: HubCurrency.gems,
                  amount: profile.gems,
                  onAddPressed: onShopRequested,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
