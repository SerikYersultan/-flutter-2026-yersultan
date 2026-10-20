import 'package:flutter/material.dart';

import '../models/exchange_session.dart';
import '../routes.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_header.dart';

class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({
    super.key,
    required this.arguments,
  });

  final DetailArguments arguments;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  late ExchangeSession _session;

  @override
  void initState() {
    super.initState();
    _session = widget.arguments.session;
  }

  void _toggleFavourite() {
    final updated = _session.copyWith(favourite: !_session.favourite);
    widget.arguments.onChanged(updated);
    setState(() {
      _session = updated;
    });
  }

  Widget _buildAbout(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (:taken, :free) = _session.places;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SessionHeader(session: _session),
        const SizedBox(height: 24),
        Text(
          _session.online ? 'Meeting link' : 'Meeting place',
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SelectableText(_session.place, style: textTheme.bodyLarge),
        const SizedBox(height: 16),
        Text(
          '$taken / ${_session.limit} participants · $free free places',
          style: textTheme.bodyLarge,
        ),
        if (_session.description case final description?) ...[
          const SizedBox(height: 24),
          Text('Description', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(description, style: textTheme.bodyLarge),
        ],
      ],
    );
  }

  Widget _buildParticipants(BuildContext context) {
    if (_session.participants.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        message: 'Nobody has joined this session yet.',
      );
    }

    final profileName = widget.arguments.profile.name;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _session.count,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final name = _session.participants[index];
        final isYou = profileName.isNotEmpty && name == profileName;

        return ListTile(
          selected: isYou,
          selectedTileColor: colorScheme.secondaryContainer,
          selectedColor: colorScheme.onSecondaryContainer,
          title: Text(
            name,
            style: isYou
                ? textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
                : textTheme.bodyLarge,
          ),
          trailing: isYou ? const Text('You') : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Session details'),
          actions: [
            IconButton(
              tooltip: _session.favourite
                  ? 'Remove from favourites'
                  : 'Add to favourites',
              onPressed: _toggleFavourite,
              icon: Icon(
                _session.favourite ? Icons.favorite : Icons.favorite_border,
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              const Tab(text: 'About'),
              Tab(text: 'Participants (${_session.count})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAbout(context),
            _buildParticipants(context),
          ],
        ),
      ),
    );
  }
}
