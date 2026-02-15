import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../settings/settings_controller.dart';
import '../../../shared/ui/fairycraft_theme.dart';
import '../application/tts_controller.dart';
import '../domain/tts_request.dart';
import '../domain/tts_voice.dart';
import 'tts_strings.dart';

class TtsControlsWidget extends StatefulWidget {
  const TtsControlsWidget({super.key, required this.text});

  final String text;

  @override
  State<TtsControlsWidget> createState() => _TtsControlsWidgetState();
}

class _TtsControlsWidgetState extends State<TtsControlsWidget> {
  bool _loadingVoices = false;
  List<TtsVoice> _voices = const <TtsVoice>[];

  String _localizedStatus(TtsStrings strings, String raw) {
    if (raw.isEmpty) {
      return raw;
    }
    if (raw == 'Preparing audio...') {
      return strings.preparingAudioLabel;
    }
    final chunkMatch = RegExp(
      r'^Preparing audio\.\.\. \((\d+)/(\d+) chunks\)$',
    ).firstMatch(raw);
    if (chunkMatch != null) {
      final current = int.tryParse(chunkMatch.group(1) ?? '') ?? 0;
      final total = int.tryParse(chunkMatch.group(2) ?? '') ?? 0;
      return AppLocalizations.of(context)!.ttsPreparingAudioChunks(
        current,
        total,
      );
    }
    if (raw == 'Playing...') {
      return strings.playingLabel;
    }
    if (raw == 'Paused') {
      return strings.pausedLabel;
    }
    if (raw == 'Completed') {
      return strings.completedLabel;
    }
    return raw;
  }

  String _localizedError(AppLocalizations l10n, String raw) {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadVoices();
    });
  }

  Future<void> _loadVoices({bool forceRefresh = false}) async {
    if (_loadingVoices) {
      return;
    }

    final settings = context.read<SettingsController>();
    final ttsController = context.read<TtsController>();
    final languageCode = ttsController.resolveLanguageCode(
      text: widget.text,
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

      setState(() {
        _voices = voices;
      });

      final selectedVoiceId = settings.preferredVoiceId;
      final selectedExists =
          selectedVoiceId != null &&
          voices.any((voice) => voice.voiceId == selectedVoiceId);
      if (!selectedExists && voices.isNotEmpty) {
        final defaultVoice = ttsController.pickDefaultVoice(voices);
        await settings.setPreferredVoiceId(defaultVoice?.voiceId);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
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

  Future<void> _play() async {
    final settings = context.read<SettingsController>();
    if (!settings.narrationEnabled) {
      return;
    }

    final ttsController = context.read<TtsController>();
    await ttsController.playText(
      text: widget.text,
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
    final strings = TtsStrings.of(context);
    final narrationEnabled = settings.narrationEnabled;
    final selectedVoiceId = settings.preferredVoiceId;

    return SafeArea(
      child: Padding(
        padding: FairyCraftSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings.narrationTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: FairyCraftSpacing.element),
            if (!narrationEnabled)
              Text(
                strings.narrationDisabled,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            _DropdownField<String>(
              label: strings.languageModeLabel,
              value: settings.ttsLanguageMode,
              items: <String, String>{
                TtsLanguageMode.auto: strings.languageAuto,
                TtsLanguageMode.followApp: strings.languageFollowApp,
                TtsLanguageMode.englishUs: strings.languageEnglish,
                TtsLanguageMode.russianRu: strings.languageRussian,
                TtsLanguageMode.armenianAm: strings.languageArmenian,
              },
              enabled: narrationEnabled,
              onChanged: (value) async {
                if (value == null) {
                  return;
                }
                await settings.setTtsLanguageMode(value);
                await _loadVoices(forceRefresh: true);
              },
            ),
            const SizedBox(height: FairyCraftSpacing.element),
            _DropdownField<String>(
              label: strings.voiceGenderLabel,
              value: settings.preferredGender,
              items: <String, String>{
                TtsGenderPreference.any: strings.genderAny,
                TtsGenderPreference.female: strings.genderFemale,
                TtsGenderPreference.male: strings.genderMale,
              },
              enabled: narrationEnabled,
              onChanged: (value) async {
                if (value == null) {
                  return;
                }
                await settings.setPreferredGender(value);
                await _loadVoices(forceRefresh: true);
              },
            ),
            const SizedBox(height: FairyCraftSpacing.element),
            _DropdownField<String>(
              label: strings.qualityPresetLabel,
              value: settings.ttsOutputQualityPreset,
              items: <String, String>{
                TtsOutputQualityPreset.defaultPreset: strings.qualityDefault,
                TtsOutputQualityPreset.expressive: strings.qualityExpressive,
                TtsOutputQualityPreset.highres: strings.qualityHighRes,
                TtsOutputQualityPreset.turbo: strings.qualityTurbo,
                TtsOutputQualityPreset.pro2: strings.qualityPro2,
                TtsOutputQualityPreset.pro1: strings.qualityPro1,
              },
              enabled: narrationEnabled,
              onChanged: (value) async {
                if (value == null) {
                  return;
                }
                await settings.setTtsOutputQualityPreset(value);
                await _loadVoices(forceRefresh: true);
              },
            ),
            const SizedBox(height: FairyCraftSpacing.element),
            _DropdownField<String>(
              label: strings.voiceLabel,
              value: selectedVoiceId,
              items: {
                for (final voice in _voices) voice.voiceId: voice.displayName,
              },
              enabled:
                  narrationEnabled && _voices.isNotEmpty && !_loadingVoices,
              hint: _loadingVoices
                  ? strings.preparingAudioLabel
                  : strings.errorNoVoices,
              onChanged: (value) => settings.setPreferredVoiceId(value),
            ),
            const SizedBox(height: FairyCraftSpacing.section),
            _ValueSlider(
              label: strings.volumeLabel,
              value: settings.ttsVolume,
              min: 0.0,
              max: 1.0,
              enabled: narrationEnabled,
              onChanged: (value) async {
                await settings.setTtsVolume(value, persist: false);
                await ttsController.setPlayerVolume(value);
              },
              onChangeEnd: (value) =>
                  settings.setTtsVolume(value, persist: true),
            ),
            _ValueSlider(
              label: strings.speedLabel,
              value: settings.ttsSpeed,
              min: 0.5,
              max: 1.5,
              enabled: narrationEnabled,
              onChanged: (value) => settings.setTtsSpeed(value, persist: false),
              onChangeEnd: (value) =>
                  settings.setTtsSpeed(value, persist: true),
            ),
            _ValueSlider(
              label: strings.intensityLabel,
              value: settings.ttsIntensity,
              min: 0.0,
              max: 1.5,
              enabled: narrationEnabled,
              onChanged: (value) =>
                  settings.setTtsIntensity(value, persist: false),
              onChangeEnd: (value) =>
                  settings.setTtsIntensity(value, persist: true),
            ),
            const SizedBox(height: FairyCraftSpacing.element),
            LinearProgressIndicator(value: ttsController.progress),
            const SizedBox(height: 8),
            Text(
              _localizedStatus(strings, ttsController.statusLabel),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (ttsController.lastError != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                _localizedError(l10n, ttsController.lastError!),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: FairyCraftPalette.error,
                ),
              ),
            ],
            const SizedBox(height: FairyCraftSpacing.element),
            Wrap(
              spacing: FairyCraftSpacing.element,
              runSpacing: FairyCraftSpacing.element,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: narrationEnabled && !ttsController.isPreparing
                      ? _play
                      : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(strings.playLabel),
                ),
                OutlinedButton.icon(
                  onPressed: ttsController.isPlaying
                      ? ttsController.pause
                      : null,
                  icon: const Icon(Icons.pause_rounded),
                  label: Text(strings.pauseLabel),
                ),
                OutlinedButton.icon(
                  onPressed: ttsController.isPaused
                      ? ttsController.resume
                      : null,
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  label: Text(strings.resumeLabel),
                ),
                OutlinedButton.icon(
                  onPressed: (ttsController.isPlaying || ttsController.isPaused)
                      ? ttsController.stop
                      : null,
                  icon: const Icon(Icons.stop_rounded),
                  label: Text(strings.stopLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.hint,
  });

  final String label;
  final T? value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          key: ValueKey<String>('tts-dropdown-$label-$value'),
          initialValue: items.containsKey(value) ? value : null,
          hint: hint == null ? null : Text(hint!),
          items: items.entries
              .map(
                (entry) => DropdownMenuItem<T>(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(growable: false),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}

class _ValueSlider extends StatelessWidget {
  const _ValueSlider({
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
            color: FairyCraftPalette.textSecondary.withValues(alpha: 0.5),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
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
