import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('UID: ${auth.user?.uid ?? '-'}'),
            const SizedBox(height: 8),
            Text('Email: ${auth.user?.email ?? 'N/A'}'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/change-password'),
              child: const Text('Change password'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.go('/provider-link'),
              child: const Text('Provider link'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                await context.read<AuthController>().signOut();
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
