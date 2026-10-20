import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_exchange/data/seed_sessions.dart';
import 'package:language_exchange/utils/format.dart';
import 'package:language_exchange/widgets/session_card.dart';

void main() {
  test('date formatting uses month labels and padded minutes', () {
    expect(formatDateTime(DateTime(2026, 10, 18, 10)), '18 Oct, 10:00');
    expect(formatDateTime(DateTime(2026, 1, 2, 9, 5)), '2 Jan, 9:05');
    expect(formatDateTime(DateTime(2026, 12, 31, 23, 59)), '31 Dec, 23:59');
  });

  testWidgets('long title fits a narrow card and callbacks are independent', (
    tester,
  ) async {
    final session = createSeedSessions().first;
    var opened = 0;
    var favourites = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: SessionCard(
                session: session,
                onTap: () => opened++,
                onFavourite: () => favourites++,
              ),
            ),
          ),
        ),
      ),
    );

    expect(session.title.length, 60);
    expect(find.text('2 / 12 joined'), findsOneWidget);
    expect(find.text('FULL'), findsNothing);
    expect(find.text('10 left'), findsNothing);
    expect(tester.takeException(), isNull);

    final title = tester.widget<Text>(find.text(session.title));
    expect(title.maxLines, 2);
    expect(title.overflow, TextOverflow.ellipsis);

    await tester.tap(find.byTooltip('Remove from favourites'));
    expect(favourites, 1);
    expect(opened, 0);

    await tester.tap(find.text(session.title));
    expect(opened, 1);
    expect(favourites, 1);
  });

  testWidgets('badge shows full, low capacity, or nothing', (tester) async {
    final original = createSeedSessions().first;

    for (final limit in [2, 5, 12]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionCard(
              session: original.copyWith(limit: limit),
              onTap: () {},
              onFavourite: () {},
            ),
          ),
        ),
      );

      expect(find.text('FULL'), limit == 2 ? findsOneWidget : findsNothing);
      expect(find.text('3 left'), limit == 5 ? findsOneWidget : findsNothing);
      expect(find.text('10 left'), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });
}
