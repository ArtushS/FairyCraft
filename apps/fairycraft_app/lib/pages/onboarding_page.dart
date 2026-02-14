import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../settings/settings_controller.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to FairyCraft')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'FairyCraft helps children co-create safe, language-friendly stories with guided choices.',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                await context.read<SettingsController>().setOnboardingCompleted(true);
                if (context.mounted) {
                  context.go('/');
                }
              },
              child: const Text('Finish onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}
