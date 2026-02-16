import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../auth/admin_auth_controller.dart';
import '../features/auth/not_authorized_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/login/login_page.dart';
import '../features/monitor/monitor_page.dart';
import '../features/policies/policies_page.dart';
import '../features/settings/settings_page.dart';
import '../features/templates/templates_page.dart';
import '../features/test_console/test_console_page.dart';
import '../features/tiers/tiers_page.dart';
import 'admin_routes.dart';
import 'admin_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'adminRootNavigator',
);

GoRouter createAdminRouter(AdminAuthController authController) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AdminRoutePath.dashboard,
    refreshListenable: authController,
    redirect: (context, state) {
      final location = state.uri.path;
      final isLogin = location == AdminRoutePath.login;
      final isUnauthorized = location == AdminRoutePath.notAuthorized;

      if (authController.accessState == AdminAccessState.initializing) {
        if (isLogin) {
          return null;
        }
        return AdminRoutePath.login;
      }

      if (authController.accessState == AdminAccessState.unauthenticated) {
        return isLogin ? null : AdminRoutePath.login;
      }

      if (authController.accessState == AdminAccessState.unauthorized) {
        return isUnauthorized ? null : AdminRoutePath.notAuthorized;
      }

      if (authController.accessState == AdminAccessState.authorized &&
          (isLogin || isUnauthorized)) {
        return AdminRoutePath.dashboard;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AdminRoutePath.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AdminRoutePath.notAuthorized,
        builder: (context, state) => const NotAuthorizedPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShellScaffold(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: AdminRoutePath.dashboard,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: AdminRoutePath.policies,
            builder: (context, state) => const PoliciesPage(),
          ),
          GoRoute(
            path: AdminRoutePath.templates,
            builder: (context, state) => const TemplatesPage(),
          ),
          GoRoute(
            path: AdminRoutePath.tiers,
            builder: (context, state) => const TiersPage(),
          ),
          GoRoute(
            path: AdminRoutePath.monitor,
            builder: (context, state) => const MonitorPage(),
          ),
          GoRoute(
            path: AdminRoutePath.testConsole,
            builder: (context, state) => const TestConsolePage(),
          ),
          GoRoute(
            path: AdminRoutePath.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
