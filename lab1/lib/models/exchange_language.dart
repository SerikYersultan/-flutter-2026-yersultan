import 'package:flutter/material.dart';

enum ExchangeLanguage {
  english('English', Icons.language),
  kazakh('Kazakh', Icons.record_voice_over),
  russian('Russian', Icons.forum),
  french('French', Icons.chat_bubble_outline),
  korean('Korean', Icons.translate);

  const ExchangeLanguage(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme colorScheme) => switch (this) {
        ExchangeLanguage.english => colorScheme.primary,
        ExchangeLanguage.kazakh => colorScheme.secondary,
        ExchangeLanguage.russian => colorScheme.tertiary,
        ExchangeLanguage.french => colorScheme.error,
        ExchangeLanguage.korean => colorScheme.onSurfaceVariant,
      };
}
