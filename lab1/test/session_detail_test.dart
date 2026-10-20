import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_exchange/data/seed_sessions.dart';
import 'package:language_exchange/main.dart';
import 'package:language_exchange/models/exchange_session.dart';
import 'package:language_exchange/models/profile.dart';
import 'package:language_exchange/routes.dart';
import 'package:language_exchange/screens/session_detail_screen.dart';
import 'package:language_exchange/widgets/session_card.dart';

void main() {
  testWidgets('card opens named detail above the navigation bar', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final card = tester.widget<SessionCard>(
      find.byType(SessionCard).first,
    );
    await tester.tap(find.text(card.session.title).first);
    await tester.pumpAndSettle();

    expect(find.byType(SessionDetailScreen), findsOneWidget);
    expect(find.text('Session details'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    final route = ModalRoute.of(
      tester.element(find.byType(SessionDetailScreen)),
    );
    expect(route?.settings.name, Routes.detail);

    Navigator.pop(
      tester.element(find.byType(SessionDetailScreen)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('favourite change reaches shell and survives returning', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final first = tester
        .widget<SessionCard>(
          find.byType(SessionCard).first,
        )
        .session;

    await tester.tap(find.text(first.title).first);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byTooltip(
        first.favourite ? 'Remove from favourites' : 'Add to favourites',
      ),
    );
    await tester.pump();

    Navigator.pop(
      tester.element(find.byType(SessionDetailScreen)),
    );
    await tester.pumpAndSettle();

    final updated = tester
        .widgetList<SessionCard>(
          find.byType(SessionCard),
        )
        .firstWhere((card) => card.session.id == first.id)
        .session;

    expect(updated.favourite, !first.favourite);
    expect(tester.takeException(), isNull);
  });

  testWidgets('participants highlight the saved profile as You', (
    tester,
  ) async {
    final session = createSeedSessions().first.copyWith(
      participants: const ['Aruzhan', 'Yersultan'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDetailScreen(
          arguments: DetailArguments(
            session: session,
            profile: const Profile(name: 'Yersultan', group: 'B23-01'),
            onChanged: (session) {},
            onRequestProfile: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Participants (2)'));
    await tester.pumpAndSettle();

    expect(find.text('Aruzhan'), findsOneWidget);
    expect(find.text('Yersultan'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);

    final selectedTile = tester.widget<ListTile>(
      find.ancestor(
        of: find.text('Yersultan'),
        matching: find.byType(ListTile),
      ),
    );
    expect(selectedTile.selected, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(minutes: 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('absent description and empty participants are supported', (
    tester,
  ) async {
    final ExchangeSession session = createSeedSessions().first.copyWith(
      participants: const [],
      clearDescription: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDetailScreen(
          arguments: DetailArguments(
            session: session,
            profile: const Profile.empty(),
            onChanged: (session) {},
            onRequestProfile: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Description'), findsNothing);
    await tester.tap(find.text('Participants (0)'));
    await tester.pumpAndSettle();
    expect(
      find.text('Nobody has joined this session yet.'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(minutes: 2));
    expect(tester.takeException(), isNull);
  });
}
