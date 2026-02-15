import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../settings/settings_controller.dart';
import '../shared/services/storage_asset_service.dart';
import '../story/catalog_repository.dart';
import '../story/shared_preferences_story_repository.dart';
import '../story/story_service.dart';
import '../voice/voice_input_controller.dart';

class StorySetupPage extends StatefulWidget {
  const StorySetupPage({super.key});

  @override
  State<StorySetupPage> createState() => _StorySetupPageState();
}

class _StorySetupPageState extends State<StorySetupPage> {
  String _storyLang = 'en';
  String _ageGroup = '6_8';
  String _storyLength = 'medium';
  double _creativity = 0.6;
  bool _imageEnabled = true;

  String? _hero;
  String? _location;
  String? _storyType;

  final TextEditingController _ideaController = TextEditingController();
  late final List<String> _heroPreviewFiles;
  late final List<String> _locationPreviewFiles;
  late final List<String> _stylePreviewFiles;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _heroPreviewFiles = List<String>.generate(
      8,
      (_) => StorageAssetService.randomHero(),
    );
    _locationPreviewFiles = List<String>.generate(
      8,
      (_) => StorageAssetService.randomLocation(),
    );
    _stylePreviewFiles = List<String>.generate(
      8,
      (_) => StorageAssetService.randomStyle(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hero == null) {
      final settings = context.read<SettingsController>();
      _storyLang = settings.defaultLanguageCode;
    }
  }

  @override
  void dispose() {
    _ideaController.dispose();
    super.dispose();
  }

  Future<void> _startStory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final storyService = context.read<StoryService>();
      final repository = context.read<SharedPreferencesStoryRepository>();

      final story = await storyService.generateStory(
        storyLang: _storyLang,
        ageGroup: _ageGroup,
        storyLength: _storyLength,
        creativityLevel: _creativity,
        hero: _hero,
        location: _location,
        storyType: _storyType,
        idea: _ideaController.text.trim().isEmpty
            ? null
            : _ideaController.text.trim(),
        imageEnabled: _imageEnabled,
      );

      await repository.saveStory(story);
      if (mounted) {
        context.go('/story-reader', extra: story);
      }
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final voice = context.watch<VoiceInputController>();

    return FutureBuilder<StoryCatalog>(
      future: context.read<StoryCatalogRepository>().loadCatalog(),
      builder: (context, snapshot) {
        final catalog = snapshot.data;

        if (catalog != null) {
          _hero ??= catalog.heroes.first;
          _location ??= catalog.locations.first;
          _storyType ??= catalog.storyTypes.first;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Story setup')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              DropdownButtonFormField<String>(
                initialValue: _storyLang,
                decoration: const InputDecoration(labelText: 'Language'),
                items: const <String>['en', 'ru', 'hy']
                    .map(
                      (lang) => DropdownMenuItem<String>(
                        value: lang,
                        child: Text(lang),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _storyLang = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _ageGroup,
                decoration: const InputDecoration(labelText: 'Age group'),
                items: const <String>['3_5', '6_8', '9_12']
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _ageGroup = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _storyLength,
                decoration: const InputDecoration(labelText: 'Length'),
                items: const <String>['short', 'medium', 'long']
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _storyLength = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              Text('Creativity: ${_creativity.toStringAsFixed(2)}'),
              Slider(
                min: 0,
                max: 1,
                divisions: 10,
                value: _creativity,
                onChanged: (value) {
                  setState(() {
                    _creativity = value;
                  });
                },
              ),
              SwitchListTile(
                value: _imageEnabled,
                title: const Text('Enable illustration request'),
                onChanged: (value) {
                  setState(() {
                    _imageEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              _StorageIconCarousel(
                title: 'Hero icons',
                files: _heroPreviewFiles,
                resolveUrl: StorageAssetService.heroUrl,
              ),
              const SizedBox(height: 8),
              _StorageIconCarousel(
                title: 'Location icons',
                files: _locationPreviewFiles,
                resolveUrl: StorageAssetService.locationUrl,
              ),
              const SizedBox(height: 8),
              _StorageIconCarousel(
                title: 'Style icons',
                files: _stylePreviewFiles,
                resolveUrl: StorageAssetService.styleUrl,
              ),
              const SizedBox(height: 12),
              if (catalog == null)
                const LinearProgressIndicator()
              else ...<Widget>[
                DropdownButtonFormField<String>(
                  initialValue: _hero,
                  decoration: const InputDecoration(labelText: 'Hero'),
                  items: catalog.heroes
                      .map(
                        (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    setState(() {
                      _hero = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _location,
                  decoration: const InputDecoration(labelText: 'Location'),
                  items: catalog.locations
                      .map(
                        (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    setState(() {
                      _location = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _storyType,
                  decoration: const InputDecoration(labelText: 'Story type'),
                  items: catalog.storyTypes
                      .map(
                        (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    setState(() {
                      _storyType = value;
                    });
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _ideaController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Idea (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: voice.isListening
                        ? null
                        : () async {
                            await voice.startListening();
                          },
                    child: const Text('Voice input'),
                  ),
                  OutlinedButton(
                    onPressed: voice.isListening
                        ? () async {
                            await voice.stopListening();
                            _ideaController.text = voice.lastText;
                            setState(() {});
                          }
                        : null,
                    child: const Text('Use recognized text'),
                  ),
                ],
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading || catalog == null ? null : _startStory,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Start'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StorageIconCarousel extends StatelessWidget {
  const _StorageIconCarousel({
    required this.title,
    required this.files,
    required this.resolveUrl,
  });

  final String title;
  final List<String> files;
  final Future<String> Function(String file) resolveUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: files.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return _StorageIconTile(imageUrlFuture: resolveUrl(files[index]));
            },
          ),
        ),
      ],
    );
  }
}

class _StorageIconTile extends StatelessWidget {
  const _StorageIconTile({required this.imageUrlFuture});

  final Future<String> imageUrlFuture;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: FutureBuilder<String>(
            future: imageUrlFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Image.network(
                  snapshot.data!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                );
              }

              return FutureBuilder<String>(
                future: StorageAssetService.placeholderUrl(),
                builder: (context, placeholderSnap) {
                  if (placeholderSnap.hasData && placeholderSnap.data != null) {
                    return Image.network(
                      placeholderSnap.data!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(Icons.image_not_supported_outlined),
                          ),
                    );
                  }

                  return const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
