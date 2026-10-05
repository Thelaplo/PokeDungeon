import 'dart:ui';

import '../../models/hero_definition.dart';
import '../../models/pokemon_type.dart';
import '../../models/stat_modifiers.dart';

abstract final class HeroCatalog {
  static const trainer = HeroDefinition(
    id: 'trainer',
    name: 'Dresseur',
    title: 'Le débutant',
    ability: HeroAbility.none,
    unlock: HeroUnlock.starter(),
    accentColor: Color(0xFFE83838),
  );
  static const pikachu = HeroDefinition(
    id: 'pikachu',
    name: 'Pikachu',
    title: 'La souris électrique',
    pokemonId: 25,
    type: PokemonType.electric,
    ability: HeroAbility.chainLightning,
    unlock: HeroUnlock.trainerLevel(3),
    accentColor: Color(0xFFFFD84A),
    modifiers: StatModifiers(speedPercent: 0.1, maxHpBonus: -10),
  );
  static const charmander = HeroDefinition(
    id: 'charmander',
    name: 'Salamèche',
    title: 'La flamme vive',
    pokemonId: 4,
    type: PokemonType.fire,
    ability: HeroAbility.burn,
    unlock: HeroUnlock.chapterCompleted(1),
    accentColor: Color(0xFFFF7A2A),
    modifiers: StatModifiers(damagePercent: 0.1),
  );
  static const squirtle = HeroDefinition(
    id: 'squirtle',
    name: 'Carapuce',
    title: 'Le bouclier',
    pokemonId: 7,
    type: PokemonType.water,
    ability: HeroAbility.shield,
    unlock: HeroUnlock.trainerLevel(8),
    accentColor: Color(0xFF4AB8FF),
    modifiers: StatModifiers(maxHpBonus: 20, speedPercent: -0.05),
  );
  static const bulbasaur = HeroDefinition(
    id: 'bulbasaur',
    name: 'Bulbizarre',
    title: 'La graine',
    pokemonId: 1,
    type: PokemonType.grass,
    ability: HeroAbility.leech,
    unlock: HeroUnlock.gems(250),
    accentColor: Color(0xFF5EE6B0),
    modifiers: StatModifiers(regenPerSecond: 0.5),
  );
  static const eevee = HeroDefinition(
    id: 'eevee',
    name: 'Évoli',
    title: 'L\'imprévisible',
    pokemonId: 133,
    ability: HeroAbility.adaptability,
    unlock: HeroUnlock.chapterCompleted(3),
    accentColor: Color(0xFFC8925A),
  );
  static const mewtwo = HeroDefinition(
    id: 'mewtwo',
    name: 'Mewtwo',
    title: 'Le clone ultime',
    pokemonId: 150,
    type: PokemonType.psychic,
    ability: HeroAbility.psychicPower,
    unlock: HeroUnlock.chapterCompleted(6),
    accentColor: Color(0xFFC77DFF),
    modifiers: StatModifiers(damagePercent: 0.2, maxHpBonus: 20),
  );

  static const all = [
    trainer,
    pikachu,
    charmander,
    squirtle,
    bulbasaur,
    eevee,
    mewtwo,
  ];

  static HeroDefinition? byId(String id) {
    for (final hero in all) {
      if (hero.id == id) {
        return hero;
      }
    }
    return null;
  }
}
