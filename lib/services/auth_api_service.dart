import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:health_ai_application/services/api_config.dart';

class AuthApiService {
  Future<String> login({required String email, required String password}) async {
    try {
      final uri = ApiConfig.buildApiUri('/api/auth/login');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Echec login (HTTP ${response.statusCode}): ${response.body}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final token = body['token']?.toString();
      if (token == null || token.isEmpty) {
        throw Exception('Token manquant dans la reponse API.');
      }

      return token;
    } on SocketException catch (error) {
      throw Exception('API inaccessible depuis cet appareil: ${error.message}');
    } on TimeoutException {
      throw Exception('Délai dépassé en contactant l’API. Vérifie l’IP du PC, le Wi-Fi partagé et le pare-feu.');
    } on HttpException catch (error) {
      throw Exception('Erreur HTTP réseau: ${error.message}');
    } on FormatException catch (error) {
      throw Exception(error.message);
    }
  }
}
