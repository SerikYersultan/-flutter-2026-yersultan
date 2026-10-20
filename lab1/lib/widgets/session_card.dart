import 'package:flutter/material.dart';

import '../models/exchange_session.dart';
import '../utils/format.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onFavourite,
  });

  final ExchangeSession session;
  final VoidCallback onTap;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (:taken, :free) = session.places;
    final categoryColor = session.language.color(scheme);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 64,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: scheme.surfaceContainerHighest,
                        child: Icon(
                          session.language.icon,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    if (free <= 5)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: session.isFull
                                  ? scheme.errorContainer
                                  : scheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              session.isFull ? 'FULL' : '$free left',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: session.isFull
                                    ? scheme.onErrorContainer
                                    : scheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDateTime(session.when),
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      session.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '$taken / ${session.limit} joined',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: session.favourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onFavourite,
                icon: Icon(
                  session.favourite ? Icons.favorite : Icons.favorite_border,
                  color: session.favourite ? scheme.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
