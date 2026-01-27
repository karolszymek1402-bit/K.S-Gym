import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silownia_app/main.dart';

void main() {
  testWidgets('K.S-Gym smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KsGymApp());

    final singleTitle = find.text('K.S-GYM');
    final part1 = find.text('K.S');
    final part2 = find.text('GYM');

    // Jeśli istnieje pojedynczy tekst "K.S-GYM" — zaakceptuj go,
    // w przeciwnym razie sprawdź obecność dwóch osobnych Textów: "K.S" i "GYM".
    if (singleTitle.evaluate().isNotEmpty) {
      expect(singleTitle, findsWidgets);
    } else {
      expect(part1, findsOneWidget);
      expect(part2, findsOneWidget);
    }

    // Dodatkowa kontrola: AppBar jest obecny
    expect(find.byType(AppBar), findsOneWidget);
  });
}
