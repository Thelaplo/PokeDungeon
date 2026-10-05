import 'package:flutter/material.dart';

enum HubTab {
  shop('BOUTIQUE', Icons.storefront_rounded),
  equipment('ÉQUIPEMENT', Icons.shield_rounded),
  adventure('AVENTURE', Icons.catching_pokemon),
  quests('QUÊTES', Icons.assignment_turned_in_rounded);

  const HubTab(this.label, this.icon);

  final String label;
  final IconData icon;

  bool get isFeatured => this == adventure;
}
