import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../shared/services/storage_asset_service.dart';
import 'story_setup_icon_cache_store.dart';
import 'story_setup_icon_firestore_service.dart';
import 'story_setup_icon_models.dart';

class StorySetupIconRepository {
  StorySetupIconRepository({
    required StorySetupIconFirestoreService firestoreService,
    required StorySetupIconCacheStore cacheStore,
    required http.Client httpClient,
    Connectivity? connectivity,
    Duration? firestoreTimeout,
    Duration? downloadTimeout,
  }) : _firestoreService = firestoreService,
       _cacheStore = cacheStore,
       _httpClient = httpClient,
       _connectivity = connectivity ?? Connectivity(),
       _firestoreTimeout = firestoreTimeout ?? const Duration(seconds: 4),
       _downloadTimeout = downloadTimeout ?? const Duration(seconds: 8);

  final StorySetupIconFirestoreService _firestoreService;
  final StorySetupIconCacheStore _cacheStore;
  final http.Client _httpClient;
  final Connectivity _connectivity;
  final Duration _firestoreTimeout;
  final Duration _downloadTimeout;

  Future<StorySetupIconCatalogResult> loadCatalog() async {
    final cachedCatalog = await _cacheStore.readCatalog();
    if (cachedCatalog != null && cachedCatalog.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[story-setup-icons] cache hit; skipping Firestore and serving local data.',
        );
      }
      return StorySetupIconCatalogResult(
        catalog: cachedCatalog,
        source: StorySetupIconCatalogSource.cache,
      );
    }

    final offlineMode = await _isOffline();
    if (offlineMode) {
      if (kDebugMode) {
        debugPrint(
          '[story-setup-icons] cache miss + offline mode; no Firestore request.',
        );
      }
      return const StorySetupIconCatalogResult(
        catalog: StorySetupIconCatalog.empty(),
        source: StorySetupIconCatalogSource.offlineCacheMiss,
      );
    }

    StorySetupIconCatalog remoteCatalog;
    try {
      remoteCatalog = await _firestoreService
          .fetchCatalog(offlineMode: false)
          .timeout(_firestoreTimeout);
    } catch (_) {
      remoteCatalog = const StorySetupIconCatalog.empty();
    }

    if (remoteCatalog.isEmpty) {
      final fallback = _defaultCatalog();
      final hydratedFallback = await _hydrateCatalog(
        fallback,
        allowDownloads: true,
      );
      await _cacheStore.writeCatalog(hydratedFallback);
      return StorySetupIconCatalogResult(
        catalog: hydratedFallback,
        source: StorySetupIconCatalogSource.fallback,
      );
    }

    final hydratedCatalog = await _hydrateCatalog(
      remoteCatalog,
      allowDownloads: true,
    );
    await _cacheStore.writeCatalog(hydratedCatalog);
    return StorySetupIconCatalogResult(
      catalog: hydratedCatalog,
      source: StorySetupIconCatalogSource.firestore,
    );
  }

  Future<void> precacheThumbnails({
    required StorySetupIconCatalog catalog,
    int maxPerCategory = 8,
  }) async {
    final heroes = catalog.heroes.take(maxPerCategory);
    final locations = catalog.locations.take(maxPerCategory);
    final styles = catalog.styles.take(maxPerCategory);
    final selected = <StorySetupIcon>[...heroes, ...locations, ...styles];
    if (selected.isEmpty) {
      return;
    }

    await _hydrateIcons(selected, allowDownloads: true);
  }

  StorySetupIconCatalog _defaultCatalog() {
    List<StorySetupIcon> fromFiles(
      StorySetupIconCategory category,
      List<String> files,
    ) {
      return files
          .map(
            (fileName) => StorySetupIcon(
              id: '${category.name}:$fileName',
              category: category,
              fileName: fileName,
              storagePath: '${category.baseStoragePath}/$fileName',
              label: storySetupIconHumanLabel(fileName),
            ),
          )
          .toList(growable: false);
    }

    return StorySetupIconCatalog(
      heroes: fromFiles(
        StorySetupIconCategory.hero,
        StorageAssetService.heroIcons,
      ),
      locations: fromFiles(
        StorySetupIconCategory.location,
        StorageAssetService.locationIcons,
      ),
      styles: fromFiles(
        StorySetupIconCategory.style,
        StorageAssetService.styleIcons,
      ),
    );
  }

  Future<StorySetupIconCatalog> _hydrateCatalog(
    StorySetupIconCatalog catalog, {
    required bool allowDownloads,
  }) async {
    final heroes = await _hydrateIcons(
      catalog.heroes,
      allowDownloads: allowDownloads,
    );
    final locations = await _hydrateIcons(
      catalog.locations,
      allowDownloads: allowDownloads,
    );
    final styles = await _hydrateIcons(
      catalog.styles,
      allowDownloads: allowDownloads,
    );

    return catalog.copyWith(
      heroes: heroes,
      locations: locations,
      styles: styles,
    );
  }

  Future<List<StorySetupIcon>> _hydrateIcons(
    Iterable<StorySetupIcon> icons, {
    required bool allowDownloads,
  }) async {
    final result = <StorySetupIcon>[];
    for (final icon in icons) {
      result.add(
        await _hydrateSingleIcon(icon, allowDownloads: allowDownloads),
      );
    }
    return result;
  }

  Future<StorySetupIcon> _hydrateSingleIcon(
    StorySetupIcon icon, {
    required bool allowDownloads,
  }) async {
    final extension = _resolveExtension(icon);
    final stableKey = _cacheStore.buildStableFileKey(icon);
    final existingPath = await _cacheStore.getExistingFilePath(
      stableKey: stableKey,
      extension: extension,
    );
    if (existingPath != null) {
      return icon.copyWith(localPath: existingPath);
    }

    if (!allowDownloads) {
      return icon;
    }

    final downloadUrl = await _resolveDownloadUrl(icon);
    if (downloadUrl == null) {
      return icon;
    }

    try {
      final response = await _httpClient
          .get(Uri.parse(downloadUrl))
          .timeout(_downloadTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return icon.copyWith(downloadUrl: downloadUrl);
      }

      final path = await _cacheStore.writeBytes(
        stableKey: stableKey,
        extension: extension,
        bytes: response.bodyBytes,
      );
      return icon.copyWith(downloadUrl: downloadUrl, localPath: path);
    } catch (_) {
      return icon.copyWith(downloadUrl: downloadUrl);
    }
  }

  Future<String?> _resolveDownloadUrl(StorySetupIcon icon) async {
    final existing = icon.downloadUrl?.trim();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final storagePath = icon.storagePath.trim();
    if (storagePath.isEmpty) {
      return null;
    }

    try {
      return await StorageAssetService.getDownloadUrl(storagePath);
    } catch (_) {
      return null;
    }
  }

  String _resolveExtension(StorySetupIcon icon) {
    final fromFile = icon.fileName.trim();
    if (fromFile.contains('.')) {
      final index = fromFile.lastIndexOf('.');
      final ext = fromFile.substring(index + 1).toLowerCase();
      if (ext.isNotEmpty) {
        return ext;
      }
    }

    final fromUrl = icon.downloadUrl?.trim() ?? '';
    if (fromUrl.contains('.')) {
      final sanitized = fromUrl.split('?').first;
      final index = sanitized.lastIndexOf('.');
      if (index >= 0 && index < sanitized.length - 1) {
        return sanitized.substring(index + 1).toLowerCase();
      }
    }

    return 'png';
  }

  Future<bool> _isOffline() async {
    try {
      final Object result = await _connectivity.checkConnectivity();
      if (result is ConnectivityResult) {
        return result == ConnectivityResult.none;
      }
      if (result is List<ConnectivityResult>) {
        return !result.any((value) => value != ConnectivityResult.none);
      }
    } catch (_) {
      // If connectivity probing fails, allow the regular request path.
    }
    return false;
  }

  String pickInitialFileName(
    StorySetupIconCategory category,
    StorySetupIconCatalog catalog,
  ) {
    final icons = catalog.iconsFor(category);
    if (icons.isEmpty) {
      switch (category) {
        case StorySetupIconCategory.hero:
          return StorageAssetService.randomHero();
        case StorySetupIconCategory.location:
          return StorageAssetService.randomLocation();
        case StorySetupIconCategory.style:
          return StorageAssetService.randomStyle();
      }
    }
    return icons[math.Random().nextInt(icons.length)].fileName;
  }
}
