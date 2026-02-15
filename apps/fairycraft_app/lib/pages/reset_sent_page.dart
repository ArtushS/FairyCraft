import 'package:flutter/material.dart';

import '../app/nav.dart';
import '../l10n/l10n.dart';

class ResetSentPage extends StatelessWidget {
  const ResetSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.authResetSentTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l10n.authResetSentBody),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Nav.backOrLogin(context),
              child: Text(l10n.commonBackToLogin),
            ),
          ],
        ),
      ),
    );
  }
}
