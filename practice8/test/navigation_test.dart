import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_list/detail_screen.dart';
import 'package:reading_list/main.dart';
import 'package:reading_list/models/book.dart';

void main() {
  testWidgets('Back from details leaves the list unchanged', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text(seed.first.title));
    await tester.pumpAndSettle();

    expect(find.byType(DetailScreen), findsOneWidget);
    expect(find.text('288 pp.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(find.text(seed.first.title), findsOneWidget);
    expect(seed.first.read, isTrue);
  });

  testWidgets('Detail toggle returns an action to the list', (tester) async {
    final originalRead = seed.first.read;
    addTearDown(() {
      seed.first.read = originalRead;
    });

    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text(seed.first.title));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark as unread'));
    await tester.pumpAndSettle();

    expect(find.byType(DetailScreen), findsNothing);
    expect(seed.first.read, isFalse);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Unread'));
    await tester.pumpAndSettle();

    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(find.text(seed.first.title), findsOneWidget);
  });

  testWidgets('Delete requires confirmation and removes the book', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text(seed.first.title));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(DetailScreen), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextButton, 'Delete'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DetailScreen), findsNothing);
    expect(find.text('Reading list (4)'), findsOneWidget);
    expect(find.text(seed.first.title), findsNothing);
    expect(find.text('932'), findsOneWidget);
  });

  testWidgets('Missing year is shown as Year unknown', (tester) async {
    await tester.pumpWidget(MaterialApp(home: DetailScreen(book: seed[2])));

    expect(find.text('Year unknown'), findsOneWidget);
  });
}
