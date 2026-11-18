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
    late final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
    } on TimeoutException catch (error) {
      throw AppException(
        'The request timed out. Check your connection and try again.',
        cause: error,
      );
    } on http.ClientException catch (error) {
      throw AppException(
        'Could not connect to the product service. Check your connection and try again.',
        cause: error,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(
        'The product service returned an error (${response.statusCode}). Please try again.',
      );
    }

    late final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (error) {
      throw AppException(
        'The product service returned invalid data. Please try again later.',
        cause: error,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const AppException(
        'The product service returned data in an unexpected format.',
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
