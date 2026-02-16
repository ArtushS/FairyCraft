import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/admin_auth_controller.dart';
import '../../config/app_environment.dart';
import '../../firebase/firebase_bootstrap.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailPassword() async {
    setState(() {
      _submitting = true;
    });
    await context.read<AdminAuthController>().signInWithEmailPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (mounted) {
      setState(() {
        _submitting = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _submitting = true;
    });
    await context.read<AdminAuthController>().signInWithGoogle();
    if (mounted) {
      setState(() {
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthController>();
    final env = context.read<AppEnvironment>();
    final bootstrap = context.read<FirebaseBootstrapResult>();

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'FairyCraft Admin',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    env.isProduction
                        ? 'Production login'
                        : 'Development login',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _submitting ? null : _signInWithGoogle,
                    icon: const Icon(Icons.login),
                    label: const Text('Sign in with Google'),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _submitting ? null : _signInWithEmailPassword,
                    child: const Text('Sign in with Email/Password'),
                  ),
                  if (_submitting) ...<Widget>[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                  if (bootstrap.usingMockMode) ...<Widget>[
                    const SizedBox(height: 12),
                    const Text(
                      'Running in mock mode. Use any credentials for local dev.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ],
                  if (bootstrap.error != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      'Firebase init fallback: ${bootstrap.error}',
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ],
                  if (auth.errorMessage != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      auth.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
