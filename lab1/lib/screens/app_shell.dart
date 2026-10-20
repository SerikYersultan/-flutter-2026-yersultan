import 'package:flutter/material.dart';

import '../data/seed_sessions.dart';
import '../models/exchange_session.dart';
import '../models/profile.dart';
import '../tabs/profile_tab.dart';
import '../tabs/sessions_tab.dart';
import '../widgets/theme_settings.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late List<ExchangeSession> _sessions;
  Profile _profile = const Profile.empty();
  int _selectedTab = 0;
  int _resetVersion = 0;

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

  void _saveProfile(Profile profile) {
    setState(() {
      _profile = profile;
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

  void _showAbout() {
    Navigator.pop(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('About Language Exchange'),
        content: const Text(
          'Find language practice meetings, save favourites and join '
          'other learners. All data stays in memory for this lab.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    Navigator.pop(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'Restore the twelve seed sessions and clear your profile?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) {
      return;
    }

    final restored = createSeedSessions();
    setState(() {
      _sessions = restored;
      _profile = const Profile.empty();
      _resetVersion++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data reset')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeSettings = ThemeSettings.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Language Exchange')),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                child: Text('Language Exchange'),
              ),
              ListTile(
                title: const Text('About'),
                trailing: const Icon(Icons.info_outline),
                onTap: _showAbout,
              ),
              ListTile(
                title: const Text('Reset data'),
                trailing: const Icon(Icons.restart_alt),
                onTap: _resetData,
              ),
            ],
          ),
        ),
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
          ProfileTab(
            key: ValueKey(_resetVersion),
            profile: _profile,
            sessions: _sessions,
            onSave: _saveProfile,
            themeMode: themeSettings.mode,
            onThemeChanged: themeSettings.onChanged,
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
