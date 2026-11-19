import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';

abstract interface class AuthRepository {
  Future<void> login({required String username, required String password});

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  });
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._apiClient);

  static final _loginUri = Uri.https('dummyjson.com', '/auth/login');
  static final _registerUri = Uri.https('dummyjson.com', '/users/add');

  final ApiClient _apiClient;

  @override
  Future<void> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.postJson(
      _loginUri,
      body: {'username': username, 'password': password},
    );
    final token = response['accessToken'];
    if (token is! String || token.isEmpty) {
      throw const AppException(
        'The authentication service returned an unexpected response.',
      );
    }
  }

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.postJson(
      _registerUri,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'password': password,
      },
    );
    if (response['id'] is! int) {
      throw const AppException(
        'The registration service returned an unexpected response.',
      );
    }
  }
}
