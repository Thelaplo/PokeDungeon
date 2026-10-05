import 'dart:ui';

import 'pokemon_type.dart';
import 'stat_modifiers.dart';

enum HeroAbility {
  none('Polyvalent', 'Aucune faiblesse, aucun talent particulier.'),
  chainLightning(
    'Éclair en chaîne',
    'Chaque tir rebondit sur un ennemi proche.',
  ),
  burn('Brûlure', 'Les tirs enflamment l\'ennemi : dégâts sur 3 s.'),
  shield('Carapace', 'Un bouclier bloque un coup toutes les 8 s.'),
  leech('Vampigraine', 'Chaque Pokémon vaincu rend 3 PV.'),
  adaptability('Adaptabilité', 'Choisis parmi 4 compétences au lieu de 3.'),
  psychicPower('Psyko', 'Les tirs transpercent tous les ennemis.');

  const HeroAbility(this.label, this.description);

  final String label;
  final String description;
}

enum HeroUnlockKind { starter, trainerLevel, chapterCompleted, gems }

class HeroUnlock {
  const HeroUnlock.starter() : kind = HeroUnlockKind.starter, value = 0;

  const HeroUnlock.trainerLevel(this.value)
    : kind = HeroUnlockKind.trainerLevel;

  const HeroUnlock.chapterCompleted(this.value)
    : kind = HeroUnlockKind.chapterCompleted;

  const HeroUnlock.gems(this.value) : kind = HeroUnlockKind.gems;

  final HeroUnlockKind kind;
  final int value;

  String describe() => switch (kind) {
    HeroUnlockKind.starter => 'Disponible',
    HeroUnlockKind.trainerLevel => 'Dresseur niveau $value',
    HeroUnlockKind.chapterCompleted => 'Terminer le chapitre $value',
    HeroUnlockKind.gems => '$value gemmes',
  };
}

class HeroDefinition {
  const HeroDefinition({
    required this.id,
    required this.name,
    required this.title,
    required this.ability,
    required this.unlock,
    required this.accentColor,
    this.pokemonId,
    this.modifiers = const StatModifiers(),
    this.type = PokemonType.normal,
  });

  final String id;
  final String name;
  final String title;
  final HeroAbility ability;
  final HeroUnlock unlock;
  final Color accentColor;
  final int? pokemonId;
  final StatModifiers modifiers;
  final PokemonType type;

  bool get isTrainer => pokemonId == null;

  String? get spriteUrl => pokemonId == null
      ? null
      : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png';
}
