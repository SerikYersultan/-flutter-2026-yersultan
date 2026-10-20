import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_exchange/data/seed_sessions.dart';
import 'package:language_exchange/main.dart';
import 'package:language_exchange/models/exchange_session.dart';
import 'package:language_exchange/models/profile.dart';
import 'package:language_exchange/routes.dart';
import 'package:language_exchange/screens/session_detail_screen.dart';
import 'package:language_exchange/widgets/session_card.dart';

const actionKey = ValueKey('participation-action');

ExchangeSession availableSession() {
  return createSeedSessions().first.copyWith(
    when: DateTime.now().add(const Duration(days: 1)),
    limit: 3,
    participants: const ['Aruzhan'],
  );
}

Future<void> showDetail(
  WidgetTester tester, {
  required ExchangeSession session,
  required ValueChanged<ExchangeSession> onChanged,
  Profile profile = const Profile(name: 'Yersultan', group: 'B23-01'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SessionDetailScreen(
        arguments: DetailArguments(
          session: session,
          profile: profile,
          onChanged: onChanged,
          onRequestProfile: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> removeDetail(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(minutes: 2));
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('Join cancellation does not change the session', (tester) async {
    var updates = 0;
    await showDetail(
      tester,
      session: availableSession(),
      onChanged: (session) {
        updates++;
      },
    );

    await tester.tap(find.byKey(actionKey));
    await tester.pumpAndSettle();
    expect(find.text('Join this session?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(updates, 0);
    expect(find.text('Participants (1)'), findsOneWidget);
    expect(find.text('Leave'), findsNothing);
    await removeDetail(tester);
  });

  testWidgets('confirmed Join updates names, tab count and opposite action', (
    tester,
  ) async {
    final updates = <ExchangeSession>[];
    final original = availableSession();
    await showDetail(
      tester,
      session: original,
      onChanged: updates.add,
    );

    await tester.tap(find.byKey(actionKey));
    await tester.pumpAndSettle();

    final confirmJoin = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, 'Join'),
    );
    expect(confirmJoin, findsOneWidget);
    await tester.tap(confirmJoin);
    await tester.pumpAndSettle();

    expect(updates, hasLength(1));
    expect(updates.single.participants, ['Aruzhan', 'Yersultan']);
    expect(original.participants, ['Aruzhan']);
    expect(find.text('Participants (2)'), findsOneWidget);
    expect(find.text('Leave'), findsOneWidget);

    await tester.tap(find.text('Participants (2)'));
    await tester.pumpAndSettle();
    expect(find.text('You'), findsOneWidget);
    await removeDetail(tester);
  });

  testWidgets('member can leave a full past session', (tester) async {
    final updates = <ExchangeSession>[];
    await showDetail(
      tester,
      session: availableSession().copyWith(
        when: DateTime.now().subtract(const Duration(days: 1)),
        limit: 2,
        participants: const ['Aruzhan', 'Yersultan'],
      ),
      onChanged: updates.add,
    );

    final button = tester.widget<FilledButton>(find.byKey(actionKey));
    expect(button.onPressed, isNotNull);
    expect(find.text('Leave'), findsOneWidget);

    await tester.tap(find.byKey(actionKey));
    await tester.pumpAndSettle();

    expect(updates, hasLength(1));
    expect(updates.single.participants, ['Aruzhan']);
    expect(find.text('Participants (1)'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byKey(actionKey)).onPressed,
      isNull,
    );
    await removeDetail(tester);
  });

  for (final full in [true, false]) {
    testWidgets(
      full ? 'full session disables Join' : 'past session disables Join',
      (tester) async {
        var updates = 0;
        final session = availableSession().copyWith(
          limit: full ? 1 : 3,
          when: full
              ? DateTime.now().add(const Duration(days: 1))
              : DateTime.now().subtract(const Duration(days: 1)),
        );
        await showDetail(
          tester,
          session: session,
          onChanged: (session) {
            updates++;
          },
        );

        expect(
          tester.widget<FilledButton>(find.byKey(actionKey)).onPressed,
          isNull,
        );
        expect(updates, 0);
        await removeDetail(tester);
      },
    );
  }

  testWidgets('empty profile SnackBar returns to the shell Profile tab', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final session = tester
        .widget<SessionCard>(
          find.byType(SessionCard).first,
        )
        .session;

    await tester.tap(find.text(session.title).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(actionKey));
    await tester.pumpAndSettle();

    expect(
      find.text('Save your name in Profile before joining.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(SessionDetailScreen), findsNothing);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      2,
    );
    expect(find.text('Your profile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
