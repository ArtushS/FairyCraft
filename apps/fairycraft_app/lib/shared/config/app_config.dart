import '../../features/tts/domain/tts_request.dart';
import '../../features/stt/domain/stt_language.dart';

class AppConfig {
  const AppConfig({
    required this.storyAgentUrl,
    required this.useMockStories,
    required this.appCheckRequired,
    required this.ttsMode,
    required this.ttsProxyUrl,
    required this.sttMode,
    required this.sttProxyUrl,
    required this.voicemakerApiKey,
  });

  final String storyAgentUrl;
  final bool useMockStories;
  final bool appCheckRequired;
  final String ttsMode;
  final String ttsProxyUrl;
  final String sttMode;
  final String sttProxyUrl;
  final String voicemakerApiKey;

  static AppConfig fromEnvironment() {
    const rawTtsMode = String.fromEnvironment(
      'TTS_MODE',
      defaultValue: TtsMode.proxy,
    );
    final normalizedTtsMode = rawTtsMode.trim().toLowerCase() == TtsMode.direct
        ? TtsMode.direct
        : TtsMode.proxy;

    const rawSttMode = String.fromEnvironment(
      'STT_MODE',
      defaultValue: SttMode.proxy,
    );
    final normalizedSttMode = rawSttMode.trim().toLowerCase() == SttMode.direct
        ? SttMode.direct
        : SttMode.proxy;

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
      ttsMode: normalizedTtsMode,
      ttsProxyUrl: const String.fromEnvironment(
        'TTS_PROXY_URL',
        defaultValue: '',
      ),
      sttMode: normalizedSttMode,
      sttProxyUrl: const String.fromEnvironment(
        'STT_PROXY_URL',
        defaultValue: '',
      ),
      voicemakerApiKey: const String.fromEnvironment(
        'VOICEMAKER_API_KEY',
        defaultValue: '',
      ),
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
