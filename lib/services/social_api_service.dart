import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:health_ai_application/models/post.dart';
import 'package:health_ai_application/services/api_config.dart';

class SocialApiService {
  Future<List<Post>> getPosts({required String token}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/social-posts');
    final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le fil social.');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Post.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Post>> getMyPosts({required String token}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/social-posts/me');
    final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger vos publications.');
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

  Future<Post> toggleLike({
    required String token,
    required String postId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/social-posts/$postId/like');
    final response = await http.post(uri, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de liker la publication.');
    }

    return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Post> addComment({
    required String token,
    required String postId,
    required String content,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/social-posts/$postId/comments');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible d\'ajouter le commentaire.');
    }

    return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Post> updatePost({
    required String token,
    required String postId,
    required String content,
    XFile? media,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/social-posts/$postId');
    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['content'] = content;

    if (media != null) {
      request.files.add(await http.MultipartFile.fromPath('media', media.path));
    }

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception('Impossible de modifier la publication: $body');
    }

    return Post.fromJson(jsonDecode(body) as Map<String, dynamic>);
  }

  Future<void> deletePost({
    required String token,
    required String postId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/social-posts/$postId');
    final response = await http.delete(uri, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de supprimer la publication.');
    }
  }
}
