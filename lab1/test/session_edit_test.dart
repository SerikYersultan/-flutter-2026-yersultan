import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_exchange/data/seed_sessions.dart';
import 'package:language_exchange/models/exchange_session.dart';
import 'package:language_exchange/models/profile.dart';
import 'package:language_exchange/routes.dart';
import 'package:language_exchange/screens/session_detail_screen.dart';
import 'package:language_exchange/screens/session_form_screen.dart';
import 'package:language_exchange/widgets/session_header.dart';

Future<void> openEdit(
  WidgetTester tester, {
  required ExchangeSession session,
  required ValueChanged<ExchangeSession> onChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SessionDetailScreen(
        arguments: DetailArguments(
          session: session,
          profile: const Profile.empty(),
          onChanged: onChanged,
          onRequestProfile: () {},
        ),
      ),
      onGenerateRoute: (settings) {
        expect(settings.name, Routes.form);
        final arguments = settings.arguments;
        expect(arguments, isA<FormArguments>());
        if (arguments is! FormArguments) {
          return null;
        }
        expect(identical(arguments.session, session), isTrue);
        return MaterialPageRoute<ExchangeSession>(
          settings: settings,
          builder: (context) => SessionFormScreen(
            session: arguments.session,
          ),
        );
      },
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('session-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Edit'));
  await tester.pumpAndSettle();
  expect(find.text('Edit session'), findsOneWidget);
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

void main() {
  testWidgets('Edit Save updates callback and the open detail', (tester) async {
    final original = createSeedSessions().first;
    final changes = <ExchangeSession>[];
    await openEdit(
      tester,
      session: original,
      onChanged: changes.add,
    );

    final title = find.widgetWithText(TextFormField, 'Title');
    final controller = tester.widget<TextFormField>(title).controller;
    expect(controller?.text, original.title);
    await tester.enterText(title, 'Edited language meeting');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    final save = find.byKey(const ValueKey('save-session'));
    await tester.scrollUntilVisible(
      save,
      250,
      scrollable: formScrollable(),
    );
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(changes, hasLength(1));
    final updated = changes.single;
    expect(updated.title, 'Edited language meeting');
    expect(updated.id, original.id);
    expect(updated.participants, original.participants);
    expect(updated.favourite, original.favourite);
    expect(original.title, isNot(updated.title));
    expect(find.byType(SessionFormScreen), findsNothing);
    expect(
      tester.widget<SessionHeader>(find.byType(SessionHeader)).session,
      same(updated),
    );
    expect(find.text('Session updated'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('Edit cancel leaves callback and detail unchanged',
      (tester) async {
    final original = createSeedSessions().first;
    final changes = <ExchangeSession>[];
    await openEdit(
      tester,
      session: original,
      onChanged: changes.add,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(changes, isEmpty);
    expect(
      tester.widget<SessionHeader>(find.byType(SessionHeader)).session,
      same(original),
    );
    expect(find.byType(SessionFormScreen), findsNothing);

    await tester.tap(find.byKey(const ValueKey('session-menu')));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
