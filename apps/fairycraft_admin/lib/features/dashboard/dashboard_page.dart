import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/admin_routes.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const <Widget>[
            _KpiCard(
              title: 'Policies',
              value: 'Managed in /policies',
              subtitle: 'Age, language, and tier scoped',
            ),
            _KpiCard(
              title: 'Templates',
              value: 'Managed in /templates',
              subtitle: 'Story + image prompts',
            ),
            _KpiCard(
              title: 'Request Monitor',
              value: 'Last 200 logs',
              subtitle: 'Status, provider, and tier filters',
            ),
            _KpiCard(
              title: 'Dry Run',
              value: 'Admin console',
              subtitle: 'Inspect composed provider payload',
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Quick Links',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _QuickLinkButton(
              label: 'Policies by Age',
              onTap: () => context.go(AdminRoutePath.policies),
            ),
            _QuickLinkButton(
              label: 'Style Templates',
              onTap: () => context.go(AdminRoutePath.templates),
            ),
            _QuickLinkButton(
              label: 'Subscription Tiers',
              onTap: () => context.go(AdminRoutePath.tiers),
            ),
            _QuickLinkButton(
              label: 'Request Monitor',
              onTap: () => context.go(AdminRoutePath.monitor),
            ),
            _QuickLinkButton(
              label: 'Agent Test Console',
              onTap: () => context.go(AdminRoutePath.testConsole),
            ),
            _QuickLinkButton(
              label: 'System Settings',
              onTap: () => context.go(AdminRoutePath.settings),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLinkButton extends StatelessWidget {
  const _QuickLinkButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(onPressed: onTap, child: Text(label));
  }
}
