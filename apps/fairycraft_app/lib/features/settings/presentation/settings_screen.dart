import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/tts/application/tts_controller.dart';
import '../../../features/tts/domain/tts_request.dart';
import '../../../features/tts/domain/tts_voice.dart';
import '../../../settings/settings_controller.dart';
import '../../../shared/ui/fairycraft_theme.dart';
import 'settings_strings.dart';

const _flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loadingVoices = false;
  List<TtsVoice> _voices = const <TtsVoice>[];

  String _localizedStatus(AppLocalizations l10n, String raw) {
    if (raw.isEmpty) {
      return raw;
    }
    if (raw == 'Preparing audio...') {
      return l10n.ttsPreparingAudioLabel;
    }
    final chunkMatch = RegExp(
      r'^Preparing audio\.\.\. \((\d+)/(\d+) chunks\)$',
    ).firstMatch(raw);
    if (chunkMatch != null) {
      final current = int.tryParse(chunkMatch.group(1) ?? '') ?? 0;
      final total = int.tryParse(chunkMatch.group(2) ?? '') ?? 0;
      return l10n.ttsPreparingAudioChunks(current, total);
    }
    if (raw == 'Playing...') {
      return l10n.ttsPlayingLabel;
    }
    if (raw == 'Paused') {
      return l10n.ttsPausedLabel;
    }
    if (raw == 'Completed') {
      return l10n.ttsCompletedLabel;
    }
    return raw;
  }

  String _localizedTtsError(AppLocalizations l10n, String raw) {
    switch (raw) {
      case 'Narration text is empty.':
        return l10n.ttsErrorNarrationEmpty;
      case 'No voices available for this language.':
        return l10n.ttsErrorNoVoicesForLanguage;
      case 'Unable to select a narration voice.':
        return l10n.ttsErrorSelectVoice;
      case 'No audio chunks were generated.':
        return l10n.ttsErrorNoAudioChunks;
      case 'Network connection is unstable. Please try again.':
        return l10n.ttsErrorNetwork;
      case 'Unable to start narration right now. Please try again.':
        return l10n.ttsErrorStart;
      default:
        return raw;
    }
  }

  Future<void> _refreshVoices({bool forceRefresh = false}) async {
    if (_loadingVoices) {
      return;
    }

    final settings = context.read<SettingsController>();
    final ttsController = context.read<TtsController>();
    final strings = SettingsStrings.of(context);
    final languageCode = ttsController.resolveLanguageCode(
      text: strings.testVoicePhrase,
      languageMode: settings.ttsLanguageMode,
      appLocaleCode: settings.localeCode,
    );

    setState(() {
      _loadingVoices = true;
    });

    try {
      final voices = await ttsController.fetchVoices(
        languageCode: languageCode,
        preferredGender: settings.preferredGender,
        qualityPreset: settings.ttsOutputQualityPreset,
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }

      final selectedVoiceId = settings.preferredVoiceId;
      final selectedExists =
          selectedVoiceId != null &&
          voices.any((voice) => voice.voiceId == selectedVoiceId);
      if (!selectedExists) {
        final defaultVoice = ttsController.pickDefaultVoice(voices);
        await settings.setPreferredVoiceId(defaultVoice?.voiceId);
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _voices = voices;
      });
    } catch (error) {
      // If voices fail to load (missing proxy, network, etc.), default to empty list
      if (!mounted) return;
      setState(() {
        _voices = const <TtsVoice>[];
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingVoices = false;
        });
      }
    }
  }

  Future<void> _openVoiceSelector() async {
    await _refreshVoices();
    if (!mounted) {
      return;
    }

    final settings = context.read<SettingsController>();
    final strings = SettingsStrings.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final selectedVoiceId = context
            .watch<SettingsController>()
            .preferredVoiceId;
        return SafeArea(
          child: Padding(
            padding: FairyCraftSpacing.page,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  strings.chooseVoiceSheetTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: FairyCraftSpacing.element),
                if (_voices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(strings.noVoicesAvailable),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _voices.length,
                      itemBuilder: (context, index) {
                        final voice = _voices[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(voice.name),
                          subtitle: Text('${voice.language} • ${voice.engine}'),
                          trailing: voice.voiceId == selectedVoiceId
                              ? const Icon(Icons.check_circle_rounded)
                              : null,
                          onTap: () async {
                            await settings.setPreferredVoiceId(voice.voiceId);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _testVoice() async {
    final settings = context.read<SettingsController>();
    if (!settings.narrationEnabled) {
      return;
    }

    final strings = SettingsStrings.of(context);
    final ttsController = context.read<TtsController>();
    await ttsController.playText(
      text: strings.testVoicePhrase,
      languageMode: settings.ttsLanguageMode,
      appLocaleCode: settings.localeCode,
      preferredGender: settings.preferredGender,
      qualityPreset: settings.ttsOutputQualityPreset,
      preferredVoiceId: settings.preferredVoiceId,
      speed: settings.ttsSpeed,
      intensity: settings.ttsIntensity,
      volume: settings.ttsVolume,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsController>();
    final ttsController = context.watch<TtsController>();
    final strings = SettingsStrings.of(context);
    final showDebugSection = _flavor.trim().toLowerCase() == 'dev';
    final narrationEnabled = settings.narrationEnabled;
    final selectedVoiceLabel = settings.preferredVoiceId == null
        ? strings.systemDefaultLabel
        : _voices
              .firstWhere(
                (voice) => voice.voiceId == settings.preferredVoiceId,
                orElse: () => TtsVoice(
                  voiceId: settings.preferredVoiceId!,
                  name: settings.preferredVoiceId!,
                  gender: TtsVoiceGender.unknown,
                  engine: '',
                  language: '',
                  country: '',
                  languageName: '',
                ),
              )
              .name;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(strings.settingsTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: FairyCraftSpacing.page,
          children: <Widget>[
            const _SectionHeader(label: 'Appearance'),
            Card(
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(strings.reduceMotionTitle),
                subtitle: Text(strings.reduceMotionSubtitle),
                value: settings.reduceMotion,
                onChanged: settings.setReduceMotion,
              ),
            ),
            const SizedBox(height: FairyCraftSpacing.section),
            const _SectionHeader(label: 'Language'),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(strings.languageTitle),
                    subtitle: Text(
                      settings.localeCode == 'hy'
                          ? strings.languageArmenian
                          : settings.localeCode == 'ru'
                          ? strings.languageRussian
                          : strings.languageEnglish,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () =>
                        context.pushNamed(AppRouteName.settingsLanguage),
                  ),
                  const Divider(height: 1),
                  _DropdownSetting(
                    label: strings.voiceInputLanguageTitle,
                    value: settings.voiceInputLanguageCode,
                    enabled: true,
                    items: <String, String>{
                      'auto': strings.voiceInputLanguageAuto,
                      'app': strings.voiceInputLanguageApp,
                      'en': strings.voiceInputLanguageEnglish,
                      'ru': strings.voiceInputLanguageRussian,
                      'hy': strings.voiceInputLanguageArmenian,
                    },
                    onChanged: (value) {
                      if (value != null) {
                        settings.setVoiceInputLanguageCode(value);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(strings.voiceInputHelpTitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () =>
                        context.pushNamed(AppRouteName.settingsVoiceHelp),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    enabled: false,
                    title: Text(strings.defaultNarrationVoiceTitle),
                    subtitle: Text(strings.defaultNarrationVoiceComingSoon),
                    trailing: const Icon(Icons.lock_outline_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FairyCraftSpacing.section),
            const _SectionHeader(label: 'Audio'),
            Card(
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    title: Text(strings.voiceNarrationTitle),
                    value: narrationEnabled,
                    onChanged: settings.setNarrationEnabled,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    title: const Text('Autoplay narration'),
                    value: settings.narrationAutoplayEnabled,
                    onChanged: narrationEnabled
                        ? settings.setNarrationAutoplayEnabled
                        : null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    title: const Text('Music'),
                    value: settings.musicEnabled,
                    onChanged: settings.setMusicEnabled,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    title: const Text('Sound effects'),
                    value: settings.soundEffectsEnabled,
                    onChanged: settings.setSoundEffectsEnabled,
                  ),
                  const Divider(height: 1),
                  _DropdownSetting(
                    label: strings.ttsLanguageModeTitle,
                    value: settings.ttsLanguageMode,
                    enabled: narrationEnabled,
                    items: <String, String>{
                      TtsLanguageMode.auto: strings.ttsLanguageModeAuto,
                      TtsLanguageMode.followApp:
                          strings.ttsLanguageModeFollowApp,
                      TtsLanguageMode.englishUs: strings.ttsLanguageModeEnglish,
                      TtsLanguageMode.russianRu: strings.ttsLanguageModeRussian,
                      TtsLanguageMode.armenianAm:
                          strings.ttsLanguageModeArmenian,
                    },
                    onChanged: (value) async {
                      if (value == null) {
                        return;
                      }
                      await settings.setTtsLanguageMode(value);
                      await _refreshVoices(forceRefresh: true);
                    },
                  ),
                  _DropdownSetting(
                    label: strings.voiceGenderTitle,
                    value: settings.preferredGender,
                    enabled: narrationEnabled,
                    items: <String, String>{
                      TtsGenderPreference.any: strings.voiceGenderAny,
                      TtsGenderPreference.female: strings.voiceGenderFemale,
                      TtsGenderPreference.male: strings.voiceGenderMale,
                    },
                    onChanged: (value) async {
                      if (value == null) {
                        return;
                      }
                      await settings.setPreferredGender(value);
                      await _refreshVoices(forceRefresh: true);
                    },
                  ),
                  _DropdownSetting(
                    label: strings.voiceQualityTitle,
                    value: settings.ttsOutputQualityPreset,
                    enabled: narrationEnabled,
                    items: <String, String>{
                      TtsOutputQualityPreset.defaultPreset:
                          strings.voiceQualityDefault,
                      TtsOutputQualityPreset.expressive:
                          strings.voiceQualityExpressive,
                      TtsOutputQualityPreset.highres:
                          strings.voiceQualityHighRes,
                      TtsOutputQualityPreset.turbo: strings.voiceQualityTurbo,
                      TtsOutputQualityPreset.pro2: strings.voiceQualityPro2,
                      TtsOutputQualityPreset.pro1: strings.voiceQualityPro1,
                    },
                    onChanged: (value) async {
                      if (value == null) {
                        return;
                      }
                      await settings.setTtsOutputQualityPreset(value);
                      await _refreshVoices(forceRefresh: true);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    enabled: narrationEnabled,
                    title: Text(strings.defaultNarrationVoiceSystemTitle),
                    subtitle: Text(
                      _loadingVoices
                          ? strings.loadingVoices
                          : selectedVoiceLabel,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: narrationEnabled ? _openVoiceSelector : null,
                  ),
                  const Divider(height: 1),
                  _SliderSetting(
                    label: strings.volumeTitle,
                    value: settings.ttsVolume,
                    min: 0.0,
                    max: 1.0,
                    enabled: narrationEnabled,
                    onChanged: (value) =>
                        settings.setTtsVolume(value, persist: false),
                    onChangeEnd: (value) =>
                        settings.setTtsVolume(value, persist: true),
                  ),
                  _SliderSetting(
                    label: strings.speedTitle,
                    value: settings.ttsSpeed,
                    min: 0.5,
                    max: 1.5,
                    enabled: narrationEnabled,
                    onChanged: (value) =>
                        settings.setTtsSpeed(value, persist: false),
                    onChangeEnd: (value) =>
                        settings.setTtsSpeed(value, persist: true),
                  ),
                  _SliderSetting(
                    label: strings.intensityTitle,
                    value: settings.ttsIntensity,
                    min: 0.0,
                    max: 1.5,
                    enabled: narrationEnabled,
                    onChanged: (value) =>
                        settings.setTtsIntensity(value, persist: false),
                    onChangeEnd: (value) =>
                        settings.setTtsIntensity(value, persist: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FairyCraftSpacing.element),
            FilledButton(
              onPressed: narrationEnabled ? _testVoice : null,
              child: Text(strings.testVoiceButton),
            ),
            const SizedBox(height: FairyCraftSpacing.section),
            const _SectionHeader(label: 'Parental control'),
            Card(
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    title: const Text('Safe mode'),
                    value: settings.safeMode,
                    onChanged: settings.setSafeMode,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    title: const Text('Disable scary content'),
                    value: settings.disableScaryContent,
                    onChanged: settings.setDisableScaryContent,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    title: const Text('Require parent confirmation for older'),
                    value: settings.requireParentConfirmationForOlder,
                    onChanged: settings.setRequireParentConfirmationForOlder,
                  ),
                ],
              ),
            ),
            if (showDebugSection) ...<Widget>[
              const SizedBox(height: FairyCraftSpacing.section),
              const _SectionHeader(label: 'Debug'),
              Card(
                child: ListTile(
                  title: const Text('Firebase sanity check'),
                  subtitle: const Text(
                    'Inspect Firebase bootstrap, App Check and auth wiring.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.pushNamed(AppRouteName.debugFirebase),
                ),
              ),
            ],
            if (ttsController.statusLabel.isNotEmpty) ...<Widget>[
              const SizedBox(height: FairyCraftSpacing.element),
              Text(
                _localizedStatus(l10n, ttsController.statusLabel),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (ttsController.lastError != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                _localizedTtsError(l10n, ttsController.lastError!),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: FairyCraftPalette.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FairyCraftSpacing.element),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: FairyCraftPalette.textSecondary,
        ),
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.enabled,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final textStyle = enabled
        ? Theme.of(context).textTheme.bodyLarge
        : Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: FairyCraftPalette.textSecondary.withValues(alpha: 0.55),
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(label, style: textStyle)),
              Text(value.toStringAsFixed(2), style: textStyle),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: enabled ? onChanged : null,
            onChangeEnd: enabled ? onChangeEnd : null,
          ),
        ],
      ),
    );
  }
}

class _DropdownSetting extends StatelessWidget {
  const _DropdownSetting({
    required this.label,
    required this.value,
    required this.enabled,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final bool enabled;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey<String>('settings-dropdown-$label-$value'),
            initialValue: items.containsKey(value) ? value : null,
            items: items.entries
                .map(
                  (entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(growable: false),
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
