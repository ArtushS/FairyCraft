import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'story_setup_icon_models.dart';

class StorySetupIconFirestoreService {
  StorySetupIconFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<StorySetupIconCatalog> fetchCatalog({
    required bool offlineMode,
  }) async {
    if (offlineMode) {
      assert(() {
        throw StateError(
          'Firestore icon fetch attempted while offlineMode=true',
        );
      }());
      if (kDebugMode) {
        debugPrint(
          '[story-setup-icons] blocked Firestore request: offlineMode=true',
        );
      }
      return const StorySetupIconCatalog.empty();
    }

    final snapshot = await _firestore
        .collection('catalog')
        .doc('story_setup')
        .collection('icons')
        .get();

    if (snapshot.docs.isEmpty) {
      return const StorySetupIconCatalog.empty();
    }

    final heroes = <StorySetupIcon>[];
    final locations = <StorySetupIcon>[];
    final styles = <StorySetupIcon>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final category =
          _categoryFromDoc(doc.id, data['category']) ??
          StorySetupIconCategoryX.fromName(doc.id);
      final icons = _parseIcons(data, category);
      if (icons.isEmpty) {
        continue;
      }

      switch (category) {
        case StorySetupIconCategory.hero:
          heroes.addAll(icons);
        case StorySetupIconCategory.location:
          locations.addAll(icons);
        case StorySetupIconCategory.style:
          styles.addAll(icons);
      }
    }

    return StorySetupIconCatalog(
      heroes: _dedupe(heroes),
      locations: _dedupe(locations),
      styles: _dedupe(styles),
    );
  }

  StorySetupIconCategory? _categoryFromDoc(String docId, Object? rawCategory) {
    final raw = rawCategory?.toString().trim().toLowerCase();
    if (raw != null && raw.isNotEmpty) {
      if (raw.contains('hero')) {
        return StorySetupIconCategory.hero;
      }
      if (raw.contains('location') || raw.contains('place')) {
        return StorySetupIconCategory.location;
      }
      if (raw.contains('style') || raw.contains('type')) {
        return StorySetupIconCategory.style;
      }
    }

    final id = docId.trim().toLowerCase();
    if (id.contains('hero')) {
      return StorySetupIconCategory.hero;
    }
    if (id.contains('location') || id.contains('place')) {
      return StorySetupIconCategory.location;
    }
    if (id.contains('style') || id.contains('type')) {
      return StorySetupIconCategory.style;
    }
    return null;
  }

  List<StorySetupIcon> _parseIcons(
    Map<String, dynamic> data,
    StorySetupIconCategory category,
  ) {
    final rawList = _extractRawList(data);
    if (rawList.isEmpty) {
      return const <StorySetupIcon>[];
    }

    final icons = <StorySetupIcon>[];
    for (final item in rawList) {
      if (item is String) {
        final fileName = item.trim();
        if (fileName.isEmpty) {
          continue;
        }
        final storagePath = '${category.baseStoragePath}/$fileName';
        icons.add(
          StorySetupIcon(
            id: '${category.name}:$fileName',
            category: category,
            fileName: fileName,
            storagePath: storagePath,
            label: storySetupIconHumanLabel(fileName),
          ),
        );
        continue;
      }

      if (item is! Map) {
        continue;
      }

      final map = item.map((key, value) => MapEntry(key.toString(), value));
      final fileName =
          map['fileName']?.toString() ??
          map['file']?.toString() ??
          _fileNameFromPath(map['storagePath']?.toString()) ??
          _fileNameFromPath(map['path']?.toString());
      if (fileName == null || fileName.trim().isEmpty) {
        continue;
      }

      final storagePath =
          map['storagePath']?.toString() ??
          map['path']?.toString() ??
          '${category.baseStoragePath}/$fileName';
      final id = map['id']?.toString() ?? '${category.name}:$fileName';
      final label =
          map['label']?.toString() ??
          map['title']?.toString() ??
          storySetupIconHumanLabel(fileName);
      final downloadUrl =
          map['downloadUrl']?.toString() ?? map['url']?.toString();

      icons.add(
        StorySetupIcon(
          id: id,
          category: category,
          fileName: fileName,
          storagePath: storagePath,
          label: label,
          downloadUrl: downloadUrl?.trim().isNotEmpty == true
              ? downloadUrl
              : null,
        ),
      );
    }

    return icons;
  }

  List<dynamic> _extractRawList(Map<String, dynamic> data) {
    final candidates = <Object?>[
      data['items'],
      data['icons'],
      data['values'],
      data['files'],
      data['list'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate;
      }
    }
    return const <dynamic>[];
  }

  String? _fileNameFromPath(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }
    final index = path.lastIndexOf('/');
    if (index < 0 || index == path.length - 1) {
      return path;
    }
    return path.substring(index + 1);
  }

  List<StorySetupIcon> _dedupe(List<StorySetupIcon> icons) {
    final byId = <String, StorySetupIcon>{};
    for (final icon in icons) {
      byId[icon.id] = icon;
    }
    return byId.values.toList(growable: false);
  }
}
