import 'package:flutter/material.dart';

import '../../../models/item_definition.dart';
import '../../../profile/player_profile.dart';
import '../common/currency_icon.dart';
import '../common/hub_button.dart';
import '../common/hub_button_variant.dart';
import '../common/hub_currency.dart';
import '../common/hub_layout.dart';
import '../common/hub_snack_bar.dart';
import '../common/rarity_chip.dart';
import '../common/rarity_item_frame.dart';
import '../hub_style.dart';
import 'equipment_effects_column.dart';

class EquipmentDetailSheet extends StatefulWidget {
  const EquipmentDetailSheet({
    required this.profile,
    required this.item,
    super.key,
  });

  final PlayerProfile profile;
  final EquipmentItem item;

  static Future<void> show(
    BuildContext context, {
    required PlayerProfile profile,
    required EquipmentItem item,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: HubLayout.maxContentWidth),
    builder: (context) => EquipmentDetailSheet(profile: profile, item: item),
  );

  @override
  State<EquipmentDetailSheet> createState() => _EquipmentDetailSheetState();
}

class _EquipmentDetailSheetState extends State<EquipmentDetailSheet> {
  static const _frameSide = 84.0;
  static const _topRadius = Radius.circular(26);

  String? _feedbackMessage;

  PlayerProfile get _profile => widget.profile;

  EquipmentItem get _item => widget.item;

  void _toggleEquipped() {
    final isEquipped = _profile.isEquipped(_item);
    if (isEquipped) {
      _profile.unequip(_item.slot);
    } else {
      _profile.equip(_item);
    }
    showHubSnackBar(
      context,
      isEquipped ? '${_item.name} retiré.' : '${_item.name} équipé !',
    );
    Navigator.of(context).pop();
  }

  void _upgrade() {
    final message = switch (_profile.upgrade(_item)) {
      UpgradeResult.upgraded =>
        'Amélioré au niveau ${_profile.levelOf(_item)} !',
      UpgradeResult.notEnoughCoins => 'Pas assez de Pokédollars.',
      UpgradeResult.maxLevelReached => 'Niveau maximum atteint.',
      UpgradeResult.notOwned => 'Tu ne possèdes pas cet objet.',
    };
    setState(() => _feedbackMessage = message);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _profile,
      builder: (context, _) {
        final level = _profile.levelOf(_item);
        final isMaxLevel = level >= EquipmentItem.maxLevel;
        final upgradeCost = _item.upgradeCost(level);
        final canAffordUpgrade = _profile.coins >= upgradeCost;
        final isEquipped = _profile.isEquipped(_item);
        final feedbackMessage = _feedbackMessage;
        return Container(
          decoration: const BoxDecoration(
            gradient: HubStyle.panelGradient,
            borderRadius: BorderRadius.only(
              topLeft: _topRadius,
              topRight: _topRadius,
            ),
            border: Border(
              top: BorderSide(color: HubStyle.panelBorder, width: 2),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SheetHandle(),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      RarityItemFrame(
                        item: _item,
                        side: _frameSide,
                        level: level,
                        isEquipped: isEquipped,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _item.name,
                              style: HubStyle.title(fontSize: 24),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                RarityChip(rarity: _item.rarity),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _item.slot.label,
                                    style: HubStyle.body(
                                      color: HubStyle.mutedText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Niveau $level / ${EquipmentItem.maxLevel}',
                              style: HubStyle.title(
                                fontSize: 15,
                                color: HubStyle.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: EquipmentEffectsColumn(
                          title: 'Actuel',
                          effects: _item.describeAtLevel(level),
                          effectColor: HubStyle.softText,
                        ),
                      ),
                      if (!isMaxLevel) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 24,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: HubStyle.success,
                          ),
                        ),
                        Expanded(
                          child: EquipmentEffectsColumn(
                            title: 'Niveau ${level + 1}',
                            effects: _item.describeAtLevel(level + 1),
                            effectColor: HubStyle.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (feedbackMessage != null) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        feedbackMessage,
                        textAlign: TextAlign.center,
                        style: HubStyle.title(
                          fontSize: 16,
                          color: HubStyle.accent,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: HubButton(
                          label: isEquipped ? 'RETIRER' : 'ÉQUIPER',
                          variant: isEquipped
                              ? HubButtonVariant.info
                              : HubButtonVariant.secondary,
                          onPressed: _toggleEquipped,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: HubButton(
                          label: isMaxLevel ? 'NIV. MAX' : 'AMÉLIORER',
                          semanticLabel: isMaxLevel
                              ? 'Niveau maximum atteint'
                              : 'Améliorer pour $upgradeCost Pokédollars',
                          caption: isMaxLevel
                              ? null
                              : _UpgradeCost(cost: upgradeCost),
                          onPressed: isMaxLevel || !canAffordUpgrade
                              ? null
                              : _upgrade,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _upgradeHint(
                      isMaxLevel: isMaxLevel,
                      missingCoins: upgradeCost - _profile.coins,
                    ),
                    textAlign: TextAlign.end,
                    style: HubStyle.body(
                      fontSize: 12,
                      color: HubStyle.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _upgradeHint({required bool isMaxLevel, required int missingCoins}) {
    if (isMaxLevel) {
      return 'Cet objet est au maximum.';
    }
    if (missingCoins > 0) {
      return 'Il te manque $missingCoins ₽';
    }
    return 'Prochain niveau : effets renforcés';
  }
}

class _UpgradeCost extends StatelessWidget {
  const _UpgradeCost({required this.cost});

  final int cost;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CurrencyIcon(currency: HubCurrency.coins, size: 16),
        const SizedBox(width: 4),
        Text('$cost', style: HubStyle.title(fontSize: 14)),
      ],
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 48,
        height: 5,
        decoration: BoxDecoration(
          color: HubStyle.panelBorder,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
