import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_service.dart';
import '../auth/auth_service_firebase.dart';
import '../auth/auth_service_mock.dart';
import '../features/stt/application/stt_controller.dart';
import '../features/stt/data/voicemaker_stt_client.dart';
import '../features/tts/application/tts_cache.dart';
import '../features/tts/application/tts_controller.dart';
import '../features/tts/data/voicemaker_client.dart';
import '../features/tts/data/voicemaker_repository.dart';
import '../firebase/firebase_bootstrap.dart';
import '../l10n/l10n.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_scope.dart';
import '../shared/network/request_context.dart';
import '../shared/ui/fairycraft_theme.dart';
import '../story/catalog_repository.dart';
import '../story/image_generation_service.dart';
import '../story/shared_preferences_story_repository.dart';
import '../story/story_preferences_controller.dart';
import '../story/story_service.dart';
import '../voice/voice_input_controller.dart';
import 'config.dart';
import 'router.dart';
import '../l10n/app_localizations.dart';

class FairyCraftApp extends StatelessWidget {
  const FairyCraftApp({
    super.key,
    required this.config,
    required this.firebaseBootstrap,
    required this.settingsController,
    required this.storyPreferencesController,
    required this.storyRepository,
  });

  final AppConfig config;
  final FirebaseBootstrap firebaseBootstrap;
  final SettingsController settingsController;
  final StoryPreferencesController storyPreferencesController;
  final SharedPreferencesStoryRepository storyRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<AppConfig>.value(value: config),
        Provider<FirebaseBootstrap>.value(value: firebaseBootstrap),
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
        ),
        Provider<RequestContext>(
          create: (context) =>
              RequestContext(context.read<SettingsController>()),
        ),
        Provider<http.Client>(
          create: (_) => http.Client(),
          dispose: (_, client) => client.close(),
        ),
        ChangeNotifierProvider<StoryPreferencesController>.value(
          value: storyPreferencesController,
        ),
        Provider<AuthService>(
          create: (_) => firebaseBootstrap.firebaseReady
              ? AuthServiceFirebase()
              : AuthServiceMock(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) =>
              AuthController(context.read<AuthService>())..start(),
        ),
        Provider<SharedPreferencesStoryRepository>.value(
          value: storyRepository,
        ),
        Provider<StoryCatalogRepository>(
          create: (_) => StubStoryCatalogRepository(),
        ),
        Provider<StoryService>(
          create: (context) => StoryService(
            config: context.read<AppConfig>(),
            authService: context.read<AuthService>(),
            settingsController: context.read<SettingsController>(),
            requestContext: context.read<RequestContext>(),
          ),
        ),
        Provider<ImageGenerationService>(
          create: (context) =>
              ImageGenerationService(context.read<StoryService>()),
        ),
        Provider<TtsCache>(create: (_) => TtsCache()),
        Provider<VoicemakerClient>(
          create: (context) => VoicemakerClient(
            config: context.read<AppConfig>(),
            httpClient: context.read<http.Client>(),
            requestContext: context.read<RequestContext>(),
          ),
        ),
        Provider<VoicemakerSttClient>(
          create: (context) => VoicemakerSttClient(
            config: context.read<AppConfig>(),
            httpClient: context.read<http.Client>(),
            idTokenProvider: () => context.read<AuthService>().getIdToken(),
            requestContext: context.read<RequestContext>(),
          ),
        ),
        Provider<VoicemakerRepository>(
          create: (context) => VoicemakerRepository(
            client: context.read<VoicemakerClient>(),
            cache: context.read<TtsCache>(),
          ),
        ),
        ChangeNotifierProvider<TtsController>(
          create: (context) =>
              TtsController(repository: context.read<VoicemakerRepository>()),
        ),
        ChangeNotifierProvider<SttController>(
          create: (context) =>
              SttController(client: context.read<VoicemakerSttClient>()),
        ),
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
    final motionEnabled = settings.reduceMotion;

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appName,
      themeMode: settings.themeMode,
      themeAnimationDuration: motionEnabled
          ? FairyCraftMotion.standard
          : Duration.zero,
      themeAnimationCurve: FairyCraftMotion.curve,
      theme: FairyCraftTheme.light(motionEnabled: motionEnabled),
      darkTheme: FairyCraftTheme.dark(motionEnabled: motionEnabled),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(settings.localeCode),
      routerConfig: _router,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return SettingsScope(
          controller: settings,
          child: MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(settings.textScaleFactor),
              disableAnimations: !motionEnabled,
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
