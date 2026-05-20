import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:health_ai_application/models/post.dart';
import 'package:health_ai_application/services/api_config.dart';

class SocialApiService {
  Future<List<Post>> getPosts() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/social-posts');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le fil social.');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Post.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createPost({
    required String token,
    required String content,
    XFile? media,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/social-posts');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['content'] = content;

    if (media != null) {
      request.files.add(await http.MultipartFile.fromPath('media', media.path));
    }

    final streamed = await request.send();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      final body = await streamed.stream.bytesToString();
      throw Exception('Publication echouee: $body');
    }
  }
}
