import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../features/tts/presentation/tts_controls_widget.dart';
import '../features/tts/presentation/tts_strings.dart';
import '../settings/settings_controller.dart';
import '../shared/ui/fairycraft_theme.dart';
import '../story/image_generation_service.dart';
import '../story/models.dart';
import '../story/shared_preferences_story_repository.dart';
import '../story/story_service.dart';
import '../voice/voice_input_controller.dart';

class StoryReaderPage extends StatefulWidget {
  const StoryReaderPage({super.key, this.initialStory});

  final StoryRecord? initialStory;

  @override
  State<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends State<StoryReaderPage> {
  StoryRecord? _story;
  bool _working = false;
  String? _errorMessage;
  final TextEditingController _promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _story = widget.initialStory;
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _continueStory(String choiceId) async {
    final current = _story;
    if (current == null) {
      return;
    }
    final l10n = context.l10n;

    setState(() {
      _working = true;
      _errorMessage = null;
    });

    try {
      final storyService = context.read<StoryService>();
      final repository = context.read<SharedPreferencesStoryRepository>();
      final updated = await storyService.continueStory(
        story: current,
        choiceId: choiceId,
      );
      await repository.saveStory(updated);

      if (mounted) {
        setState(() {
          _story = updated;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = _friendlyError(error.toString(), l10n);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  Future<void> _illustrate() async {
    final current = _story;
    if (current == null) {
      return;
    }
    final l10n = context.l10n;

    setState(() {
      _working = true;
      _errorMessage = null;
    });

    try {
      final imageService = context.read<ImageGenerationService>();
      final repository = context.read<SharedPreferencesStoryRepository>();
      final response = await imageService.generateIllustration(
        story: current,
        prompt: _promptController.text.trim().isEmpty
            ? null
            : _promptController.text.trim(),
      );
      final updated = current.copyWith(lastImagePrompt: response.imagePrompt);
      await repository.saveStory(updated);
      if (mounted) {
        setState(() {
          _story = updated;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = _friendlyError(error.toString(), l10n);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  String _buildNarrationText(StoryRecord story) {
    final buffer = StringBuffer()..writeln(story.title);
    for (final chapter in story.chapters) {
      if (chapter.title != null && chapter.title!.trim().isNotEmpty) {
        buffer.writeln();
        buffer.writeln(chapter.title!.trim());
      }
      if (chapter.text.trim().isNotEmpty) {
        buffer.writeln();
        buffer.writeln(chapter.text.trim());
      }
    }
    return buffer.toString().trim();
  }

  Future<void> _openNarrationControls() async {
    final story = _story;
    if (story == null) {
      return;
    }

    final settings = context.read<SettingsController>();
    if (!settings.narrationEnabled) {
      return;
    }

    final narrationText = _buildNarrationText(story);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: SingleChildScrollView(
            child: TtsControlsWidget(text: narrationText),
          ),
        );
      },
    );
  }

  StoryChapter? get _currentChapter {
    final story = _story;
    if (story == null || story.chapters.isEmpty) {
      return null;
    }
    return story.chapters.last;
  }

  String _friendlyError(String raw, AppLocalizations l10n) {
    final normalized = raw.toLowerCase();
    if (normalized.contains('network') || normalized.contains('socket')) {
      return l10n.storyReaderErrorNetwork;
    }
    return l10n.storyReaderErrorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final story = _story;
    if (story == null) {
      return Scaffold(body: Center(child: Text(l10n.storyReaderNoStorySelected)));
    }

    final chapter = _currentChapter;
    final voice = context.watch<VoiceInputController>();
    final settings = context.watch<SettingsController>();
    final ttsStrings = TtsStrings.of(context);

    if (chapter == null) {
      return Scaffold(
        appBar: AppBar(title: Text(story.title)),
        body: Center(child: Text(l10n.storyReaderNoChapter)),
      );
    }

    final progress = chapter.choices.isEmpty
        ? 1.0
        : math.min(0.95, chapter.index / (chapter.index + 1.5));

    return Scaffold(
      appBar: AppBar(title: Text(story.title)),
      body: SafeArea(
        child: ListView(
          padding: FairyCraftSpacing.page,
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(FairyCraftSpacing.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.storyReaderProgressTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: FairyCraftSpacing.element),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(20),
                      backgroundColor: FairyCraftPalette.outline,
                      color: FairyCraftPalette.secondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      chapter.choices.isEmpty
                          ? l10n.storyReaderComplete
                          : l10n.storyReaderChapter(chapter.index),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: FairyCraftSpacing.section),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(FairyCraftSpacing.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (chapter.title != null)
                      Text(
                        chapter.title!,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    if (chapter.title != null)
                      const SizedBox(height: FairyCraftSpacing.element),
                    Text(
                      chapter.text,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.8),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: FairyCraftSpacing.section),
            Text(
              l10n.storyReaderWhatNext,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: FairyCraftSpacing.element),
            if (chapter.choices.isNotEmpty)
              ...chapter.choices.map((choice) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: FairyCraftSpacing.element,
                  ),
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _working ? null : () => _continueStory(choice.id),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          FairyCraftSpacing.padding,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                choice.label,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              })
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(FairyCraftSpacing.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.storyReaderTheEnd,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: FairyCraftSpacing.element),
                      Text(
                        l10n.storyReaderCompleteDescription,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: FairyCraftSpacing.section),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(FairyCraftSpacing.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.storyReaderIllustrations,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: FairyCraftSpacing.element),
                    TextField(
                      controller: _promptController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: l10n.storyReaderPromptHint,
                      ),
                    ),
                    const SizedBox(height: FairyCraftSpacing.element),
                    Wrap(
                      spacing: FairyCraftSpacing.element,
                      children: <Widget>[
                        FilledButton(
                          onPressed: _working ? null : _illustrate,
                          child: Text(l10n.storyReaderGenerateImage),
                        ),
                        OutlinedButton.icon(
                          onPressed: _working || !settings.narrationEnabled
                              ? null
                              : _openNarrationControls,
                          icon: const Icon(Icons.headphones_rounded),
                          label: Text(ttsStrings.listenButton),
                        ),
                      ],
                    ),
                    const SizedBox(height: FairyCraftSpacing.element),
                    Wrap(
                      spacing: FairyCraftSpacing.element,
                      children: <Widget>[
                        OutlinedButton(
                          onPressed: voice.isListening
                              ? null
                              : voice.startListening,
                          child: Text(l10n.storyReaderVoiceInput),
                        ),
                        OutlinedButton(
                          onPressed: voice.isListening
                              ? () async {
                                  await voice.stopListening();
                                  _promptController.text = voice.lastText;
                                  setState(() {});
                                }
                              : null,
                          child: Text(l10n.storyReaderUseRecognizedText),
                        ),
                      ],
                    ),
                    if (story.lastImagePrompt != null) ...<Widget>[
                      const SizedBox(height: FairyCraftSpacing.element),
                      Text(
                        l10n.storyReaderLastPrompt(story.lastImagePrompt!),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: FairyCraftSpacing.section),
              Text(
                _errorMessage!,
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
