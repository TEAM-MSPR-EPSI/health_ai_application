import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:health_ai_application/models/user_profile.dart';
import 'package:health_ai_application/services/api_config.dart';

class UserApiService {
  Future<UserProfile> getMe(String token) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/users/me');
      final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      return UserProfile.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } on SocketException catch (error) {
      throw Exception('Profil impossible à joindre depuis cet appareil: ${error.message}');
    } on TimeoutException {
      throw Exception('Délai dépassé pendant le chargement du profil.');
    }
  }

  Future<UserProfile> updateMe(String token, UserProfile profile) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/users/me');
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profile.toUpdateJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      return UserProfile.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } on SocketException catch (error) {
      throw Exception('Mise à jour du profil impossible depuis cet appareil: ${error.message}');
    } on TimeoutException {
      throw Exception('Délai dépassé pendant la mise à jour du profil.');
    }
  }

  Future<UserProfile> updateAvatar({
    required String token,
    XFile? image,
    String? emoji,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/users/me/avatar');
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token';

      if (emoji != null && emoji.trim().isNotEmpty) {
        request.fields['avatarEmoji'] = emoji.trim();
      }

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('avatar', image.path));
      }

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        throw Exception('HTTP ${streamed.statusCode}: $body');
      }

      return UserProfile.fromJson(jsonDecode(body) as Map<String, dynamic>);
    } on SocketException catch (error) {
      throw Exception('Avatar impossible à joindre depuis cet appareil: ${error.message}');
    } on TimeoutException {
      throw Exception('Délai dépassé pendant la mise à jour de l’avatar.');
    }
  }
}
