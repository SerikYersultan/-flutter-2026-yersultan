import 'package:flutter_test/flutter_test.dart';
import 'package:language_exchange/data/seed_sessions.dart';
import 'package:language_exchange/models/exchange_language.dart';

void main() {
  final reference = DateTime(2026, 10, 20, 10);

  test('seed contains twelve items with unique nonempty identifiers', () {
    final seed = createSeedSessions(today: reference);

    expect(seed, hasLength(12));
    expect(seed.every((item) => item.id.isNotEmpty), isTrue);
    expect(seed.map((item) => item.id).toSet(), hasLength(12));
  });

  test('seed contains every mandatory edge case', () {
    final seed = createSeedSessions(today: reference);

    expect(seed.any((item) => item.title.length == 60), isTrue);
    expect(seed.any((item) => item.isFull), isTrue);
    expect(seed.any((item) => item.when.isBefore(reference)), isTrue);
    expect(seed.any((item) => item.online), isTrue);
    expect(seed.any((item) => item.description == null), isTrue);
  });

  test('seed values satisfy the basic data constraints', () {
    final seed = createSeedSessions(today: reference);

    for (final item in seed) {
      expect(item.title.length, inInclusiveRange(3, 60));
      expect(item.limit, inInclusiveRange(1, 500));
      expect(item.count, lessThanOrEqualTo(item.limit));
      expect(item.place.trim(), isNotEmpty);
      expect(item.participants.every((name) => name.isNotEmpty), isTrue);
      expect(item.participants.toSet().length, item.count);

      if (item.online) {
        expect(item.place, contains('://'));
      }
    }

    expect(
      seed.map((item) => item.language).toSet(),
      containsAll(ExchangeLanguage.values),
    );
  });

  test('dates shift with the supplied day, keeping local meeting times', () {
    final first = createSeedSessions(today: reference);
    final second = createSeedSessions(
      today: DateTime(2026, 11, 20, 22),
    );

    for (var index = 0; index < first.length; index++) {
      final a = first[index];
      final b = second[index];

      expect(b.id, a.id);
      expect(
        b.when,
        DateTime(
          a.when.year,
          a.when.month + 1,
          a.when.day,
          a.when.hour,
          a.when.minute,
        ),
      );
    }
  });

  test('recreating seed restores initial values with independent lists', () {
    final first = createSeedSessions(today: reference);
    final second = createSeedSessions(today: reference);

    first[0] = first[0].copyWith(favourite: false);
    first.removeLast();

    expect(first, hasLength(11));
    expect(second, hasLength(12));
    expect(second[0].favourite, isTrue);
    expect(
      () => second[0].participants.add('New participant'),
      throwsUnsupportedError,
    );
  });
}
