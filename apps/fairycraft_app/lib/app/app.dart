import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_service.dart';
import '../auth/auth_service_firebase.dart';
import '../auth/auth_service_mock.dart';
import '../firebase/firebase_bootstrap.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_scope.dart';
import '../story/catalog_repository.dart';
import '../story/image_generation_service.dart';
import '../story/shared_preferences_story_repository.dart';
import '../story/story_service.dart';
import '../tts/tts_service.dart';
import '../voice/voice_input_controller.dart';
import 'config.dart';
import 'router.dart';

class FairyCraftApp extends StatelessWidget {
  const FairyCraftApp({
    super.key,
    required this.config,
    required this.firebaseBootstrap,
    required this.settingsController,
    required this.storyRepository,
  });

  final AppConfig config;
  final FirebaseBootstrap firebaseBootstrap;
  final SettingsController settingsController;
  final SharedPreferencesStoryRepository storyRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<AppConfig>.value(value: config),
        Provider<FirebaseBootstrap>.value(value: firebaseBootstrap),
        ChangeNotifierProvider<SettingsController>.value(value: settingsController),
        Provider<AuthService>(
          create: (_) => firebaseBootstrap.firebaseReady ? AuthServiceFirebase() : AuthServiceMock(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(context.read<AuthService>())..start(),
        ),
        Provider<SharedPreferencesStoryRepository>.value(value: storyRepository),
        Provider<StoryCatalogRepository>(create: (_) => StubStoryCatalogRepository()),
        Provider<StoryService>(
          create: (context) => StoryService(
            config: context.read<AppConfig>(),
            authService: context.read<AuthService>(),
            settingsController: context.read<SettingsController>(),
          ),
        ),
        Provider<ImageGenerationService>(
          create: (context) => ImageGenerationService(context.read<StoryService>()),
        ),
        Provider<TtsService>(create: (_) => TtsService()),
        ChangeNotifierProvider<VoiceInputController>(
          create: (_) => VoiceInputController(),
        ),
      ],
      child: const _AppRouterShell(),
    );
  }
}

class _AppRouterShell extends StatefulWidget {
  const _AppRouterShell();

  @override
  State<_AppRouterShell> createState() => _AppRouterShellState();
}

class _AppRouterShellState extends State<_AppRouterShell> {
  late final _router = createRouter(
    authController: context.read<AuthController>(),
    settingsController: context.read<SettingsController>(),
  );

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return MaterialApp.router(
      title: 'FairyCraft',
      themeMode: settings.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E8B57)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF2E8B57),
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en'),
        Locale('ru'),
        Locale('hy'),
      ],
      locale: Locale(settings.defaultLanguageCode),
      routerConfig: _router,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return SettingsScope(
          controller: settings,
          child: MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(settings.textScaleFactor),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

