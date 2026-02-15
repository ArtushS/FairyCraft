import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'story_setup_icon_models.dart';

class StorySetupIconCacheStore {
  StorySetupIconCacheStore();

  static const String _catalogCacheKey = 'story_setup_icon_catalog_v1';

  SharedPreferences? _prefs;
  Directory? _iconDirectory;

  Future<StorySetupIconCatalog?> readCatalog() async {
    final prefs = await _resolvePreferences();
    final raw = prefs.getString(_catalogCacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return StorySetupIconCatalog.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeCatalog(StorySetupIconCatalog catalog) async {
    final prefs = await _resolvePreferences();
    await prefs.setString(_catalogCacheKey, jsonEncode(catalog.toJson()));
  }

  String buildStableFileKey(StorySetupIcon icon) {
    final seed = <String>[
      icon.id,
      icon.category.name,
      icon.fileName,
      icon.storagePath,
      icon.downloadUrl ?? '',
    ].join('|');
    return sha256.convert(utf8.encode(seed)).toString();
  }

  Future<String?> getExistingFilePath({
    required String stableKey,
    required String extension,
  }) async {
    final directory = await _resolveIconDirectory();
    final file = File('${directory.path}/$stableKey.$extension');
    if (!await file.exists()) {
      return null;
    }
    return file.path;
  }

  Future<String> writeBytes({
    required String stableKey,
    required String extension,
    required Uint8List bytes,
  }) async {
    final directory = await _resolveIconDirectory();
    final file = File('${directory.path}/$stableKey.$extension');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<SharedPreferences> _resolvePreferences() async {
    if (_prefs != null) {
      return _prefs!;
    }
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<Directory> _resolveIconDirectory() async {
    if (_iconDirectory != null) {
      return _iconDirectory!;
    }

    final root = await getApplicationSupportDirectory();
    final iconDirectory = Directory('${root.path}/story_setup_icon_cache');
    if (!await iconDirectory.exists()) {
      await iconDirectory.create(recursive: true);
    }

    _iconDirectory = iconDirectory;
    return iconDirectory;
  }
}
