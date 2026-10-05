import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HubScrollBehavior extends MaterialScrollBehavior {
  const HubScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
