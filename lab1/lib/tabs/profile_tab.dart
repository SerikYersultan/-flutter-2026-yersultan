import 'package:flutter/material.dart';

import '../models/exchange_session.dart';
import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.sessions,
    required this.onSave,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final Profile profile;
  final List<ExchangeSession> sessions;
  final ValueChanged<Profile> onSave;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _groupController;
  final _nameFocus = FocusNode();
  final _groupFocus = FocusNode();

  static final _groupPattern = RegExp(
    r'^[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*$',
  );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _groupController = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.name != widget.profile.name) {
      _nameController.text = widget.profile.name;
    }
    if (oldWidget.profile.group != widget.profile.group) {
      _groupController.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _nameFocus.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final updated = widget.profile.copyWith(
      name: _nameController.text.trim(),
      group: _groupController.text.trim(),
    );
    _nameFocus.unfocus();
    _groupFocus.unfocus();
    widget.onSave(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final membershipCount = widget.sessions.fold<int>(
      0,
      (count, session) =>
          count +
          (widget.profile.name.trim().isNotEmpty &&
                  session.contains(widget.profile.name)
              ? 1
              : 0),
    );
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Your profile', style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('You are on $membershipCount lists'),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocus,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onTapOutside: (_) => _nameFocus.unfocus(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your name';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                _save();
                _groupFocus.requestFocus();
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _groupController,
              focusNode: _groupFocus,
              decoration: const InputDecoration(
                labelText: 'Group',
                helperText: 'Letters and digits; for example B23-01',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              onTapOutside: (_) => _groupFocus.unfocus(),
              validator: (value) {
                final group = value?.trim() ?? '';
                if (!_groupPattern.hasMatch(group)) {
                  return 'Use letters/digits with optional hyphens';
                }
                return null;
              },
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _save,
              child: const Text('Save profile'),
            ),
            const SizedBox(height: 24),
            Text('Theme', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final mode in ThemeMode.values)
                  ChoiceChip(
                    label: Text(
                      switch (mode) {
                        ThemeMode.system => 'System',
                        ThemeMode.light => 'Light',
                        ThemeMode.dark => 'Dark',
                      },
                    ),
                    selected: widget.themeMode == mode,
                    onSelected: (_) => widget.onThemeChanged(mode),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
