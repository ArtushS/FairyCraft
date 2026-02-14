import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/config.dart';
import 'firebase/firebase_bootstrap.dart';
import 'settings/settings_controller.dart';
import 'story/shared_preferences_story_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final firebaseBootstrap = await FirebaseBootstrap.init(config);
  final settingsController = await SettingsController.load();
  final storyRepository = await SharedPreferencesStoryRepository.create();

  runApp(
    FairyCraftApp(
      config: config,
      firebaseBootstrap: firebaseBootstrap,
      settingsController: settingsController,
      storyRepository: storyRepository,
    ),
  );
}
