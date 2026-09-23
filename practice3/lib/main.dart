import 'package:flutter/material.dart';

import 'data.dart';
import 'profile_header.dart';
import 'info_row.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My profile',
      home: Scaffold(
        appBar: AppBar(title: const Text('My profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ProfileHeader(name: myName, university: myUniversity),
                const SizedBox(height: 24),
                for (final f in facts) InfoRow(label: f.label, value: f.value),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
