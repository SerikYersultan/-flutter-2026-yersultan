import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_list/add_book_screen.dart';
import 'package:reading_list/main.dart';

void main() {
  testWidgets('Empty form shows three errors, with no year error', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddBookScreen()));

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Title is too short'), findsOneWidget);
    expect(find.text('Enter an author'), findsOneWidget);
    expect(find.text('A whole number above 0'), findsOneWidget);
    expect(find.textContaining('Enter a year from'), findsNothing);
    expect(find.byType(AddBookScreen), findsOneWidget);
  });

  testWidgets('Invalid pages and year prevent saving', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddBookScreen()));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Example book');
    await tester.enterText(fields.at(1), 'Example author');
    await tester.enterText(fields.at(2), 'abc');
    await tester.enterText(fields.at(3), '1449');

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Save'));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('A whole number above 0'), findsOneWidget);
    expect(find.textContaining('Enter a year from'), findsOneWidget);
    expect(find.byType(AddBookScreen), findsOneWidget);
  });

  testWidgets('Book with an empty year is added and has Year unknown', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'New book');
    await tester.enterText(fields.at(1), 'New author');
    await tester.enterText(fields.at(2), '100');

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Save'));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.byType(AddBookScreen), findsNothing);
    expect(find.text('Reading list (6)'), findsOneWidget);
    expect(find.text('1320'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('New book'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('New book'));
    await tester.pumpAndSettle();

    expect(find.text('Year unknown'), findsOneWidget);
    expect(find.text('Mark as read'), findsOneWidget);
  });

  testWidgets('Back from the form adds nothing', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(find.text('1220'), findsOneWidget);
  });
}
