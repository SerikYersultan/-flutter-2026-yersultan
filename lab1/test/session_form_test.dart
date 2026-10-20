import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_exchange/data/seed_sessions.dart';
import 'package:language_exchange/models/exchange_session.dart';
import 'package:language_exchange/screens/session_form_screen.dart';

Future<void> openForm(
  WidgetTester tester, {
  ExchangeSession? session,
  required ValueChanged<ExchangeSession?> onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final result = await Navigator.push<ExchangeSession>(
                context,
                MaterialPageRoute<ExchangeSession>(
                  builder: (context) => SessionFormScreen(session: session),
                ),
              );
              if (!context.mounted) {
                return;
              }
              onResult(result);
            },
            child: const Text('Open form'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open form'));
  await tester.pumpAndSettle();
}

Finder formScrollable() {
  final list = find.descendant(
    of: find.byType(SessionFormScreen),
    matching: find.byType(ListView),
  );
  // The outer list's Scrollable precedes those inside its text fields.
  return find
      .descendant(
        of: list,
        matching: find.byType(Scrollable),
      )
      .first;
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> saveForm(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();

  final save = find.byKey(const ValueKey('save-session'));
  expect(formScrollable(), findsOneWidget);
  await tester.scrollUntilVisible(
    save,
    250,
    scrollable: formScrollable(),
  );
  await tester.pumpAndSettle();
  expect(save, findsOneWidget);
  await tester.tap(save);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('edit returns updated item and preserves identity and names', (
    tester,
  ) async {
    final original = createSeedSessions().first;
    ExchangeSession? result;
    await openForm(
      tester,
      session: original,
      onResult: (value) => result = value,
    );

    expect(find.text('Edit session'), findsOneWidget);
    await tester.enterText(field('Title'), 'Updated language meeting');
    await saveForm(tester);

    expect(result?.title, 'Updated language meeting');
    expect(result?.id, original.id);
    expect(result?.participants, original.participants);
    expect(result?.favourite, original.favourite);
    expect(original.title, isNot('Updated language meeting'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('new form validates required fields', (tester) async {
    var returned = false;
    await openForm(
      tester,
      onResult: (value) => returned = true,
    );
    await saveForm(tester);

    expect(returned, isFalse);
    expect(find.byType(SessionFormScreen), findsOneWidget);

    await tester.scrollUntilVisible(
      field('Title'),
      -250,
      scrollable: formScrollable(),
    );
    await tester.pumpAndSettle();
    expect(find.text('Use 3–60 characters'), findsOneWidget);

    await tester.scrollUntilVisible(
      field('Meeting place'),
      150,
      scrollable: formScrollable(),
    );
    await tester.pumpAndSettle();
    expect(find.text('Enter a meeting place'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clean back returns null', (tester) async {
    var returned = false;
    ExchangeSession? result;
    await openForm(
      tester,
      onResult: (value) {
        returned = true;
        result = value;
      },
    );
    Navigator.pop(tester.element(find.byType(SessionFormScreen)));
    await tester.pumpAndSettle();

    expect(returned, isTrue);
    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });
}
