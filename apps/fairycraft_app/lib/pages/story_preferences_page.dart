import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StoryPreferencesPage extends StatelessWidget {
  const StoryPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Story preferences')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Preferences are configured during story setup.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/setup'),
              child: const Text('Open setup'),
            ),
          ],
        ),
      ),
    );
  }
}
