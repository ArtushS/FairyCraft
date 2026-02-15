import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../firebase/firebase_bootstrap.dart';
import '../l10n/l10n.dart';

class DebugFirebasePage extends StatelessWidget {
  const DebugFirebasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bootstrap = context.read<FirebaseBootstrap>();
    final authService = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debugFirebaseTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.debugFirebaseReady(bootstrap.firebaseReady.toString())),
            Text(
              l10n.debugAppCheckAttempted(
                bootstrap.appCheckAttempted.toString(),
              ),
            ),
            Text(l10n.debugBootstrapError(bootstrap.error ?? '-')),
            Text(l10n.debugAuthService(authService.runtimeType.toString())),
          ],
        ),
      ),
    );
  }
}
