import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_list/main.dart';
import 'package:reading_list/models/book.dart';
import 'package:reading_list/widgets/book_tile.dart';

void main() {
  testWidgets('Filters update the list count', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(3));
    expect(find.text('1220'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Unread'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (4)'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Read'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (1)'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (5)'), findsOneWidget);
  });

  testWidgets('Checking an unread book removes it from that filter', (
    tester,
  ) async {
    final originalReadFlags = seed.map((book) => book.read).toList();

    addTearDown(() {
      for (var i = 0; i < seed.length; i++) {
        seed[i].read = originalReadFlags[i];
      }
    });

    await tester.pumpWidget(const MyApp());
    await tester.tap(find.widgetWithText(ChoiceChip, 'Unread'));
    await tester.pumpAndSettle();

    expect(find.text('Reading list (4)'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect(find.text('Reading list (3)'), findsOneWidget);
    expect(find.text('Null Safety for Humans'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Read'));
    await tester.pumpAndSettle();

    expect(find.text('Reading list (2)'), findsOneWidget);
    expect(find.text('Null Safety for Humans'), findsOneWidget);
  });

  testWidgets('Long title has two-line ellipsis without layout errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: BookTile(book: seed.last, onToggle: () {}),
            ),
          ),
        ),
      ),
    );

    final title = tester.widget<Text>(find.text(seed.last.title));

    expect(title.maxLines, 2);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(find.byKey(const ValueKey('unread-dot')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
