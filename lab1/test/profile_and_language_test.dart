import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_exchange/models/exchange_language.dart';
import 'package:language_exchange/models/profile.dart';

void main() {
  group('Profile', () {
    test('empty constructor provides empty name and group', () {
      const profile = Profile.empty();

      expect(profile.name, isEmpty);
      expect(profile.group, isEmpty);
    });

    test('copyWith changes name and preserves group and original', () {
      const original = Profile(name: 'Yersultan', group: 'SE-01');

      final updated = original.copyWith(name: 'Aruzhan');

      expect(updated.name, 'Aruzhan');
      expect(updated.group, 'SE-01');
      expect(original.name, 'Yersultan');
      expect(original.group, 'SE-01');
    });

    test('copyWith changes group and preserves name', () {
      const original = Profile(name: 'Yersultan', group: 'SE-01');

      final updated = original.copyWith(group: 'SE-02');

      expect(updated.name, 'Yersultan');
      expect(updated.group, 'SE-02');
    });

    test('copyWith permits explicitly clearing both fields', () {
      const original = Profile(name: 'Yersultan', group: 'SE-01');

      final updated = original.copyWith(name: '', group: '');

      expect(updated.name, isEmpty);
      expect(updated.group, isEmpty);
    });

    test('copyWith without arguments preserves values', () {
      const original = Profile(name: 'Yersultan', group: 'SE-01');

      final updated = original.copyWith();

      expect(updated.name, original.name);
      expect(updated.group, original.group);
    });
  });

  group('ExchangeLanguage', () {
    test('provides at least five distinct labels and icons', () {
      expect(ExchangeLanguage.values.length, greaterThanOrEqualTo(5));

      final labels = ExchangeLanguage.values.map((value) => value.label);
      final icons = ExchangeLanguage.values.map((value) => value.icon);

      expect(labels.every((label) => label.isNotEmpty), isTrue);
      expect(labels.toSet().length, ExchangeLanguage.values.length);
      expect(icons.toSet().length, ExchangeLanguage.values.length);
    });

    test('each category returns its designated theme role', () {
      final scheme = ThemeData().colorScheme;

      expect(ExchangeLanguage.english.color(scheme), scheme.primary);
      expect(ExchangeLanguage.kazakh.color(scheme), scheme.secondary);
      expect(ExchangeLanguage.russian.color(scheme), scheme.tertiary);
      expect(ExchangeLanguage.french.color(scheme), scheme.error);
      expect(ExchangeLanguage.korean.color(scheme), scheme.onSurfaceVariant);
    });
  });
}
