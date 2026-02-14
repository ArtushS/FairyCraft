import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig({
    required this.storyAgentUrl,
    required this.useMockStories,
    required this.appCheckRequired,
  });

  final String storyAgentUrl;
  final bool useMockStories;
  final bool appCheckRequired;

  static AppConfig fromEnvironment() {
    return AppConfig(
      storyAgentUrl: const String.fromEnvironment(
        'STORY_AGENT_URL',
        defaultValue: 'http://localhost:8080/',
      ),
      useMockStories: const bool.fromEnvironment(
        'USE_MOCK_STORIES',
        defaultValue: true,
      ),
      appCheckRequired: bool.fromEnvironment(
        'APPCHECK_REQUIRED',
        defaultValue: kReleaseMode,
      ),
    );
  }
}
