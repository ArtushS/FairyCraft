import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../l10n/l10n.dart';

class ProviderLinkPage extends StatefulWidget {
  const ProviderLinkPage({super.key});

  @override
  State<ProviderLinkPage> createState() => _ProviderLinkPageState();
}

class _ProviderLinkPageState extends State<ProviderLinkPage> {
  String? _message;

  Future<void> _link(String provider) async {
    setState(() {
      _message = null;
    });

    try {
      await context.read<AuthController>().linkProvider(provider);
      setState(() {
        _message = context.l10n.authProviderLinkRequested(provider);
      });
    } catch (error) {
      setState(() {
        _message = context.l10n.authProviderLinkFailed(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.authProviderLinkTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FilledButton(
              onPressed: () => _link('google.com'),
              child: Text(l10n.authLinkGoogleStub),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _link('facebook.com'),
              child: Text(l10n.authLinkFacebookStub),
            ),
            if (_message != null) ...<Widget>[
              const SizedBox(height: 16),
              Text(_message!),
            ],
          ],
        ),
      ),
    );
  }
}
