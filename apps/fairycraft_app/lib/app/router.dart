import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../features/settings/presentation/language_selection_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/voice_input_help_screen.dart';
import '../pages/account_page.dart';
import '../pages/auth_gate_page.dart';
import '../pages/debug_firebase_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/my_stories_page.dart';
import '../pages/onboarding_page.dart';
import '../pages/register_page.dart';
import '../pages/reset_sent_page.dart';
import '../pages/story_preferences_page.dart';
import '../pages/story_reader_page.dart';
import '../pages/story_setup_page.dart';
import '../settings/settings_controller.dart';
import '../story/models.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNavigator',
);

class AppRoutePath {
  const AppRoutePath._();

  static const String authGate = '/auth';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetSent = '/reset-sent';
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String setup = '/setup';
  static const String storyReader = '/story-reader';
  static const String myStories = '/my-stories';
  static const String storyPreferences = '/story-preferences';
  static const String account = '/account';
  static const String settings = '/settings';
  static const String settingsLanguage = '/settings/language';
  static const String settingsVoiceHelp = '/settings/voice-help';
  static const String debugFirebase = '/debug-firebase';
}

class AppRouteName {
  const AppRouteName._();

  static const String authGate = 'auth_gate';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot_password';
  static const String resetSent = 'reset_sent';
  static const String home = 'home';
  static const String onboarding = 'onboarding';
  static const String setup = 'setup';
  static const String storyReader = 'story_reader';
  static const String myStories = 'my_stories';
  static const String storyPreferences = 'story_preferences';
  static const String account = 'account';
  static const String settings = 'settings';
  static const String settingsLanguage = 'settings_language';
  static const String settingsVoiceHelp = 'settings_voice_help';
  static const String debugFirebase = 'debug_firebase';
}

MaterialPage<void> _materialPage(GoRouterState state, Widget child) {
  return MaterialPage<void>(key: state.pageKey, child: child);
}

NoTransitionPage<void> _noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}

GoRouter createRouter({
  required AuthController authController,
  required SettingsController settingsController,
}) {
  const unauthPaths = <String>{
    AppRoutePath.login,
    AppRoutePath.register,
    AppRoutePath.forgotPassword,
    AppRoutePath.resetSent,
  };

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutePath.authGate,
    refreshListenable: Listenable.merge(<Listenable>[
      authController,
      settingsController,
    ]),
    redirect: (context, state) {
      final location = state.uri.path;
      final isUnauthRoute = unauthPaths.contains(location);
      String? target;

      if (authController.status == AuthStatus.unknown ||
          authController.status == AuthStatus.loading) {
        target = location == AppRoutePath.authGate
            ? null
            : AppRoutePath.authGate;
      } else if (authController.status == AuthStatus.unauthenticated) {
        if (location == AppRoutePath.authGate) {
          target = AppRoutePath.login;
        } else {
          target = isUnauthRoute ? null : AppRoutePath.login;
        }
      } else if (authController.status == AuthStatus.authenticated &&
          (location == AppRoutePath.authGate || isUnauthRoute)) {
        target = AppRoutePath.home;
      } else if (authController.status == AuthStatus.authenticated &&
          !settingsController.onboardingCompleted &&
          location == AppRoutePath.home) {
        target = AppRoutePath.onboarding;
      } else if (authController.status == AuthStatus.authenticated &&
          settingsController.onboardingCompleted &&
          location == AppRoutePath.onboarding) {
        target = AppRoutePath.home;
      }

      if (kDebugMode && (location == AppRoutePath.authGate || target != null)) {
        debugPrint(
          '[auth_router] status=${authController.status} '
          'location=$location target=${target ?? '-'}',
        );
      }
      return target;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutePath.authGate,
        name: AppRouteName.authGate,
        pageBuilder: (context, state) =>
            _noTransitionPage(state, const AuthGatePage()),
      ),
      GoRoute(
        path: AppRoutePath.login,
        name: AppRouteName.login,
        pageBuilder: (context, state) =>
            _materialPage(state, const LoginPage()),
      ),
      GoRoute(
        path: AppRoutePath.register,
        name: AppRouteName.register,
        pageBuilder: (context, state) =>
            _materialPage(state, const RegisterPage()),
      ),
      GoRoute(
        path: AppRoutePath.forgotPassword,
        name: AppRouteName.forgotPassword,
        pageBuilder: (context, state) =>
            _materialPage(state, const ForgotPasswordPage()),
      ),
      GoRoute(
        path: AppRoutePath.resetSent,
        name: AppRouteName.resetSent,
        pageBuilder: (context, state) =>
            _materialPage(state, const ResetSentPage()),
      ),
      GoRoute(
        path: AppRoutePath.account,
        name: AppRouteName.account,
        pageBuilder: (context, state) =>
            _materialPage(state, const AccountPage()),
      ),
      GoRoute(
        path: AppRoutePath.onboarding,
        name: AppRouteName.onboarding,
        pageBuilder: (context, state) =>
            _materialPage(state, const OnboardingPage()),
      ),
      GoRoute(
        path: AppRoutePath.home,
        name: AppRouteName.home,
        pageBuilder: (context, state) => _materialPage(state, const HomePage()),
      ),
      GoRoute(
        path: AppRoutePath.storyPreferences,
        name: AppRouteName.storyPreferences,
        pageBuilder: (context, state) =>
            _materialPage(state, const StoryPreferencesPage()),
      ),
      GoRoute(
        path: AppRoutePath.setup,
        name: AppRouteName.setup,
        pageBuilder: (context, state) =>
            _materialPage(state, const StorySetupPage()),
      ),
      GoRoute(
        path: AppRoutePath.myStories,
        name: AppRouteName.myStories,
        pageBuilder: (context, state) =>
            _materialPage(state, const MyStoriesPage()),
      ),
      GoRoute(
        path: AppRoutePath.settings,
        name: AppRouteName.settings,
        pageBuilder: (context, state) =>
            _materialPage(state, const SettingsScreen()),
      ),
      GoRoute(
        path: AppRoutePath.settingsLanguage,
        name: AppRouteName.settingsLanguage,
        pageBuilder: (context, state) =>
            _materialPage(state, const LanguageSelectionScreen()),
      ),
      GoRoute(
        path: AppRoutePath.settingsVoiceHelp,
        name: AppRouteName.settingsVoiceHelp,
        pageBuilder: (context, state) =>
            _materialPage(state, const VoiceInputHelpScreen()),
      ),
      GoRoute(
        path: AppRoutePath.debugFirebase,
        name: AppRouteName.debugFirebase,
        pageBuilder: (context, state) =>
            _materialPage(state, const DebugFirebasePage()),
      ),
      GoRoute(
        path: AppRoutePath.storyReader,
        name: AppRouteName.storyReader,
        pageBuilder: (context, state) {
          final extra = state.extra;
          final story = extra is StoryRecord ? extra : null;
          return _materialPage(state, StoryReaderPage(initialStory: story));
        },
      ),
    ],
  );
}
