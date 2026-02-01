import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silownia_app/main.dart';

void main() {
  testWidgets('K.S-Gym smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KsGymApp());

    // Poczekaj na załadowanie widgetów
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Sprawdź czy aplikacja się uruchomiła - szukaj typowych elementów
    // StartChoiceScreen zawiera Scaffold
    expect(find.byType(Scaffold), findsWidgets);

    // Sprawdź czy jest jakikolwiek tekst (aplikacja się wyrenderowała)
    expect(find.byType(Text), findsWidgets);
  });
}
