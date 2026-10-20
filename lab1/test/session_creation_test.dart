import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_exchange/main.dart';
import 'package:language_exchange/models/exchange_session.dart';
import 'package:language_exchange/screens/session_form_screen.dart';
import 'package:language_exchange/tabs/sessions_tab.dart';

const createKey = ValueKey('create-session');
const saveKey = ValueKey('save-session');

List<ExchangeSession> shellSessions(WidgetTester tester) {
  return tester
      .widget<SessionsTab>(
        find.byWidgetPredicate(
          (widget) => widget is SessionsTab && !widget.favouritesOnly,
        ),
      )
      .sessions;
}

Finder formScrollable() {
  final list = find.descendant(
    of: find.byType(SessionFormScreen),
    matching: find.byType(ListView),
  );
  return find
      .descendant(
        of: list,
        matching: find.byType(Scrollable),
      )
      .first;
}

Future<void> openNew(WidgetTester tester) async {
  await tester.tap(find.byKey(createKey));
  await tester.pumpAndSettle();
  expect(find.text('New session'), findsOneWidget);
  expect(find.byType(NavigationBar), findsNothing);
}

void main() {
  testWidgets('FAB opens named form and cancel preserves shell data', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    final before = shellSessions(tester);

    await openNew(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(identical(shellSessions(tester), before), isTrue);
    expect(shellSessions(tester), hasLength(12));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      tester.widget<FloatingActionButton>(find.byKey(createKey)).onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('New Save adds one immutable session to shell data', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    final before = shellSessions(tester);

    await openNew(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Student language meeting',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    final place = find.widgetWithText(TextFormField, 'Meeting place');
    await tester.scrollUntilVisible(
      place,
      150,
      scrollable: formScrollable(),
    );
    await tester.enterText(place, 'Library room 204');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(saveKey),
      250,
      scrollable: formScrollable(),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(saveKey));
    await tester.pumpAndSettle();

    final after = shellSessions(tester);
    expect(before, hasLength(12));
    expect(after, hasLength(13));
    final created = after.singleWhere(
      (session) => session.title == 'Student language meeting',
    );
    expect(created.id, isNotEmpty);
    expect(created.place, 'Library room 204');
    expect(created.participants, isEmpty);
    expect(created.favourite, isFalse);
    expect(
      () => created.participants.add('Unexpected'),
      throwsUnsupportedError,
    );
    expect(find.byType(SessionFormScreen), findsNothing);
    expect(find.text('Session created'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('FAB is available on Favourites but hidden on Profile', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favourites'));
    await tester.pumpAndSettle();
    expect(find.byKey(createKey), findsOneWidget);
    await openNew(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byKey(createKey), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
