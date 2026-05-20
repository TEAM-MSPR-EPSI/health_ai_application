import 'dart:convert';

import 'package:get/get.dart';
import 'package:health_ai_application/services/api_config.dart';

class AuthApiService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = ApiConfig.baseUrl;
    httpClient.timeout = const Duration(seconds: 20);
    super.onInit();
  }

  Future<String> login({required String email, required String password}) async {
    final response = await post('/api/auth/login', {
      'email': email,
      'password': password,
    });

    if (!response.isOk || response.body == null) {
      final statusCode = response.statusCode;
      final details = response.bodyString ?? response.statusText ?? 'Aucun detail';
      throw Exception('Echec login (HTTP $statusCode): $details');
    }

    final body = response.body is Map
        ? response.body as Map
        : jsonDecode(response.bodyString ?? '{}') as Map;

    final token = body['token']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('Token manquant dans la reponse API.');
    }

    return token;
  }
}
