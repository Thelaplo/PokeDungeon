import 'package:flutter/material.dart';

import '../hub_style.dart';

enum HubCurrency {
  coins(name: 'Pokédollars', color: HubStyle.gold),
  gems(name: 'gemmes', color: HubStyle.gem);

  const HubCurrency({required this.name, required this.color});

  final String name;
  final Color color;
}
