import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/nav.dart';
import '../features/stt/presentation/voice_input_field.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../settings/settings_controller.dart';
import '../shared/services/storage_asset_service.dart';
import '../shared/ui/fairycraft_theme.dart';
import '../story/shared_preferences_story_repository.dart';
import '../story/story_preferences_controller.dart';
import '../story/story_service.dart';

class StorySetupPage extends StatefulWidget {
  const StorySetupPage({super.key});

  @override
  State<StorySetupPage> createState() => _StorySetupPageState();
}

class _StorySetupPageState extends State<StorySetupPage> {
  final TextEditingController _ideaController = TextEditingController();

  late String _selectedHeroFile;
  late String _selectedLocationFile;
  late String _selectedStyleFile;

  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedHeroFile = StorageAssetService.randomHero();
    _selectedLocationFile = StorageAssetService.randomLocation();
    _selectedStyleFile = StorageAssetService.randomStyle();
  }

  @override
  void dispose() {
    _ideaController.dispose();
    super.dispose();
  }

  Future<void> _generateStory() async {
    final l10n = context.l10n;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final prefs = context.read<StoryPreferencesController>();
    final settings = context.read<SettingsController>();
    final storyService = context.read<StoryService>();
    final repository = context.read<SharedPreferencesStoryRepository>();

    try {
      final story = await storyService.generateStory(
        storyLang: settings.defaultLanguageCode,
        ageGroup: prefs.ageGroupCode,
        storyLength: prefs.storyLengthCode,
        creativityLevel: prefs.creativity,
        hero: prefs.heroName.isNotEmpty
            ? prefs.heroName
            : _labelFromFile(_selectedHeroFile),
        location: _labelFromFile(_selectedLocationFile),
        storyType: _labelFromFile(_selectedStyleFile),
        idea: _ideaController.text.trim().isEmpty
            ? null
            : _ideaController.text.trim(),
        imageEnabled: prefs.autoIllustrations,
      );

      await repository.saveStory(story);
      if (mounted) {
        Nav.toStoryReader(context, story);
      }
    } catch (error) {
      setState(() {
        _errorMessage = _friendlyError(error.toString(), l10n);
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  String _labelFromFile(String file) {
    return file.replaceAll('.png', '').replaceAll('_', ' ').trim();
  }

  String _friendlyError(String raw, AppLocalizations l10n) {
    final normalized = raw.toLowerCase();
    if (normalized.contains('network') || normalized.contains('socket')) {
      return l10n.storySetupErrorNetwork;
    }
    return l10n.storySetupErrorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prefs = context.watch<StoryPreferencesController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.storySetupTitle),
        actions: <Widget>[
          IconButton(
            onPressed: () => Nav.toStoryPreferences(context),
            icon: const Icon(Icons.tune_rounded),
            tooltip: l10n.storySetupPreferencesTooltip,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: FairyCraftSpacing.page,
          children: <Widget>[
            Text(
              l10n.storySetupIdeaTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: FairyCraftSpacing.element),
            VoiceInputField(
              controller: _ideaController,
              hintText: l10n.storySetupIdeaHint,
            ),
            const SizedBox(height: FairyCraftSpacing.section),
            Card(
              child: SwitchListTile(
                value: prefs.familyMode,
                title: Text(l10n.storySetupFamilyMode),
                subtitle: Text(l10n.storySetupFamilyModeSubtitle),
                onChanged: prefs.setFamilyMode,
              ),
            ),
            const SizedBox(height: FairyCraftSpacing.section),
            _CarouselSelector(
              title: l10n.storySetupHeroSection,
              files: StorageAssetService.heroIcons,
              selectedFile: _selectedHeroFile,
              resolveUrl: StorageAssetService.heroUrl,
              onSelected: (file) {
                setState(() {
                  _selectedHeroFile = file;
                });
              },
            ),
            const SizedBox(height: FairyCraftSpacing.section),
            _CarouselSelector(
              title: l10n.storySetupLocationSection,
              files: StorageAssetService.locationIcons,
              selectedFile: _selectedLocationFile,
              resolveUrl: StorageAssetService.locationUrl,
              onSelected: (file) {
                setState(() {
                  _selectedLocationFile = file;
                });
              },
            ),
            const SizedBox(height: FairyCraftSpacing.section),
            _CarouselSelector(
              title: l10n.storySetupStyleSection,
              files: StorageAssetService.styleIcons,
              selectedFile: _selectedStyleFile,
              resolveUrl: StorageAssetService.styleUrl,
              onSelected: (file) {
                setState(() {
                  _selectedStyleFile = file;
                });
              },
            ),
            const SizedBox(height: FairyCraftSpacing.section),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: FairyCraftPalette.error,
                ),
              ),
            const SizedBox(height: 92),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: _submitting ? null : _generateStory,
          child: _submitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.storySetupGenerateButton),
        ),
      ),
    );
  }
}

class _CarouselSelector extends StatelessWidget {
  const _CarouselSelector({
    required this.title,
    required this.files,
    required this.selectedFile,
    required this.resolveUrl,
    required this.onSelected,
  });

  final String title;
  final List<String> files;
  final String selectedFile;
  final Future<String> Function(String file) resolveUrl;
  final ValueChanged<String> onSelected;

  String _labelFromFile(String file) {
    return file.replaceAll('.png', '').replaceAll('_', ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: FairyCraftSpacing.element),
        SizedBox(
          height: 142,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: files.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: FairyCraftSpacing.element),
            itemBuilder: (context, index) {
              final file = files[index];
              final selected = file == selectedFile;
              return SizedBox(
                width: 130,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onSelected(file),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: selected
                            ? FairyCraftPalette.secondary
                            : FairyCraftPalette.outline,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: FutureBuilder<String>(
                              future: resolveUrl(file),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Image.network(
                                    snapshot.data!,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => const Icon(
                                          Icons.image_not_supported_outlined,
                                        ),
                                  );
                                }
                                return const Center(
                                  child: SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _labelFromFile(file),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
