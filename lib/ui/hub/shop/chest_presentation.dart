import 'package:flutter/material.dart';

import '../../../profile/chest_type.dart';
import '../common/ball_style.dart';
import '../hub_style.dart';

extension ChestPresentation on ChestType {
  String get rarityRange => switch (this) {
    ChestType.pokeBall => 'Commun à épique',
    ChestType.hyperBall => 'Rare à légendaire',
  };

  String? get highlight => switch (this) {
    ChestType.pokeBall => null,
    ChestType.hyperBall => '10 % légendaire',
  };

  BallStyle get ballStyle => switch (this) {
    ChestType.pokeBall => BallStyle.pokeBall,
    ChestType.hyperBall => BallStyle.hyperBall,
  };

  Color get borderColor => switch (this) {
    ChestType.pokeBall => HubStyle.panelBorder,
    ChestType.hyperBall => HubStyle.eventBorder,
  };
}
