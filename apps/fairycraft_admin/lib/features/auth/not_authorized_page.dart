import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/admin_auth_controller.dart';

class NotAuthorizedPage extends StatelessWidget {
  const NotAuthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthController>();
    final uid = auth.currentUid ?? '-';
    final email = auth.currentEmail ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Not Authorized')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'This account is not authorized for admin access.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text('UID: $uid'),
                  Text('Email: $email'),
                  const SizedBox(height: 16),
                  const Text(
                    'Required claim: admin=true',
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<AdminAuthController>().signOut(),
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
