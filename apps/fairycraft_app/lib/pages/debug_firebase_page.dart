import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../firebase/firebase_bootstrap.dart';

class DebugFirebasePage extends StatelessWidget {
  const DebugFirebasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bootstrap = context.read<FirebaseBootstrap>();
    final authService = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Firebase debug')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Firebase ready: ${bootstrap.firebaseReady}'),
            Text('AppCheck attempted: ${bootstrap.appCheckAttempted}'),
            Text('Bootstrap error: ${bootstrap.error ?? '-'}'),
            Text('Auth service: ${authService.runtimeType}'),
          ],
        ),
      ),
    );
  }
}
