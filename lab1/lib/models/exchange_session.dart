import 'exchange_language.dart';

class ExchangeSession {
  factory ExchangeSession({
    required String id,
    required String title,
    required ExchangeLanguage language,
    required DateTime when,
    required int limit,
    required List<String> participants,
    required bool online,
    required String place,
    String? description,
    bool favourite = false,
  }) {
    return ExchangeSession._(
      id: id,
      title: title,
      language: language,
      when: when,
      limit: limit,
      participants: List<String>.unmodifiable(participants),
      online: online,
      place: place,
      description: description,
      favourite: favourite,
    );
  }

  const ExchangeSession._({
    required this.id,
    required this.title,
    required this.language,
    required this.when,
    required this.limit,
    required this.participants,
    required this.online,
    required this.place,
    required this.description,
    required this.favourite,
  });

  factory ExchangeSession.empty() {
    return ExchangeSession(
      id: '',
      title: '',
      language: ExchangeLanguage.english,
      when: DateTime.now().add(const Duration(days: 1)),
      limit: 10,
      participants: const [],
      online: false,
      place: '',
    );
  }

  final String id;
  final String title;
  final ExchangeLanguage language;
  final DateTime when;
  final int limit;
  final List<String> participants;
  final bool online;
  final String place;
  final String? description;
  final bool favourite;

  int get count => participants.length;

  int get free => limit > count ? limit - count : 0;

  bool get isFull => count >= limit;

  bool get isPast => when.isBefore(DateTime.now());

  bool contains(String name) => participants.contains(name);

  ({int taken, int free}) get places => (taken: count, free: free);

  ExchangeSession copyWith({
    String? id,
    String? title,
    ExchangeLanguage? language,
    DateTime? when,
    int? limit,
    List<String>? participants,
    bool? online,
    String? place,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) {
    return ExchangeSession(
      id: id ?? this.id,
      title: title ?? this.title,
      language: language ?? this.language,
      when: when ?? this.when,
      limit: limit ?? this.limit,
      participants: participants ?? this.participants,
      online: online ?? this.online,
      place: place ?? this.place,
      description: clearDescription ? null : description ?? this.description,
      favourite: favourite ?? this.favourite,
    );
  }
}
