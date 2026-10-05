import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:poke_dungeon/profile/player_profile.dart';
import 'package:poke_dungeon/services/poke_api_service.dart';
import 'package:poke_dungeon/ui/hub/app/hub_theme.dart';
import 'package:poke_dungeon/ui/hub/hub_screen.dart';

import '../../profile/profile_test_fixtures.dart';

const _phoneSize = Size(412, 915);
const _smallPhoneSize = Size(360, 640);
const _desktopSize = Size(1280, 800);

Future<void> _pumpHub(
  WidgetTester tester,
  PlayerProfile profile, {
  Size viewSize = _phoneSize,
}) async {
  tester.view
    ..physicalSize = viewSize
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final api = PokeApiService(
    client: MockClient((request) async => http.Response('', 404)),
  );
  addTearDown(api.close);
  await tester.pumpWidget(
    MaterialApp(
      theme: HubTheme.dark(),
      home: HubScreen(profile: profile, api: api),
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('opens on the adventure tab with a playable first chapter', (
    tester,
  ) async {
    await _pumpHub(tester, buildProfile());

    expect(find.text('JOUER'), findsOneWidget);
    expect(find.text('Forêt de Jade'), findsOneWidget);
    expect(find.text('ÉVÉNEMENT DU JOUR'), findsOneWidget);
  });

  testWidgets('quests tab shows the daily progress card', (tester) async {
    await _pumpHub(tester, buildProfile());

    await tester.tap(find.text('QUÊTES'));
    await tester.pumpAndSettle();

    expect(find.text('Quêtes du jour'), findsOneWidget);
    expect(find.text('Progression du jour'), findsOneWidget);
  });

  testWidgets('shop tab shows both chests', (tester) async {
    await _pumpHub(tester, buildProfile());

    await tester.tap(find.text('BOUTIQUE'));
    await tester.pumpAndSettle();

    expect(find.text('Poké Ball'), findsOneWidget);
    expect(find.text('Hyper Ball'), findsOneWidget);
  });

  testWidgets('equipment tab opens the heroes screen', (tester) async {
    await _pumpHub(tester, buildProfile());

    await tester.tap(find.text('ÉQUIPEMENT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HÉROS'));
    await tester.pumpAndSettle();

    expect(find.text('Héros'), findsOneWidget);
    expect(find.text('CHOISI'), findsOneWidget);
  });

  for (final viewSize in const [_smallPhoneSize, _desktopSize]) {
    testWidgets('every tab lays out without overflow at $viewSize', (
      tester,
    ) async {
      await _pumpHub(tester, buildProfile(), viewSize: viewSize);

      for (final tabLabel in const ['BOUTIQUE', 'ÉQUIPEMENT', 'QUÊTES']) {
        await tester.tap(find.text(tabLabel));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('ÉQUIPEMENT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('HÉROS'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
