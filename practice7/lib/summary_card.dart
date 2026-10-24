import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birthDate,
  });

  final String name;
  final String email;
  final String group;
  final String birthDate;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ListTile(
        leading: const Icon(Icons.person_outline),
        title: const Text('Name'),
        subtitle: Text(name),
      ),
      ListTile(
        leading: const Icon(Icons.email_outlined),
        title: const Text('Email'),
        subtitle: Text(email),
      ),
      ListTile(
        leading: const Icon(Icons.groups_outlined),
        title: const Text('Group'),
        subtitle: Text(group),
      ),
      ListTile(
        leading: const Icon(Icons.calendar_month),
        title: const Text('Date of birth'),
        subtitle: Text(birthDate),
      ),
    ];

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 600) {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 4,
                children: tiles,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: tiles,
            );
          },
        ),
      ),
    );
  }
}
