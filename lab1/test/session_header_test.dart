import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_exchange/data/seed_sessions.dart';
import 'package:language_exchange/utils/format.dart';
import 'package:language_exchange/widgets/session_countdown.dart';
import 'package:language_exchange/widgets/session_header.dart';

void main() {
  testWidgets('header loads its asset and fits a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final session = createSeedSessions().first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SessionHeader(session: session),
          ),
        ),
      ),
    );

    // Allow the bundled image to finish decoding before checking errors.
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/images/session_header.png'),
        tester.element(find.byType(SessionHeader)),
      );
    });
    await tester.pump();

    expect(find.text(session.title), findsOneWidget);
    expect(find.text(session.language.label), findsOneWidget);
    expect(find.text(formatDateTime(session.when)), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(SessionCountdown), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Removing the header also disposes its countdown timer.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(minutes: 2));
    expect(tester.takeException(), isNull);
  });
}
