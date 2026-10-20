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
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    _session = widget.arguments.session;
  }

  void _updateSession(ExchangeSession updated) {
    widget.arguments.onChanged(updated);
    setState(() {
      _session = updated;
    });
  }

  void _toggleFavourite() {
    _updateSession(_session.copyWith(favourite: !_session.favourite));
  }

  void _openProfile() {
    final requestProfile = widget.arguments.onRequestProfile;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.pop(context);
    requestProfile();
  }

  Future<void> _participate() async {
    if (_confirming) {
      return;
    }

    final name = widget.arguments.profile.name.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Save your name in Profile before joining.'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: _openProfile,
          ),
        ),
      );
      return;
    }

    if (_session.contains(name)) {
      final remaining = _session.participants
          .where((participant) => participant != name)
          .toList();
      _updateSession(_session.copyWith(participants: remaining));
      return;
    }

    if (_session.isFull || _session.isPast) {
      return;
    }

    setState(() {
      _confirming = true;
    });

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Join this session?'),
        content: Text('Add $name to "${_session.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Join'),
          ),
        ],
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _confirming = false;
    });

    if (confirmed != true ||
        _session.isFull ||
        _session.isPast ||
        _session.contains(name)) {
      return;
    }

    _updateSession(
      _session.copyWith(
        participants: [..._session.participants, name],
      ),
    );
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

    final profileName = widget.arguments.profile.name.trim();
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
    final name = widget.arguments.profile.name.trim();
    final isMember = name.isNotEmpty && _session.contains(name);
    final unavailable = !isMember && (_session.isFull || _session.isPast);
    final actionLabel = isMember
        ? 'Leave'
        : _session.isPast
            ? 'Session started'
            : _session.isFull
                ? 'Session full'
                : 'Join';

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
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildAbout(context),
                  _buildParticipants(context),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const ValueKey('participation-action'),
                    onPressed: _confirming || unavailable ? null : _participate,
                    icon: Icon(
                      isMember ? Icons.person_remove : Icons.person_add,
                    ),
                    label: Text(actionLabel),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
