import 'package:flutter/material.dart';

import '../models/exchange_session.dart';
import '../utils/format.dart';
import 'session_countdown.dart';

class SessionHeader extends StatelessWidget {
  const SessionHeader({
    super.key,
    required this.session,
  });

  final ExchangeSession session;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 208,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/session_header.png',
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
                Center(
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: colorScheme.surface,
                    child: Icon(
                      session.language.icon,
                      size: 32,
                      color: session.language.color(colorScheme),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Chip(
                    avatar: Icon(
                      session.language.icon,
                      color: session.language.color(colorScheme),
                    ),
                    label: Text(session.language.label),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: SessionCountdown(startsAt: session.when),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(session.title, style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          formatDateTime(session.when),
          style: textTheme.bodyLarge,
        ),
      ],
    );
  }
}
