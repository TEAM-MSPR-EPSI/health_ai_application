import 'dart:convert';

import 'package:get/get.dart';
import 'package:health_ai_application/models/user_profile.dart';
import 'package:health_ai_application/services/api_config.dart';

class UserApiService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = ApiConfig.baseUrl;
    httpClient.timeout = const Duration(seconds: 20);
    super.onInit();
  }

  Future<UserProfile> getMe(String token) async {
    final response = await get(
      '/api/users/me',
      headers: {'Authorization': 'Bearer $token'},
    );

    if (!response.isOk || response.body == null) {
      throw Exception('Impossible de recuperer le profil utilisateur.');
    }

    final body = response.body is Map
        ? response.body as Map<String, dynamic>
        : jsonDecode(response.bodyString ?? '{}') as Map<String, dynamic>;

    return UserProfile.fromJson(body);
  }

  Future<UserProfile> updateMe(String token, UserProfile profile) async {
    final response = await put(
      '/api/users/me',
      profile.toUpdateJson(),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (!response.isOk || response.body == null) {
      throw Exception('Impossible de mettre a jour le profil.');
    }

    final body = response.body is Map
        ? response.body as Map<String, dynamic>
        : jsonDecode(response.bodyString ?? '{}') as Map<String, dynamic>;

    return UserProfile.fromJson(body);
  }
}
