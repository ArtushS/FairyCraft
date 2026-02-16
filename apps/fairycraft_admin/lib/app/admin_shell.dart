import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/admin_auth_controller.dart';
import 'admin_routes.dart';

class AdminShellScaffold extends StatelessWidget {
  const AdminShellScaffold({super.key, required this.child});

  final Widget child;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(
      path: AdminRoutePath.dashboard,
      label: 'Dashboard',
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard,
    ),
    _NavItem(
      path: AdminRoutePath.policies,
      label: 'Policies',
      icon: Icons.verified_user_outlined,
      selectedIcon: Icons.verified_user,
    ),
    _NavItem(
      path: AdminRoutePath.templates,
      label: 'Templates',
      icon: Icons.auto_fix_high_outlined,
      selectedIcon: Icons.auto_fix_high,
    ),
    _NavItem(
      path: AdminRoutePath.tiers,
      label: 'Tiers',
      icon: Icons.workspace_premium_outlined,
      selectedIcon: Icons.workspace_premium,
    ),
    _NavItem(
      path: AdminRoutePath.monitor,
      label: 'Monitor',
      icon: Icons.monitor_heart_outlined,
      selectedIcon: Icons.monitor_heart,
    ),
    _NavItem(
      path: AdminRoutePath.testConsole,
      label: 'Test Console',
      icon: Icons.science_outlined,
      selectedIcon: Icons.science,
    ),
    _NavItem(
      path: AdminRoutePath.settings,
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndex(location);
    final title = _selectedTitle(location);
    final authController = context.watch<AdminAuthController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final wideLayout = constraints.maxWidth >= 1100;
        return Scaffold(
          drawer: wideLayout ? null : _MobileNavDrawer(currentPath: location),
          appBar: AppBar(
            title: Text(title),
            actions: <Widget>[
              if (authController.currentEmail != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Text(
                      authController.currentEmail!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              TextButton(
                onPressed: () => context.read<AdminAuthController>().signOut(),
                child: const Text('Sign out'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: wideLayout
              ? Row(
                  children: <Widget>[
                    NavigationRail(
                      labelType: NavigationRailLabelType.all,
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (index) {
                        context.go(_items[index].path);
                      },
                      destinations: _items
                          .map(
                            (item) => NavigationRailDestination(
                              icon: Icon(item.icon),
                              selectedIcon: Icon(item.selectedIcon),
                              label: Text(item.label),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: child),
                  ],
                )
              : child,
        );
      },
    );
  }

  int _selectedIndex(String location) {
    for (var index = 0; index < _items.length; index += 1) {
      final item = _items[index];
      if (item.path == AdminRoutePath.dashboard) {
        if (location == AdminRoutePath.dashboard) {
          return index;
        }
      } else if (location.startsWith(item.path)) {
        return index;
      }
    }
    return 0;
  }

  String _selectedTitle(String location) {
    for (final item in _items) {
      if (item.path == AdminRoutePath.dashboard &&
          location == AdminRoutePath.dashboard) {
        return item.label;
      }
      if (item.path != AdminRoutePath.dashboard &&
          location.startsWith(item.path)) {
        return item.label;
      }
    }
    return 'Admin';
  }
}

class _MobileNavDrawer extends StatelessWidget {
  const _MobileNavDrawer({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: AdminShellScaffold._items.map((item) {
            final selected = item.path == AdminRoutePath.dashboard
                ? currentPath == item.path
                : currentPath.startsWith(item.path);
            return ListTile(
              leading: Icon(selected ? item.selectedIcon : item.icon),
              title: Text(item.label),
              selected: selected,
              onTap: () {
                Navigator.of(context).pop();
                context.go(item.path);
              },
            );
          }).toList(growable: false),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
