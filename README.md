# Poké Dungeon

Rogue-lite top-down façon Archero en Flutter + Flame : chapitres de 10 salles, compétences à chaque salle, équipement améliorable, héros Pokémon à débloquer, types et faiblesses, quêtes quotidiennes. Les Pokémon, sprites et objets viennent de [PokéAPI](https://pokeapi.co).

## Prérequis

- Flutter 3.47+ (Dart 3.13+)
- Une connexion internet en jeu (PokéAPI et Google Fonts)

## Lancer

```bash
flutter pub get
flutter run -d chrome
```

Autres cibles : `flutter run -d windows`, ou un appareil Android / iOS.

## Tester

```bash
flutter test
dart analyze
```

## Contrôles

- Joystick ou ZQSD / WASD : se déplacer
- Immobile : tir automatique sur l'ennemi le plus proche (Espace pour tirer manuellement)
- I ou Échap : sac · P : pause
