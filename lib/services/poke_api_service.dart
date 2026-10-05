import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/monster_data.dart';

class PokeApiException implements Exception {
  const PokeApiException(this.message);

  final String message;

  @override
  String toString() => 'PokeApiException: $message';
}

class PokeApiService {
  PokeApiService({http.Client? client}) : _client = client ?? http.Client();

  static const firstGenerationLastId = 151;
  static const minGameSpeed = 40.0;
  static const maxGameSpeed = 140.0;
  static const _speedFactor = 1.2;
  static const _defaultStat = 50;
  static const _baseUrl = 'https://pokeapi.co/api/v2';

  final http.Client _client;
  final Map<int, MonsterData> _monsterCache = {};
  final Map<String, List<int>> _typeCache = {};
  final Map<String, Uint8List> _spriteCache = {};

  /// Throws [PokeApiException].
  Future<MonsterData> fetchMonster(int pokemonId) async {
    final cachedMonster = _monsterCache[pokemonId];
    if (cachedMonster != null) {
      return cachedMonster;
    }

    final json = await _getJson('$_baseUrl/pokemon/$pokemonId');
    final monster = parseMonster(json);
    _monsterCache[pokemonId] = monster;
    return monster;
  }

  /// Throws [PokeApiException].
  Future<List<int>> fetchFirstGenerationIdsOfType(String pokemonType) async {
    final cachedIds = _typeCache[pokemonType];
    if (cachedIds != null) {
      return cachedIds;
    }

    final json = await _getJson('$_baseUrl/type/$pokemonType');
    final ids = parseFirstGenerationIds(json);
    _typeCache[pokemonType] = ids;
    return ids;
  }

  /// Throws [PokeApiException].
  Future<Uint8List> fetchSpriteBytes(String spriteUrl) async {
    final cachedBytes = _spriteCache[spriteUrl];
    if (cachedBytes != null) {
      return cachedBytes;
    }

    final response = await _send(Uri.parse(spriteUrl));
    _spriteCache[spriteUrl] = response.bodyBytes;
    return response.bodyBytes;
  }

  void close() => _client.close();

  /// Throws [PokeApiException].
  static MonsterData parseMonster(Map<String, dynamic> json) {
    final stats = json['stats'] as List<dynamic>;
    int statNamed(String statName) {
      for (final stat in stats.cast<Map<String, dynamic>>()) {
        final statInfo = stat['stat'] as Map<String, dynamic>;
        if (statInfo['name'] == statName) {
          return stat['base_stat'] as int;
        }
      }
      return _defaultStat;
    }

    final sprites = json['sprites'] as Map<String, dynamic>;
    final spriteUrl = sprites['front_default'] as String?;
    if (spriteUrl == null || spriteUrl.isEmpty) {
      throw PokeApiException('Pokémon ${json['id']} sans sprite');
    }

    final types = (json['types'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((slot) => (slot['type'] as Map<String, dynamic>)['name'] as String)
        .toList();

    return MonsterData(
      id: json['id'] as int,
      name: (json['name'] as String).toUpperCase(),
      baseHp: statNamed('hp'),
      attack: statNamed('attack'),
      speed: (statNamed('speed') * _speedFactor).clamp(
        minGameSpeed,
        maxGameSpeed,
      ),
      spriteUrl: spriteUrl,
      types: types,
    );
  }

  static List<int> parseFirstGenerationIds(Map<String, dynamic> json) {
    final entries = (json['pokemon'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return entries
        .map((entry) => entry['pokemon'] as Map<String, dynamic>)
        .map((pokemon) => _idFromResourceUrl(pokemon['url'] as String))
        .whereType<int>()
        .where((id) => id >= 1 && id <= firstGenerationLastId)
        .toList();
  }

  static int? _idFromResourceUrl(String resourceUrl) {
    final segments = Uri.parse(resourceUrl).pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    return segments.isEmpty ? null : int.tryParse(segments.last);
  }

  Future<Map<String, dynamic>> _getJson(String url) async {
    final response = await _send(Uri.parse(url));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<http.Response> _send(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri);
    } on Exception catch (error) {
      throw PokeApiException('Réseau indisponible pour $uri ($error)');
    }
    if (response.statusCode != 200) {
      throw PokeApiException('HTTP ${response.statusCode} sur $uri');
    }
    return response;
  }
}
