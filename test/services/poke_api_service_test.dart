import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:poke_dungeon/services/poke_api_service.dart';

Map<String, dynamic> pokemonJson({
  int id = 4,
  String? spriteUrl = 'https://sprites.test/4.png',
  int speed = 65,
}) => {
  'id': id,
  'name': 'charmander',
  'stats': [
    {
      'base_stat': 39,
      'stat': {'name': 'hp'},
    },
    {
      'base_stat': 52,
      'stat': {'name': 'attack'},
    },
    {
      'base_stat': speed,
      'stat': {'name': 'speed'},
    },
  ],
  'sprites': {'front_default': spriteUrl},
  'types': [
    {
      'slot': 1,
      'type': {'name': 'fire'},
    },
  ],
};

void main() {
  group('parseMonster', () {
    test('extracts the stats, sprite and types the game needs', () {
      final monster = PokeApiService.parseMonster(pokemonJson());

      expect(monster.id, 4);
      expect(monster.name, 'CHARMANDER');
      expect(monster.baseHp, 39);
      expect(monster.attack, 52);
      expect(monster.speed, closeTo(78, 0.001));
      expect(monster.spriteUrl, 'https://sprites.test/4.png');
      expect(monster.types, ['fire']);
    });

    test('clamps the speed into the playable range', () {
      expect(
        PokeApiService.parseMonster(pokemonJson(speed: 5)).speed,
        PokeApiService.minGameSpeed,
      );
      expect(
        PokeApiService.parseMonster(pokemonJson(speed: 200)).speed,
        PokeApiService.maxGameSpeed,
      );
    });

    test('rejects a pokemon without a front sprite', () {
      expect(
        () => PokeApiService.parseMonster(pokemonJson(spriteUrl: null)),
        throwsA(isA<PokeApiException>()),
      );
    });
  });

  test('parseFirstGenerationIds keeps only ids from 1 to 151', () {
    final json = {
      'pokemon': [
        {
          'pokemon': {
            'name': 'charmander',
            'url': 'https://pokeapi.co/api/v2/pokemon/4/',
          },
        },
        {
          'pokemon': {
            'name': 'moltres',
            'url': 'https://pokeapi.co/api/v2/pokemon/146/',
          },
        },
        {
          'pokemon': {
            'name': 'cyndaquil',
            'url': 'https://pokeapi.co/api/v2/pokemon/155/',
          },
        },
      ],
    };

    expect(PokeApiService.parseFirstGenerationIds(json), [4, 146]);
  });

  test('fetchMonster hits the network once per pokemon id', () async {
    var requestCount = 0;
    final service = PokeApiService(
      client: MockClient((request) async {
        requestCount++;
        return http.Response(jsonEncode(pokemonJson()), 200);
      }),
    );

    await service.fetchMonster(4);
    await service.fetchMonster(4);

    expect(requestCount, 1);
  });

  test('fetchMonster turns an HTTP error into a PokeApiException', () async {
    final service = PokeApiService(
      client: MockClient((request) async => http.Response('Not Found', 404)),
    );

    expect(service.fetchMonster(9999), throwsA(isA<PokeApiException>()));
  });
}
