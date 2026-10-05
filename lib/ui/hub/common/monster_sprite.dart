import 'package:flutter/material.dart';

import '../../../models/monster_data.dart';
import '../hub_style.dart';

class MonsterSprite extends StatelessWidget {
  const MonsterSprite({
    required this.monster,
    required this.side,
    this.isSilhouette = false,
    super.key,
  });

  static const hiddenMonsterLabel = 'Pokémon mystère';

  final Future<MonsterData> monster;
  final double side;
  final bool isSilhouette;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: side,
      child: FutureBuilder<MonsterData>(
        future: monster,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _UnknownMonster(side: side);
          }
          final monsterData = snapshot.data;
          if (monsterData == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: HubStyle.accent,
                strokeWidth: 4,
              ),
            );
          }
          final image = Image.network(
            monsterData.spriteUrl,
            width: side,
            height: side,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
            semanticLabel: isSilhouette ? hiddenMonsterLabel : monsterData.name,
            errorBuilder: (context, error, stackTrace) =>
                _UnknownMonster(side: side),
          );
          if (!isSilhouette) {
            return image;
          }
          return ColorFiltered(
            colorFilter: const ColorFilter.mode(
              HubStyle.silhouette,
              BlendMode.srcIn,
            ),
            child: image,
          );
        },
      ),
    );
  }
}

class _UnknownMonster extends StatelessWidget {
  const _UnknownMonster({required this.side});

  static const _fontRatio = 0.4;

  final double side;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '?',
        semanticsLabel: MonsterSprite.hiddenMonsterLabel,
        style: HubStyle.title(fontSize: side * _fontRatio),
      ),
    );
  }
}
