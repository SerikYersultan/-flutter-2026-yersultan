import 'package:flutter/material.dart';

import '../models/exchange_language.dart';
import '../models/exchange_session.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_card.dart';

class SessionsTab extends StatefulWidget {
  const SessionsTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onFavourite,
    this.favouritesOnly = false,
  });

  final List<ExchangeSession> sessions;
  final ValueChanged<ExchangeSession> onOpen;
  final ValueChanged<ExchangeSession> onFavourite;
  final bool favouritesOnly;

  @override
  State<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<SessionsTab> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  String _query = '';
  ExchangeLanguage? _language;
  bool _showPast = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final query = _query.trim().toLowerCase();

    final visible = widget.sessions.where((session) {
      return (!widget.favouritesOnly || session.favourite) &&
          (_language == null || session.language == _language) &&
          (_showPast || !session.when.isBefore(now)) &&
          session.title.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) => a.when.compareTo(b.when));

    final hasFavourites = widget.sessions.any(
      (session) => session.favourite,
    );
    final noFavourites = widget.favouritesOnly && !hasFavourites;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            textInputAction: TextInputAction.search,
            onTapOutside: (_) => _searchFocus.unfocus(),
            onSubmitted: (_) => _searchFocus.unfocus(),
            decoration: InputDecoration(
              labelText: 'Search sessions',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                    ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _language == null,
                onSelected: (_) {
                  setState(() {
                    _language = null;
                  });
                },
              ),
              ...ExchangeLanguage.values.map(
                (language) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    avatar: Icon(language.icon),
                    label: Text(language.label),
                    selected: _language == language,
                    onSelected: (_) {
                      setState(() {
                        _language = language;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              label: const Text('Include past sessions'),
              selected: _showPast,
              onSelected: (value) {
                setState(() {
                  _showPast = value;
                });
              },
            ),
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: noFavourites ? Icons.favorite_border : Icons.search_off,
                  message: noFavourites
                      ? 'No favourites yet. Tap a heart on the sessions list.'
                      : 'No sessions match your filters.',
                  buttonLabel: !noFavourites && _query.isNotEmpty
                      ? 'Clear search'
                      : null,
                  onAction:
                      !noFavourites && _query.isNotEmpty ? _clearSearch : null,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                  itemCount: visible.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final session = visible[index];
                    return SessionCard(
                      key: ValueKey(session.id),
                      session: session,
                      onTap: () => widget.onOpen(session),
                      onFavourite: () => widget.onFavourite(session),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
