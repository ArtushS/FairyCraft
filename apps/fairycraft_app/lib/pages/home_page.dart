import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FairyCraft')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text('Choose what you want to do:'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go('/setup'),
            child: const Text('Start new story'),
          ),
          OutlinedButton(
            onPressed: () => context.go('/story-preferences'),
            child: const Text('Story preferences'),
          ),
          OutlinedButton(
            onPressed: () => context.go('/my-stories'),
            child: const Text('My stories'),
          ),
          OutlinedButton(
            onPressed: () => context.go('/settings'),
            child: const Text('Settings'),
          ),
          OutlinedButton(
            onPressed: () => context.go('/voice-help'),
            child: const Text('Voice help'),
          ),
          OutlinedButton(
            onPressed: () => context.go('/account'),
            child: const Text('Account'),
          ),
          OutlinedButton(
            onPressed: () => context.go('/debug-firebase'),
            child: const Text('Debug Firebase'),
          ),
        ],
      ),
    );
  }
}
