import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_exchange/models/countdown.dart';
import 'package:language_exchange/widgets/session_countdown.dart';

void main() {
  final startsAt = DateTime(2026, 10, 20, 10);

  test('before the start returns Upcoming with remaining time', () {
    final result = countdownAt(
      startsAt: startsAt,
      now: startsAt.subtract(const Duration(minutes: 30)),
    );

    expect(result, isA<Upcoming>());
    expect(countdownText(result), 'Starts in 30 min');
  });

  test('exact start and the first hour return Started', () {
    final atStart = countdownAt(startsAt: startsAt, now: startsAt);
    final later = countdownAt(
      startsAt: startsAt,
      now: startsAt.add(const Duration(minutes: 59)),
    );

    expect(atStart, isA<Started>());
    expect(countdownText(atStart), 'Started less than 1 minute ago');
    expect(countdownText(later), 'Started 59 min ago');
  });

  test('exact end and later return Ended', () {
    for (final elapsed in [
      const Duration(hours: 1),
      const Duration(days: 1),
    ]) {
      final result = countdownAt(
        startsAt: startsAt,
        now: startsAt.add(elapsed),
      );
      expect(result, isA<Ended>());
      expect(countdownText(result), 'Ended');
    }
  });

  test('duration is configurable and must be positive', () {
    final result = countdownAt(
      startsAt: startsAt,
      now: startsAt.add(const Duration(minutes: 90)),
      sessionDuration: const Duration(hours: 2),
    );
    expect(countdownText(result), 'Started 1h 30m ago');

    expect(
      () => countdownAt(
        startsAt: startsAt,
        now: startsAt,
        sessionDuration: Duration.zero,
      ),
      throwsArgumentError,
    );
  });

  test('upcoming formatting handles days and sub-minute intervals', () {
    expect(
      countdownText(const Upcoming(Duration(days: 2, hours: 3))),
      'Starts in 2d 3h',
    );
    expect(
      countdownText(const Upcoming(Duration(seconds: 30))),
      'Starts in less than 1 minute',
    );
  });

  testWidgets('countdown cancels its timer when removed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SessionCountdown(
            startsAt: DateTime.now().add(const Duration(days: 2)),
          ),
        ),
      ),
    );

    expect(find.byType(SessionCountdown), findsOneWidget);
    await tester.pump(const Duration(minutes: 1));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(minutes: 2));
    expect(tester.takeException(), isNull);
  });
}
