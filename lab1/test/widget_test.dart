import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_exchange/main.dart';

void main() {
  testWidgets('shows the Language Exchange welcome screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Language Exchange'), findsOneWidget);
    expect(find.text('Meet. Speak. Connect.'), findsOneWidget);
    expect(
      find.text('Conversation sessions for the KBTU community.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.forum_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
