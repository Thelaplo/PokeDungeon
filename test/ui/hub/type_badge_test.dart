import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poke_dungeon/models/pokemon_type.dart';
import 'package:poke_dungeon/ui/hub/common/type_badge.dart';

Future<void> _pumpBadge(WidgetTester tester, TypeBadge badge) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: badge)),
      ),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('shows the french type label', (tester) async {
    await _pumpBadge(tester, const TypeBadge(type: PokemonType.electric));

    expect(find.text('Électrik'), findsOneWidget);
  });

  testWidgets('announces the type to screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpBadge(tester, const TypeBadge(type: PokemonType.fire));

    expect(find.bySemanticsLabel('Type Feu'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('uses the type color in its gradient', (tester) async {
    await _pumpBadge(
      tester,
      const TypeBadge(type: PokemonType.water, isCompact: true),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(TypeBadge),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    final gradient = decoration.gradient! as LinearGradient;
    expect(
      gradient.colors.first,
      Color.lerp(PokemonType.water.color, Colors.white, 0.2),
    );
  });
}
