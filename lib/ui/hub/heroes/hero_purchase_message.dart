import '../../../models/hero_definition.dart';
import '../../../profile/player_profile.dart';

String heroPurchaseMessage(HeroPurchaseResult result, HeroDefinition hero) =>
    switch (result) {
      HeroPurchaseResult.purchased => '${hero.name} rejoint ton équipe !',
      HeroPurchaseResult.notEnoughGems => 'Pas assez de gemmes.',
      HeroPurchaseResult.alreadyUnlocked => '${hero.name} est déjà débloqué.',
      HeroPurchaseResult.notForSale => '${hero.name} ne s\'achète pas.',
    };
