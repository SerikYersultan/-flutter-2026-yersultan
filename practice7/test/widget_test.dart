import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signup_form/main.dart';

void main() {
  testWidgets('Level 4 shows extra inputs and requires agreement', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    final agreement = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile),
    );
    expect(agreement.value, isFalse);
  });
}
