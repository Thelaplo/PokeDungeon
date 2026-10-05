import 'dart:convert';
import 'dart:typed_data';

import 'package:poke_dungeon/game/chapters/chapter_catalog.dart';
import 'package:poke_dungeon/game/heroes/hero_catalog.dart';
import 'package:poke_dungeon/game/items/item_catalog.dart';
import 'package:poke_dungeon/models/hero_definition.dart';
import 'package:poke_dungeon/models/item_definition.dart';
import 'package:poke_dungeon/models/monster_data.dart';
import 'package:poke_dungeon/models/run_config.dart';
import 'package:poke_dungeon/services/poke_api_service.dart';

const spriteUrl = 'https://sprites.test/monster.png';
const _onePixelPng =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

class FakePokeApiService extends PokeApiService {
  FakePokeApiService({this.monsterTypes = const ['normal']});

  final List<String> monsterTypes;
  bool isClosed = false;

  @override
  Future<List<int>> fetchFirstGenerationIdsOfType(String pokemonType) async =>
      const [10, 11];

  @override
  Future<MonsterData> fetchMonster(int pokemonId) async => MonsterData(
    id: pokemonId,
    name: 'MON$pokemonId',
    baseHp: 30,
    attack: 40,
    speed: 0,
    spriteUrl: spriteUrl,
    types: monsterTypes,
  );

  @override
  Future<Uint8List> fetchSpriteBytes(String spriteUrl) async =>
      base64Decode(_onePixelPng);

  @override
  void close() => isClosed = true;
}

RunConfig chapterOneConfig({HeroDefinition hero = HeroCatalog.trainer}) =>
    RunConfig(
      chapter: ChapterCatalog.byNumber(1),
      hero: hero,
      loadout: const EquipmentLoadout({
        EquipmentSlot.attack: OwnedEquipment(
          item: ItemCatalog.charcoal,
          level: 2,
        ),
      }),
      startingConsumables: const {ItemCatalog.potion: 2},
    );
