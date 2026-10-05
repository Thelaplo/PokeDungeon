import 'dart:math';

import '../../models/pokemon_type.dart';

abstract final class TypeDamage {
  static List<PokemonType> parseTypes(Iterable<String> apiNames) => [
    for (final apiName in apiNames) ?PokemonType.fromApiName(apiName),
  ];

  static double heroAttackMultiplier({
    required PokemonType heroType,
    required List<PokemonType> enemyTypes,
  }) => TypeChart.multiplier(heroType, enemyTypes);

  static double enemyContactMultiplier({
    required List<PokemonType> enemyTypes,
    required PokemonType heroType,
  }) {
    if (enemyTypes.isEmpty) {
      return 1;
    }
    return TypeChart.multiplier(enemyTypes.first, [heroType]);
  }

  static int scale(int damage, double multiplier) =>
      max(1, (damage * multiplier).round());
}
