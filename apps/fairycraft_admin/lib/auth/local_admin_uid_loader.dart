import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LocalAdminUidLoader {
  LocalAdminUidLoader({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const String localUidFilePath = '/local_admin_uids.json';

  Future<Set<String>> load() async {
    if (!kIsWeb) {
      return <String>{};
    }
    try {
      final response = await _httpClient.get(Uri.parse(localUidFilePath));
      if (response.statusCode != 200) {
        return <String>{};
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return <String>{};
      }

      final rawUids = decoded['uids'];
      if (rawUids is! List) {
        return <String>{};
      }

      return rawUids
          .map((uid) => uid.toString().trim())
          .where((uid) => uid.isNotEmpty)
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }
}
