import 'dart:convert';

import 'package:data_catalog/core/errors/app_exception.dart';
import 'package:data_catalog/core/network/api_client.dart';
import 'package:data_catalog/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'sends login credentials to DummyJSON and requires an access token',
    () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url, Uri.https('dummyjson.com', '/auth/login'));
        expect(jsonDecode(request.body), {
          'username': 'emilys',
          'password': 'emilyspass',
        });
        return http.Response('{"accessToken":"demo-token"}', 200);
      });
      final apiClient = ApiClient(client: client);
      addTearDown(client.close);
      final repository = ApiAuthRepository(apiClient);

      await expectLater(
        repository.login(username: 'emilys', password: 'emilyspass'),
        completes,
      );
    },
  );

  test('surfaces authentication errors from the API', () async {
    final client = MockClient(
      (_) async => http.Response('{"message":"Invalid credentials"}', 401),
    );
    final apiClient = ApiClient(client: client);
    addTearDown(client.close);
    final repository = ApiAuthRepository(apiClient);

    await expectLater(
      repository.login(username: 'unknown', password: 'wrong-password'),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'Invalid credentials',
        ),
      ),
    );
  });

  test('posts registration fields to DummyJSON user-add endpoint', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url, Uri.https('dummyjson.com', '/users/add'));
      expect(jsonDecode(request.body), {
        'firstName': 'Taylor',
        'lastName': 'Lee',
        'username': 'taylorlee',
        'email': 'taylor@example.com',
        'password': 'password123',
      });
      return http.Response('{"id":101,"username":"taylorlee"}', 201);
    });
    final apiClient = ApiClient(client: client);
    addTearDown(client.close);
    final repository = ApiAuthRepository(apiClient);

    await expectLater(
      repository.register(
        firstName: 'Taylor',
        lastName: 'Lee',
        username: 'taylorlee',
        email: 'taylor@example.com',
        password: 'password123',
      ),
      completes,
    );
  });
}
