import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

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
import '../story_setup/story_setup_icon_models.dart';
import '../story_setup/story_setup_icon_repository.dart';

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
  StorySetupIconCatalog _iconCatalog = const StorySetupIconCatalog.empty();
  bool _iconsLoading = true;
  bool _offlineCacheMissing = false;

  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedHeroFile = StorageAssetService.randomHero();
    _selectedLocationFile = StorageAssetService.randomLocation();
    _selectedStyleFile = StorageAssetService.randomStyle();
    unawaited(_loadIconCatalog());
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

  Future<void> _loadIconCatalog() async {
    final repository = context.read<StorySetupIconRepository>();
    final result = await repository.loadCatalog();
    final catalog = result.catalog;

    if (!mounted) {
      return;
    }

    setState(() {
      _iconCatalog = catalog;
      _iconsLoading = false;
      _offlineCacheMissing = result.cacheMissWhileOffline;

      if (catalog.heroes.isNotEmpty &&
          !catalog.heroes.any((icon) => icon.fileName == _selectedHeroFile)) {
        _selectedHeroFile = repository.pickInitialFileName(
          StorySetupIconCategory.hero,
          catalog,
        );
      }
      if (catalog.locations.isNotEmpty &&
          !catalog.locations.any(
            (icon) => icon.fileName == _selectedLocationFile,
          )) {
        _selectedLocationFile = repository.pickInitialFileName(
          StorySetupIconCategory.location,
          catalog,
        );
      }
      if (catalog.styles.isNotEmpty &&
          !catalog.styles.any((icon) => icon.fileName == _selectedStyleFile)) {
        _selectedStyleFile = repository.pickInitialFileName(
          StorySetupIconCategory.style,
          catalog,
        );
      }
    });

    if (catalog.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(
        repository.precacheThumbnails(catalog: catalog, maxPerCategory: 8),
      );
      _precacheVisibleThumbnails(catalog);
    });
  }

  void _precacheVisibleThumbnails(StorySetupIconCatalog catalog) {
    final icons = <StorySetupIcon>[
      ...catalog.heroes.take(6),
      ...catalog.locations.take(6),
      ...catalog.styles.take(6),
    ];

    for (final icon in icons) {
      final provider = _imageProviderFor(icon);
      if (provider == null) {
        continue;
      }
      unawaited(
        precacheImage(provider, context).catchError((_) {
          return null;
        }),
      );
    }
  }

  ImageProvider<Object>? _imageProviderFor(StorySetupIcon icon) {
    final localPath = icon.localPath?.trim();
    if (localPath != null && localPath.isNotEmpty) {
      return FileImage(File(localPath));
    }

    final url = icon.downloadUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return NetworkImage(url);
    }

    return null;
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
    final hasIcons = _iconCatalog.isNotEmpty;

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
            if (_iconsLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            if (_offlineCacheMissing)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Icons are not cached yet and this device is offline. '
                    'Connect once to load icons, then offline mode will use local cache only.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            if (!_iconsLoading && hasIcons) ...<Widget>[
              _CarouselSelector(
                title: l10n.storySetupHeroSection,
                icons: _iconCatalog.heroes,
                selectedFile: _selectedHeroFile,
                onSelected: (icon) {
                  setState(() {
                    _selectedHeroFile = icon.fileName;
                  });
                },
              ),
              const SizedBox(height: FairyCraftSpacing.section),
              _CarouselSelector(
                title: l10n.storySetupLocationSection,
                icons: _iconCatalog.locations,
                selectedFile: _selectedLocationFile,
                onSelected: (icon) {
                  setState(() {
                    _selectedLocationFile = icon.fileName;
                  });
                },
              ),
              const SizedBox(height: FairyCraftSpacing.section),
              _CarouselSelector(
                title: l10n.storySetupStyleSection,
                icons: _iconCatalog.styles,
                selectedFile: _selectedStyleFile,
                onSelected: (icon) {
                  setState(() {
                    _selectedStyleFile = icon.fileName;
                  });
                },
              ),
            ],
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
    required this.icons,
    required this.selectedFile,
    required this.onSelected,
  });

  final String title;
  final List<StorySetupIcon> icons;
  final String selectedFile;
  final ValueChanged<StorySetupIcon> onSelected;

  @override
  Widget build(BuildContext context) {
    return _PaginatedCarouselSelector(
      title: title,
      icons: icons,
      selectedFile: selectedFile,
      onSelected: onSelected,
    );
  }
}

class _PaginatedCarouselSelector extends StatefulWidget {
  const _PaginatedCarouselSelector({
    required this.title,
    required this.icons,
    required this.selectedFile,
    required this.onSelected,
  });

  final String title;
  final List<StorySetupIcon> icons;
  final String selectedFile;
  final ValueChanged<StorySetupIcon> onSelected;

  @override
  State<_PaginatedCarouselSelector> createState() =>
      _PaginatedCarouselSelectorState();
}

class _PaginatedCarouselSelectorState
    extends State<_PaginatedCarouselSelector> {
  static const int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();
  late int _visibleCount;

  @override
  void initState() {
    super.initState();
    _visibleCount = math.min(widget.icons.length, _pageSize);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _PaginatedCarouselSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.icons != widget.icons) {
      _visibleCount = math.min(widget.icons.length, _pageSize);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_visibleCount >= widget.icons.length) {
      return;
    }
    if (_scrollController.position.extentAfter > 280) {
      return;
    }

    setState(() {
      _visibleCount = math.min(widget.icons.length, _visibleCount + _pageSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.icons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: FairyCraftSpacing.element),
        SizedBox(
          height: 142,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _visibleCount,
            separatorBuilder: (context, index) =>
                const SizedBox(width: FairyCraftSpacing.element),
            itemBuilder: (context, index) {
              final icon = widget.icons[index];
              final selected = icon.fileName == widget.selectedFile;
              return SizedBox(
                width: 130,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => widget.onSelected(icon),
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
                          Expanded(child: _IconThumbnail(icon: icon)),
                          const SizedBox(height: 6),
                          Text(
                            icon.label,
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

class _IconThumbnail extends StatelessWidget {
  const _IconThumbnail({required this.icon});

  final StorySetupIcon icon;

  @override
  Widget build(BuildContext context) {
    final localPath = icon.localPath?.trim();
    if (localPath != null && localPath.isNotEmpty) {
      return Image.file(
        File(localPath),
        fit: BoxFit.contain,
        errorBuilder: _fallbackBuilder,
      );
    }

    final url = icon.downloadUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: _fallbackBuilder,
      );
    }

    return const Icon(Icons.image_not_supported_outlined);
  }

  Widget _fallbackBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const Icon(Icons.image_not_supported_outlined);
  }
}
