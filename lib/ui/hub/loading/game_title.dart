import 'package:flutter/material.dart';

import '../hub_style.dart';

class GameTitle extends StatelessWidget {
  const GameTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'Poké Dungeon',
      excludeSemantics: true,
      child: Column(
        children: [
          Text(
            'Poké',
            style: HubStyle.title(fontSize: 52, color: HubStyle.accent),
          ),
          Text('Dungeon', style: HubStyle.title(fontSize: 40)),
        ],
      ),
    );
  }
}
