import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:poke_dungeon/services/poke_api_service.dart';
import 'package:poke_dungeon/ui/hub/app/hub_scroll_behavior.dart';
import 'package:poke_dungeon/ui/hub/app/hub_theme.dart';
import 'package:poke_dungeon/ui/hub/app/profile_gate_view.dart';

import '../../profile/profile_test_fixtures.dart';

const _bottomAreaRatio = 0.8;

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final viewSize in const [Size(375, 812), Size(1280, 800)]) {
    testWidgets(
      'app shell shows header, play button and bottom nav at $viewSize',
      (tester) async {
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
            scrollBehavior: const HubScrollBehavior(),
            home: ProfileGateView(
              profileLoading: Future.value(buildProfile()),
              api: api,
              onRetry: () {},
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('Dresseur Nv. 1'), findsOneWidget);
        expect(find.text('JOUER'), findsOneWidget);
        for (final tabLabel in const [
          'BOUTIQUE',
          'ÉQUIPEMENT',
          'AVENTURE',
          'QUÊTES',
        ]) {
          final tabFinder = find.text(tabLabel);
          expect(tabFinder, findsOneWidget);
          expect(
            tester.getCenter(tabFinder).dy,
            greaterThan(viewSize.height * _bottomAreaRatio),
          );
          expect(
            tester.getTopRight(tabFinder).dx,
            lessThanOrEqualTo(viewSize.width),
          );
        }
        expect(
          tester.getCenter(find.text('JOUER')).dy,
          lessThan(tester.getCenter(find.text('AVENTURE')).dy),
        );
      },
    );
  }
}
