import 'package:flutter/material.dart';

import '../data/seed_sessions.dart';
import '../models/exchange_session.dart';
import '../models/profile.dart';
import '../tabs/sessions_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late List<ExchangeSession> _sessions;
  final Profile _profile = const Profile.empty();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _sessions = createSeedSessions();
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  void _toggleFavourite(ExchangeSession selected) {
    final updated = [
      for (final session in _sessions)
        if (session.id == selected.id)
          session.copyWith(favourite: !session.favourite)
        else
          session,
    ];

    setState(() {
      _sessions = updated;
    });
  }

  void _openSession(ExchangeSession session) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('The detail screen will be added in the next stage.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final membershipCount = _profile.name.trim().isEmpty
        ? 0
        : _sessions.where((session) => session.contains(_profile.name)).length;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Exchange'),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          SessionsTab(
            sessions: _sessions,
            onOpen: _openSession,
            onFavourite: _toggleFavourite,
          ),
          SessionsTab(
            sessions: _sessions,
            favouritesOnly: true,
            onOpen: _openSession,
            onFavourite: _toggleFavourite,
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    _profile.name.isEmpty ? 'Your profile' : _profile.name,
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _profile.group.isEmpty ? 'No group saved' : _profile.group,
                  ),
                  Text('You are on $membershipCount lists'),
                  const SizedBox(height: 12),
                  const Text('Profile editing will be added next.'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
