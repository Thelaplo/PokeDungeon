import 'dart:ui';

enum PokemonType {
  normal('normal', 'Normal', Color(0xFFA8A878)),
  fire('fire', 'Feu', Color(0xFFF08030)),
  water('water', 'Eau', Color(0xFF6890F0)),
  electric('electric', 'Électrik', Color(0xFFF8D030)),
  grass('grass', 'Plante', Color(0xFF78C850)),
  ice('ice', 'Glace', Color(0xFF98D8D8)),
  fighting('fighting', 'Combat', Color(0xFFC03028)),
  poison('poison', 'Poison', Color(0xFFA040A0)),
  ground('ground', 'Sol', Color(0xFFE0C068)),
  flying('flying', 'Vol', Color(0xFFA890F0)),
  psychic('psychic', 'Psy', Color(0xFFF85888)),
  bug('bug', 'Insecte', Color(0xFFA8B820)),
  rock('rock', 'Roche', Color(0xFFB8A038)),
  ghost('ghost', 'Spectre', Color(0xFF705898)),
  dragon('dragon', 'Dragon', Color(0xFF7038F8)),
  dark('dark', 'Ténèbres', Color(0xFF705848)),
  steel('steel', 'Acier', Color(0xFFB8B8D0)),
  fairy('fairy', 'Fée', Color(0xFFEE99AC));

  const PokemonType(this.apiName, this.label, this.color);

  final String apiName;
  final String label;
  final Color color;

  static PokemonType? fromApiName(String apiName) {
    for (final type in values) {
      if (type.apiName == apiName) {
        return type;
      }
    }
    return null;
  }
}

enum TypeEffectiveness {
  immune('Aucun effet…'),
  notVeryEffective('Pas très efficace…'),
  neutral(''),
  superEffective('Super efficace !');

  const TypeEffectiveness(this.label);

  final String label;
}

abstract final class TypeChart {
  static const superEffectiveMultiplier = 2.0;
  static const notVeryEffectiveMultiplier = 0.5;
  static const immuneMultiplier = 0.25;

  static const _superEffective = <PokemonType, Set<PokemonType>>{
    PokemonType.fire: {
      PokemonType.grass,
      PokemonType.ice,
      PokemonType.bug,
      PokemonType.steel,
    },
    PokemonType.water: {PokemonType.fire, PokemonType.ground, PokemonType.rock},
    PokemonType.electric: {PokemonType.water, PokemonType.flying},
    PokemonType.grass: {
      PokemonType.water,
      PokemonType.ground,
      PokemonType.rock,
    },
    PokemonType.ice: {
      PokemonType.grass,
      PokemonType.ground,
      PokemonType.flying,
      PokemonType.dragon,
    },
    PokemonType.fighting: {
      PokemonType.normal,
      PokemonType.ice,
      PokemonType.rock,
      PokemonType.dark,
      PokemonType.steel,
    },
    PokemonType.poison: {PokemonType.grass, PokemonType.fairy},
    PokemonType.ground: {
      PokemonType.fire,
      PokemonType.electric,
      PokemonType.poison,
      PokemonType.rock,
      PokemonType.steel,
    },
    PokemonType.flying: {
      PokemonType.grass,
      PokemonType.fighting,
      PokemonType.bug,
    },
    PokemonType.psychic: {PokemonType.fighting, PokemonType.poison},
    PokemonType.bug: {PokemonType.grass, PokemonType.psychic, PokemonType.dark},
    PokemonType.rock: {
      PokemonType.fire,
      PokemonType.ice,
      PokemonType.flying,
      PokemonType.bug,
    },
    PokemonType.ghost: {PokemonType.psychic, PokemonType.ghost},
    PokemonType.dragon: {PokemonType.dragon},
    PokemonType.dark: {PokemonType.psychic, PokemonType.ghost},
    PokemonType.steel: {PokemonType.ice, PokemonType.rock, PokemonType.fairy},
    PokemonType.fairy: {
      PokemonType.fighting,
      PokemonType.dragon,
      PokemonType.dark,
    },
  };

  static const _notVeryEffective = <PokemonType, Set<PokemonType>>{
    PokemonType.normal: {PokemonType.rock, PokemonType.steel},
    PokemonType.fire: {
      PokemonType.fire,
      PokemonType.water,
      PokemonType.rock,
      PokemonType.dragon,
    },
    PokemonType.water: {
      PokemonType.water,
      PokemonType.grass,
      PokemonType.dragon,
    },
    PokemonType.electric: {
      PokemonType.electric,
      PokemonType.grass,
      PokemonType.dragon,
    },
    PokemonType.grass: {
      PokemonType.fire,
      PokemonType.grass,
      PokemonType.poison,
      PokemonType.flying,
      PokemonType.bug,
      PokemonType.dragon,
      PokemonType.steel,
    },
    PokemonType.ice: {
      PokemonType.fire,
      PokemonType.water,
      PokemonType.ice,
      PokemonType.steel,
    },
    PokemonType.fighting: {
      PokemonType.poison,
      PokemonType.flying,
      PokemonType.psychic,
      PokemonType.bug,
      PokemonType.fairy,
    },
    PokemonType.poison: {
      PokemonType.poison,
      PokemonType.ground,
      PokemonType.rock,
      PokemonType.ghost,
    },
    PokemonType.ground: {PokemonType.grass, PokemonType.bug},
    PokemonType.flying: {
      PokemonType.electric,
      PokemonType.rock,
      PokemonType.steel,
    },
    PokemonType.psychic: {PokemonType.psychic, PokemonType.steel},
    PokemonType.bug: {
      PokemonType.fire,
      PokemonType.fighting,
      PokemonType.poison,
      PokemonType.flying,
      PokemonType.ghost,
      PokemonType.steel,
      PokemonType.fairy,
    },
    PokemonType.rock: {
      PokemonType.fighting,
      PokemonType.ground,
      PokemonType.steel,
    },
    PokemonType.ghost: {PokemonType.dark},
    PokemonType.dragon: {PokemonType.steel},
    PokemonType.dark: {
      PokemonType.fighting,
      PokemonType.dark,
      PokemonType.fairy,
    },
    PokemonType.steel: {
      PokemonType.fire,
      PokemonType.water,
      PokemonType.electric,
      PokemonType.steel,
    },
    PokemonType.fairy: {
      PokemonType.fire,
      PokemonType.poison,
      PokemonType.steel,
    },
  };

  static const _immune = <PokemonType, Set<PokemonType>>{
    PokemonType.normal: {PokemonType.ghost},
    PokemonType.electric: {PokemonType.ground},
    PokemonType.fighting: {PokemonType.ghost},
    PokemonType.poison: {PokemonType.steel},
    PokemonType.ground: {PokemonType.flying},
    PokemonType.psychic: {PokemonType.dark},
    PokemonType.ghost: {PokemonType.normal},
    PokemonType.dragon: {PokemonType.fairy},
  };

  static double multiplierAgainstOne(
    PokemonType attacking,
    PokemonType defending,
  ) {
    if (_immune[attacking]?.contains(defending) ?? false) {
      return immuneMultiplier;
    }
    if (_superEffective[attacking]?.contains(defending) ?? false) {
      return superEffectiveMultiplier;
    }
    if (_notVeryEffective[attacking]?.contains(defending) ?? false) {
      return notVeryEffectiveMultiplier;
    }
    return 1;
  }

  static double multiplier(
    PokemonType attacking,
    Iterable<PokemonType> defending,
  ) => defending.fold(
    1.0,
    (product, type) => product * multiplierAgainstOne(attacking, type),
  );

  static TypeEffectiveness effectivenessOf(double multiplier) {
    if (multiplier <= immuneMultiplier) {
      return TypeEffectiveness.immune;
    }
    if (multiplier > 1) {
      return TypeEffectiveness.superEffective;
    }
    if (multiplier < 1) {
      return TypeEffectiveness.notVeryEffective;
    }
    return TypeEffectiveness.neutral;
  }

  static List<PokemonType> strongAgainstAll(
    Iterable<PokemonType> defendingTypes,
  ) => [
    for (final attacking in PokemonType.values)
      if (defendingTypes.any(
        (defending) => multiplierAgainstOne(attacking, defending) > 1,
      ))
        attacking,
  ];
}
