import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../story/image_generation_service.dart';
import '../story/shared_preferences_story_repository.dart';
import '../story/models.dart';
import '../story/story_service.dart';
import '../tts/tts_service.dart';
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
  String? _error;
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

  Future<void> _continue(String choiceId) async {
    final current = _story;
    if (current == null) {
      return;
    }

    setState(() {
      _working = true;
      _error = null;
    });

    try {
      final storyService = context.read<StoryService>();
      final repository = context.read<SharedPreferencesStoryRepository>();

      final updated = await storyService.continueStory(story: current, choiceId: choiceId);
      await repository.saveStory(updated);

      setState(() {
        _story = updated;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
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

    setState(() {
      _working = true;
      _error = null;
    });

    try {
      final imageService = context.read<ImageGenerationService>();
      final repository = context.read<SharedPreferencesStoryRepository>();
      final response = await imageService.generateIllustration(
        story: current,
        prompt: _promptController.text.trim().isEmpty ? null : _promptController.text.trim(),
      );

      final updated = current.copyWith(lastImagePrompt: response.imagePrompt);
      await repository.saveStory(updated);
      setState(() {
        _story = updated;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  Future<void> _readCurrentChapter() async {
    final chapter = _story?.chapters.isNotEmpty == true ? _story!.chapters.last : null;
    if (chapter == null) {
      return;
    }

    await context.read<TtsService>().speak(
          chapter.text,
          languageCode: _story?.storyLang ?? 'en',
        );
  }

  @override
  Widget build(BuildContext context) {
    final story = _story;
    final voice = context.watch<VoiceInputController>();

    if (story == null) {
      return const Scaffold(
        body: Center(child: Text('No story selected. Start from setup page.')),
      );
    }

    final chapter = story.chapters.isNotEmpty ? story.chapters.last : null;

    return Scaffold(
      appBar: AppBar(title: Text(story.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (chapter == null)
            const Text('No chapter available.')
          else ...<Widget>[
            Text('Chapter ${chapter.index}', style: Theme.of(context).textTheme.titleLarge),
            if (chapter.title != null) Text(chapter.title!),
            const SizedBox(height: 12),
            Text(chapter.text),
            const SizedBox(height: 16),
            const Text('Choices:'),
            const SizedBox(height: 8),
            for (final choice in chapter.choices)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FilledButton.tonal(
                  onPressed: _working ? null : () => _continue(choice.id),
                  child: Text(choice.label),
                ),
              ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _promptController,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Illustration prompt (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: <Widget>[
              FilledButton(
                onPressed: _working ? null : _illustrate,
                child: const Text('Illustrate'),
              ),
              OutlinedButton(
                onPressed: _working ? null : _readCurrentChapter,
                child: const Text('Read chapter (TTS)'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: <Widget>[
              OutlinedButton(
                onPressed: voice.isListening ? null : voice.startListening,
                child: const Text('Voice input'),
              ),
              OutlinedButton(
                onPressed: voice.isListening
                    ? () async {
                        await voice.stopListening();
                        _promptController.text = voice.lastText;
                        setState(() {});
                      }
                    : null,
                child: const Text('Use recognized text'),
              ),
            ],
          ),
          if (story.lastImagePrompt != null) ...<Widget>[
            const SizedBox(height: 12),
            Text('Last illustration prompt: ${story.lastImagePrompt}'),
          ],
          if (_error != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}

