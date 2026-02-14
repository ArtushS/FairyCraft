import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResetSentPage extends StatelessWidget {
  const ResetSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset sent')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('If the email exists, reset instructions were sent.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/login'),
              child: const Text('Back to login'),
            ),
          ],
        ),
      ),
    );
  }
}
