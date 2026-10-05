import '../../../models/item_definition.dart';
import '../../../profile/player_profile.dart';

String shopPurchaseMessage(ShopPurchaseResult result, ItemDefinition item) =>
    switch (result) {
      ShopPurchaseResult.purchased => switch (item) {
        EquipmentItem() => '${item.name} rejoint ton sac !',
        ConsumableItem() => '${item.name} prête pour la prochaine aventure !',
      },
      ShopPurchaseResult.notEnoughCoins => 'Pas assez de Pokédollars.',
      ShopPurchaseResult.notEnoughGems => 'Pas assez de gemmes.',
      ShopPurchaseResult.alreadyOwned => 'Tu possèdes déjà cet objet.',
    };
