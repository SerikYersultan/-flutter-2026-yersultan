import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_exchange/main.dart';

void main() {
  testWidgets('shell shows three destinations and profile summary', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Language Exchange'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(3));
    expect(find.text('Search sessions'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Your profile'), findsOneWidget);
    expect(find.text('You are on 0 lists'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('removing all favourites displays the shared empty state', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favourites'));
    await tester.pumpAndSettle();

    while (find.byTooltip('Remove from favourites').evaluate().isNotEmpty) {
      await tester.tap(find.byTooltip('Remove from favourites').first);
      await tester.pumpAndSettle();
    }

    expect(
      find.text('No favourites yet. Tap a heart on the sessions list.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
