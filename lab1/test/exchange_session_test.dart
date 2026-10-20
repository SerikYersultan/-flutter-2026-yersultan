import 'package:flutter_test/flutter_test.dart';
import 'package:language_exchange/models/exchange_language.dart';
import 'package:language_exchange/models/exchange_session.dart';

ExchangeSession makeSession({
  List<String> participants = const ['Aruzhan'],
  int limit = 3,
  DateTime? when,
}) {
  return ExchangeSession(
    id: 'session-1',
    title: 'English conversation',
    language: ExchangeLanguage.english,
    when: when ?? DateTime.now().add(const Duration(days: 2)),
    limit: limit,
    participants: participants,
    online: false,
    place: 'KBTU library',
    description: 'Discuss books and university life.',
  );
}

void main() {
  group('ExchangeSession', () {
    test('derives count, free places and membership', () {
      final session = makeSession();

      expect(session.count, 1);
      expect(session.free, 2);
      expect(session.isFull, isFalse);
      expect(session.contains('Aruzhan'), isTrue);
      expect(session.contains('Yersultan'), isFalse);
    });

    test('places record can be destructured', () {
      final session = makeSession();
      final (:taken, :free) = session.places;

      expect(taken, 1);
      expect(free, 2);
    });

    test('full session has no free places', () {
      final session = makeSession(
        participants: ['Aruzhan', 'Yersultan', 'Dana'],
      );

      expect(session.count, 3);
      expect(session.free, 0);
      expect(session.isFull, isTrue);
    });

    test('free places never become negative', () {
      final session = makeSession(limit: 0);

      expect(session.free, 0);
      expect(session.isFull, isTrue);
    });

    test('constructor takes a defensive snapshot of participants', () {
      final source = ['Aruzhan'];
      final session = makeSession(participants: source);

      source.add('Dana');

      expect(session.participants, ['Aruzhan']);
      expect(
        () => session.participants.add('Yersultan'),
        throwsUnsupportedError,
      );
    });

    test('copyWith updates values without changing original', () {
      final original = makeSession();
      final names = ['Aruzhan', 'Yersultan'];
      final updated = original.copyWith(
        participants: names,
        favourite: true,
        online: true,
        place: 'https://example.org/meeting',
        language: ExchangeLanguage.kazakh,
      );

      names.clear();

      expect(original.count, 1);
      expect(original.favourite, isFalse);
      expect(original.online, isFalse);
      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.when, original.when);
      expect(updated.limit, original.limit);
      expect(updated.count, 2);
      expect(updated.favourite, isTrue);
      expect(updated.online, isTrue);
      expect(updated.language, ExchangeLanguage.kazakh);
      expect(updated.place, 'https://example.org/meeting');
    });

    test('description is preserved, replaced or explicitly cleared', () {
      final original = makeSession();

      expect(original.copyWith().description, original.description);
      expect(
        original.copyWith(description: 'New topic').description,
        'New topic',
      );
      expect(
        original.copyWith(clearDescription: true).description,
        isNull,
      );
      expect(
        original
            .copyWith(description: 'Ignored', clearDescription: true)
            .description,
        isNull,
      );
    });

    test('past and upcoming status is derived from date', () {
      final now = DateTime.now();

      expect(
        makeSession(when: now.subtract(const Duration(days: 2))).isPast,
        isTrue,
      );
      expect(
        makeSession(when: now.add(const Duration(days: 2))).isPast,
        isFalse,
      );
    });

    test('empty creates a new-session template', () {
      final session = ExchangeSession.empty();

      expect(session.id, isEmpty);
      expect(session.title, isEmpty);
      expect(session.place, isEmpty);
      expect(session.language, ExchangeLanguage.english);
      expect(session.limit, 10);
      expect(session.participants, isEmpty);
      expect(session.description, isNull);
      expect(session.online, isFalse);
      expect(session.favourite, isFalse);
      expect(session.isPast, isFalse);
    });
  });
}
