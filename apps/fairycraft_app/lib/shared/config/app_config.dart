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
      appCheckRequired: _appCheckEnabledFromEnvironment(),
    );
  }

  static bool _appCheckEnabledFromEnvironment() {
    const appCheckMode = String.fromEnvironment(
      'APP_CHECK',
      defaultValue: 'off',
    );
    final normalizedMode = appCheckMode.trim().toLowerCase();
    if (normalizedMode == 'on') {
      return true;
    }
    if (normalizedMode == 'off') {
      return false;
    }

    return const bool.fromEnvironment('APPCHECK_REQUIRED', defaultValue: false);
  }
}
