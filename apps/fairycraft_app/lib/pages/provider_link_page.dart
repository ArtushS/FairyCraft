import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';

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
        _message = '$provider link request completed (stub for now).';
      });
    } catch (error) {
      setState(() {
        _message = 'Failed: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider link')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FilledButton(
              onPressed: () => _link('google.com'),
              child: const Text('Link Google (stub)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _link('facebook.com'),
              child: const Text('Link Facebook (stub)'),
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
