import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_exchange/main.dart';
import 'package:language_exchange/models/exchange_session.dart';
import 'package:language_exchange/screens/session_detail_screen.dart';
import 'package:language_exchange/tabs/sessions_tab.dart';

List<ExchangeSession> shellSessions(WidgetTester tester) {
  return tester
      .widget<SessionsTab>(
        find.byWidgetPredicate(
          (widget) => widget is SessionsTab && !widget.favouritesOnly,
        ),
      )
      .sessions;
}

Future<ExchangeSession> openDelete(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
  final selected = shellSessions(tester).first;

  await tester.tap(find.text(selected.title));
  await tester.pumpAndSettle();
  expect(find.byType(SessionDetailScreen), findsOneWidget);

  await tester.tap(find.byKey(const ValueKey('session-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Delete'));
  await tester.pumpAndSettle();
  expect(find.text('Delete this session?'), findsOneWidget);
  return selected;
}

void main() {
  testWidgets('Delete Cancel preserves session and keeps detail open', (
    tester,
  ) async {
    final selected = await openDelete(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Cancel'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(SessionDetailScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(shellSessions(tester), hasLength(12));
    expect(
      shellSessions(tester).singleWhere((session) => session.id == selected.id),
      same(selected),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirmed Delete removes session from both shell tabs', (
    tester,
  ) async {
    final selected = await openDelete(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SessionDetailScreen), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(shellSessions(tester), hasLength(11));
    expect(
      shellSessions(tester).any((session) => session.id == selected.id),
      isFalse,
    );
    expect(find.text('Session deleted'), findsOneWidget);

    await tester.tap(find.text('Favourites'));
    await tester.pumpAndSettle();
    final favourites = tester.widget<SessionsTab>(
      find.byWidgetPredicate(
        (widget) => widget is SessionsTab && widget.favouritesOnly,
      ),
    );
    expect(
      favourites.sessions.any((session) => session.id == selected.id),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });
}
