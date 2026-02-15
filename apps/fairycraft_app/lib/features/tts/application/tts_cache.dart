import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/tts_request.dart';

class TtsCache {
  Directory? _cacheDirectory;

  Future<File?> getCachedFile(String key, {String extension = 'mp3'}) async {
    final directory = await _resolveCacheDirectory();
    final file = File('${directory.path}/$key.$extension');
    if (!await file.exists()) {
      return null;
    }
    return file;
  }

  Future<File> writeBytes({
    required String key,
    required Uint8List bytes,
    String extension = 'mp3',
  }) async {
    final directory = await _resolveCacheDirectory();
    final file = File('${directory.path}/$key.$extension');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  String buildChunkCacheKey({
    required TtsRequest request,
    required String textChunk,
  }) {
    final source = <String, dynamic>{
      'text': textChunk,
      'voiceId': request.voiceId,
      'languageCode': request.languageCode,
      'speed': request.speed.toStringAsFixed(3),
      'pitch': request.intensity.toStringAsFixed(3),
      'format': request.outputFormat,
      'sampleRate': request.sampleRate,
      'qualityPreset': request.qualityPreset,
    };
    final digest = sha256.convert(utf8.encode(jsonEncode(source)));
    return digest.toString();
  }

  Future<Directory> _resolveCacheDirectory() async {
    if (_cacheDirectory != null) {
      return _cacheDirectory!;
    }

    final root = await getTemporaryDirectory();
    final cacheDirectory = Directory('${root.path}/voicemaker_tts_cache');
    if (!await cacheDirectory.exists()) {
      await cacheDirectory.create(recursive: true);
    }

    _cacheDirectory = cacheDirectory;
    return cacheDirectory;
  }
}
