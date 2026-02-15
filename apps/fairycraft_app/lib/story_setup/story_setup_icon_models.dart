class StorySetupIcon {
  const StorySetupIcon({
    required this.id,
    required this.category,
    required this.fileName,
    required this.storagePath,
    required this.label,
    this.downloadUrl,
    this.localPath,
  });

  final String id;
  final StorySetupIconCategory category;
  final String fileName;
  final String storagePath;
  final String label;
  final String? downloadUrl;
  final String? localPath;

  StorySetupIcon copyWith({
    String? id,
    StorySetupIconCategory? category,
    String? fileName,
    String? storagePath,
    String? label,
    String? downloadUrl,
    String? localPath,
  }) {
    return StorySetupIcon(
      id: id ?? this.id,
      category: category ?? this.category,
      fileName: fileName ?? this.fileName,
      storagePath: storagePath ?? this.storagePath,
      label: label ?? this.label,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      localPath: localPath ?? this.localPath,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'category': category.name,
      'fileName': fileName,
      'storagePath': storagePath,
      'label': label,
      'downloadUrl': downloadUrl,
      'localPath': localPath,
    };
  }

  factory StorySetupIcon.fromJson(Map<String, dynamic> json) {
    return StorySetupIcon(
      id: json['id']?.toString() ?? '',
      category: StorySetupIconCategoryX.fromName(
        json['category']?.toString() ?? '',
      ),
      fileName: json['fileName']?.toString() ?? '',
      storagePath: json['storagePath']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      downloadUrl: json['downloadUrl']?.toString(),
      localPath: json['localPath']?.toString(),
    );
  }
}

class StorySetupIconCatalog {
  const StorySetupIconCatalog({
    required this.heroes,
    required this.locations,
    required this.styles,
  });

  const StorySetupIconCatalog.empty()
    : heroes = const <StorySetupIcon>[],
      locations = const <StorySetupIcon>[],
      styles = const <StorySetupIcon>[];

  final List<StorySetupIcon> heroes;
  final List<StorySetupIcon> locations;
  final List<StorySetupIcon> styles;

  bool get isEmpty => heroes.isEmpty && locations.isEmpty && styles.isEmpty;

  bool get isNotEmpty => !isEmpty;

  StorySetupIconCatalog copyWith({
    List<StorySetupIcon>? heroes,
    List<StorySetupIcon>? locations,
    List<StorySetupIcon>? styles,
  }) {
    return StorySetupIconCatalog(
      heroes: heroes ?? this.heroes,
      locations: locations ?? this.locations,
      styles: styles ?? this.styles,
    );
  }

  List<StorySetupIcon> iconsFor(StorySetupIconCategory category) {
    switch (category) {
      case StorySetupIconCategory.hero:
        return heroes;
      case StorySetupIconCategory.location:
        return locations;
      case StorySetupIconCategory.style:
        return styles;
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'heroes': heroes.map((icon) => icon.toJson()).toList(),
      'locations': locations.map((icon) => icon.toJson()).toList(),
      'styles': styles.map((icon) => icon.toJson()).toList(),
    };
  }

  factory StorySetupIconCatalog.fromJson(Map<String, dynamic> json) {
    List<StorySetupIcon> parseList(Object? raw) {
      if (raw is! List) {
        return const <StorySetupIcon>[];
      }
      return raw
          .whereType<Map>()
          .map(
            (item) => StorySetupIcon.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(growable: false);
    }

    return StorySetupIconCatalog(
      heroes: parseList(json['heroes']),
      locations: parseList(json['locations']),
      styles: parseList(json['styles']),
    );
  }
}

enum StorySetupIconCategory { hero, location, style }

extension StorySetupIconCategoryX on StorySetupIconCategory {
  String get segment {
    switch (this) {
      case StorySetupIconCategory.hero:
        return 'hero';
      case StorySetupIconCategory.location:
        return 'location';
      case StorySetupIconCategory.style:
        return 'style';
    }
  }

  String get baseStoragePath => 'icons/$segment';

  static StorySetupIconCategory fromName(String name) {
    final normalized = name.trim().toLowerCase();
    if (normalized == 'hero' || normalized == 'heroes') {
      return StorySetupIconCategory.hero;
    }
    if (normalized == 'location' || normalized == 'locations') {
      return StorySetupIconCategory.location;
    }
    return StorySetupIconCategory.style;
  }
}

enum StorySetupIconCatalogSource {
  cache,
  firestore,
  offlineCacheMiss,
  fallback,
}

class StorySetupIconCatalogResult {
  const StorySetupIconCatalogResult({
    required this.catalog,
    required this.source,
  });

  final StorySetupIconCatalog catalog;
  final StorySetupIconCatalogSource source;

  bool get cacheMissWhileOffline =>
      source == StorySetupIconCatalogSource.offlineCacheMiss;
}

String storySetupIconHumanLabel(String value) {
  return value.replaceAll('.png', '').replaceAll('_', ' ').trim();
}
