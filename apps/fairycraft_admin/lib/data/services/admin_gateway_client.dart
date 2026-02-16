import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../data/models/admin_test_input.dart';

class DryRunResult {
  const DryRunResult({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final Map<String, dynamic> body;

  bool get ok => statusCode >= 200 && statusCode < 300;
}

class AdminGatewayClient {
  AdminGatewayClient({
    required String baseUrl,
    required Future<String?> Function() idTokenProvider,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl,
        _idTokenProvider = idTokenProvider,
        _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final Future<String?> Function() _idTokenProvider;
  final http.Client _httpClient;

  Future<DryRunResult> runDryRun(AdminTestInput input) async {
    final token = await _idTokenProvider();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final uri = Uri.parse('$_baseUrl/v1/admin/dry-run');
    final response = await _httpClient.post(
      uri,
      headers: headers,
      body: jsonEncode(input.toJson()),
    );

    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return DryRunResult(statusCode: response.statusCode, body: body);
      }
    } catch (_) {
      // Fall through to safe fallback payload.
    }

    return DryRunResult(
      statusCode: response.statusCode,
      body: <String, dynamic>{
        'ok': false,
        'error': 'invalid_gateway_response',
        'rawBody': response.body,
      },
    );
  }
}
