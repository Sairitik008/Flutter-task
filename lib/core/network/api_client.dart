import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/app_exception.dart';

class ApiClient {
  ApiClient({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  Future<Map<String, dynamic>> getJson(Uri uri) async {
    final response = await _send(() => _client.get(uri, headers: _headers));
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> postJson(
    Uri uri, {
    required Map<String, Object?> body,
  }) async {
    final response = await _send(
      () => _client.post(uri, headers: _headers, body: jsonEncode(body)),
    );
    return _decodeResponse(response);
  }

  static const _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(const Duration(seconds: 15));
    } on TimeoutException catch (error) {
      throw AppException(
        'The request timed out. Check your connection and try again.',
        cause: error,
      );
    } on http.ClientException catch (error) {
      throw AppException(
        'Could not connect to the service. Check your connection and try again.',
        cause: error,
      );
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    late final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (error) {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AppException(
          'The service returned an error (${response.statusCode}). Please try again.',
          cause: error,
        );
      }
      throw AppException(
        'The service returned invalid data. Please try again later.',
        cause: error,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const AppException(
        'The service returned data in an unexpected format.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded['message'];
      throw AppException(
        message is String && message.isNotEmpty
            ? message
            : 'The service returned an error (${response.statusCode}). Please try again.',
      );
    }
    return decoded;
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
