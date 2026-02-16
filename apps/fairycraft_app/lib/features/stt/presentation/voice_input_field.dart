import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n.dart';
import '../../../settings/settings_controller.dart';
import '../../../shared/ui/fairycraft_theme.dart';
import '../application/stt_controller.dart';
import '../domain/stt_language.dart';

class VoiceInputField extends StatefulWidget {
  const VoiceInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.minLines = 4,
    this.maxLines = 6,
  });

  final TextEditingController controller;
  final String hintText;
  final int minLines;
  final int maxLines;

  @override
  State<VoiceInputField> createState() => _VoiceInputFieldState();
}

class _VoiceInputFieldState extends State<VoiceInputField> {
  String? _lastShownError;

  Future<void> _onMicPressed() async {
    final sttController = context.read<SttController>();
    if (sttController.isProcessing) {
      return;
    }

    if (sttController.isRecording) {
      final settings = context.read<SettingsController>();
      final language = _resolveLanguage(settings);
      final result = await sttController.stopRecordingAndTranscribe(
        language: language,
      );
      if (result != null && result.success && !result.isProcessing) {
        final transcript = result.text.trim();
        if (transcript.isNotEmpty) {
          final current = widget.controller.text.trim();
          final nextText = current.isEmpty
              ? transcript
              : '$current $transcript';
          widget.controller
            ..text = nextText
            ..selection = TextSelection.collapsed(offset: nextText.length);
        }
      }
      return;
    }

    final settings = context.read<SettingsController>();
    final language = _resolveLanguage(settings);
    await sttController.startRecording(language: language);
  }

  SttLanguage _resolveLanguage(SettingsController settings) {
    final configured = settings.voiceInputLanguageCode.trim().toLowerCase();
    if (configured == 'app') {
      return sttLanguageFromAppLocaleCode(settings.localeCode);
    }
    return sttLanguageFromStorageCode(configured);
  }

  String _localizeError(AppLocalizations l10n, String raw) {
    switch (raw) {
      case 'Microphone permission is required for voice input.':
        return l10n.sttErrorPermissionRequired;
      case 'Unable to start recording right now.':
        return l10n.sttErrorUnableStartRecording;
      case 'Recorded audio file was not created.':
        return l10n.sttErrorAudioNotCreated;
      case 'Recorded audio file was not found.':
        return l10n.sttErrorAudioNotFound;
      case 'Transcription in progress. Please try a shorter sample.':
        return l10n.sttErrorProcessingInProgress;
      case 'Network connection is unstable. Please try again.':
        return l10n.sttErrorNetwork;
      case 'Voice transcription failed. Please try again.':
        return l10n.sttErrorFailed;
      case 'Story Agent URL is missing. Use --dart-define=STORY_AGENT_URL=<backend_url>.':
        return l10n.sttErrorProxyMissing;
      case 'Story Agent URL is invalid.':
        return l10n.sttErrorProxyInvalid;
      default:
        return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sttController = context.watch<SttController>();

    final currentError = sttController.errorMessage;
    if (currentError != null && currentError != _lastShownError) {
      _lastShownError = currentError;
      final localizedError = _localizeError(l10n, currentError);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizedError)));
      });
    }

    final isRecording = sttController.isRecording;
    final isProcessing = sttController.isProcessing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: widget.controller,
          enabled: !isProcessing,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _MicButton(
                isRecording: isRecording,
                isProcessing: isProcessing,
                onPressed: _onMicPressed,
                startTooltip: l10n.sttStartRecordingTooltip,
                stopTooltip: l10n.sttStopRecordingTooltip,
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minHeight: 52,
              minWidth: 56,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            if (isRecording)
              Text(
                l10n.sttRecordingTapToStop,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: FairyCraftPalette.secondary,
                ),
              )
            else if (isProcessing)
              Text(
                l10n.sttProcessingVoice,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Text(
                l10n.sttTapMicToUseVoice,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
        if (sttController.lastDetectedLanguage != null &&
            sttController.lastDetectedLanguage!.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            l10n.sttDetectedLanguage(sttController.lastDetectedLanguage!),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: FairyCraftPalette.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.isRecording,
    required this.isProcessing,
    required this.onPressed,
    required this.startTooltip,
    required this.stopTooltip,
  });

  final bool isRecording;
  final bool isProcessing;
  final Future<void> Function() onPressed;
  final String startTooltip;
  final String stopTooltip;

  @override
  Widget build(BuildContext context) {
    if (isProcessing) {
      return const SizedBox(
        height: 28,
        width: 28,
        child: Padding(
          padding: EdgeInsets.all(4),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final icon = isRecording ? Icons.stop_rounded : Icons.mic_none_rounded;
    final foreground = isRecording ? Colors.white : FairyCraftPalette.primary;
    final background = isRecording
        ? FairyCraftPalette.secondary
        : FairyCraftPalette.surface;

    return AnimatedContainer(
      duration: FairyCraftMotion.standard,
      curve: FairyCraftMotion.curve,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        border: Border.all(
          color: isRecording
              ? FairyCraftPalette.secondary
              : FairyCraftPalette.outline,
          width: isRecording ? 2 : 1,
        ),
        boxShadow: isRecording
            ? <BoxShadow>[
                BoxShadow(
                  color: FairyCraftPalette.secondary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: foreground),
        tooltip: isRecording ? stopTooltip : startTooltip,
      ),
    );
  }
}
