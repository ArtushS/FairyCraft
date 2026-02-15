import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../l10n/l10n.dart';
import '../shared/ui/fairycraft_theme.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? _statusMessage;

  Future<void> _toggleProvider({
    required String providerId,
    required bool linked,
  }) async {
    final auth = context.read<AuthController>();
    final l10n = context.l10n;
    final providerLabel = _providerLabel(context, providerId);
    try {
      if (linked) {
        await auth.unlinkProvider(providerId);
      } else {
        await auth.linkProvider(providerId);
      }
      if (mounted) {
        setState(() {
          _statusMessage = linked
              ? l10n.accountProviderUnlinked(providerLabel)
              : l10n.accountProviderLinkRequested(providerLabel);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _statusMessage = context.l10n.accountProviderUpdateFailed;
        });
      }
    }
  }

  String _providerLabel(BuildContext context, String providerId) {
    final l10n = context.l10n;
    switch (providerId) {
      case 'google.com':
        return l10n.accountGoogle;
      case 'facebook.com':
        return l10n.accountFacebook;
      case 'password':
        return l10n.accountEmailPassword;
      default:
        return providerId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthController>();
    final user = auth.user;
    final linkedProviders = user?.providerIds.toSet() ?? <String>{};

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: ListView(
        padding: FairyCraftSpacing.page,
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(FairyCraftSpacing.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.accountEmailLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: FairyCraftSpacing.element),
                  Text(
                    user?.email ?? l10n.commonNotAvailable,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: FairyCraftSpacing.section),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(FairyCraftSpacing.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.accountLinkedProviders,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: FairyCraftSpacing.element),
                  _ProviderTile(
                    icon: Icons.g_mobiledata_rounded,
                    title: l10n.accountGoogle,
                    linked: linkedProviders.contains('google.com'),
                    onPressed: () => _toggleProvider(
                      providerId: 'google.com',
                      linked: linkedProviders.contains('google.com'),
                    ),
                  ),
                  _ProviderTile(
                    icon: Icons.facebook_rounded,
                    title: l10n.accountFacebook,
                    linked: linkedProviders.contains('facebook.com'),
                    onPressed: () => _toggleProvider(
                      providerId: 'facebook.com',
                      linked: linkedProviders.contains('facebook.com'),
                    ),
                  ),
                  _ProviderTile(
                    icon: Icons.lock_outline_rounded,
                    title: l10n.accountEmailPassword,
                    linked: linkedProviders.contains('password'),
                    onPressed: null,
                  ),
                ],
              ),
            ),
          ),
          if (_statusMessage != null) ...<Widget>[
            const SizedBox(height: FairyCraftSpacing.section),
            Text(
              _statusMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: FairyCraftSpacing.section),
          FilledButton.icon(
            onPressed: () async {
              await context.read<AuthController>().signOut();
            },
            icon: const Icon(Icons.logout_rounded),
            label: Text(l10n.accountLogout),
          ),
        ],
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.icon,
    required this.title,
    required this.linked,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final bool linked;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FairyCraftSpacing.element),
      child: Row(
        children: <Widget>[
          Icon(icon, color: FairyCraftPalette.primary),
          const SizedBox(width: FairyCraftSpacing.element),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Icon(
            linked ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: linked
                ? Colors.green.shade600
                : FairyCraftPalette.textSecondary,
          ),
          const SizedBox(width: FairyCraftSpacing.element),
          OutlinedButton(
            onPressed: onPressed,
            child: Text(linked ? context.l10n.commonUnlink : context.l10n.commonLink),
          ),
        ],
      ),
    );
  }
}
