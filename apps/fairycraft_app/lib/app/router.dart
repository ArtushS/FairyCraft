import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../pages/account_page.dart';
import '../pages/auth_gate_page.dart';
import '../pages/change_password_page.dart';
import '../pages/debug_firebase_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/my_stories_page.dart';
import '../pages/onboarding_page.dart';
import '../pages/provider_link_page.dart';
import '../pages/register_page.dart';
import '../pages/reset_sent_page.dart';
import '../pages/settings_page.dart';
import '../pages/story_preferences_page.dart';
import '../pages/story_reader_page.dart';
import '../pages/story_setup_page.dart';
import '../pages/voice_help_page.dart';
import '../settings/settings_controller.dart';
import '../story/models.dart';

GoRouter createRouter({
  required AuthController authController,
  required SettingsController settingsController,
}) {
  const sessionGateRoute = '/auth';
  const unauthRoutes = <String>{
    '/login',
    '/register',
    '/forgot-password',
    '/reset-sent',
  };

  return GoRouter(
    initialLocation: '/auth',
    refreshListenable: Listenable.merge(<Listenable>[
      authController,
      settingsController,
    ]),
    redirect: (context, state) {
      final location = state.uri.path;
      final isUnauthRoute = unauthRoutes.contains(location);
      String? target;

      if (authController.status == AuthStatus.unknown ||
          authController.status == AuthStatus.loading) {
        target = location == sessionGateRoute ? null : sessionGateRoute;
      } else if (authController.status == AuthStatus.unauthenticated) {
        if (location == sessionGateRoute) {
          target = '/login';
        } else {
          target = isUnauthRoute ? null : '/login';
        }
      } else if (authController.status == AuthStatus.authenticated &&
          (location == sessionGateRoute || isUnauthRoute)) {
        target = '/';
      } else if (authController.status == AuthStatus.authenticated &&
          !settingsController.onboardingCompleted &&
          location == '/') {
        target = '/onboarding';
      } else if (authController.status == AuthStatus.authenticated &&
          settingsController.onboardingCompleted &&
          location == '/onboarding') {
        target = '/';
      }

      if (kDebugMode && (location == sessionGateRoute || target != null)) {
        debugPrint(
          '[auth_router] status=${authController.status} '
          'location=$location target=${target ?? '-'}',
        );
      }
      return target;
    },
    routes: <RouteBase>[
      GoRoute(path: '/auth', builder: (context, state) => const AuthGatePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-sent',
        builder: (context, state) => const ResetSentPage(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountPage(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/provider-link',
        builder: (context, state) => const ProviderLinkPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/story-preferences',
        builder: (context, state) => const StoryPreferencesPage(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const StorySetupPage(),
      ),
      GoRoute(
        path: '/my-stories',
        builder: (context, state) => const MyStoriesPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/voice-help',
        builder: (context, state) => const VoiceHelpPage(),
      ),
      GoRoute(
        path: '/debug-firebase',
        builder: (context, state) => const DebugFirebasePage(),
      ),
      GoRoute(
        path: '/story-reader',
        builder: (context, state) {
          final extra = state.extra;
          final story = extra is StoryRecord ? extra : null;
          return StoryReaderPage(initialStory: story);
        },
      ),
    ],
  );
}
