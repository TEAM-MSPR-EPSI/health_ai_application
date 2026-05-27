import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:health_ai_application/controllers/auth_controller.dart';
import 'package:health_ai_application/models/post.dart';
import 'package:health_ai_application/services/social_api_service.dart';

class FeedController extends GetxController {
  FeedController({required this.socialApiService, required this.authController});

  final SocialApiService socialApiService;
  final AuthController authController;

  final RxList<Post> posts = <Post>[].obs;
  final RxList<Post> myPosts = <Post>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> loadPostsWithToken(String token) async {
    isLoading.value = true;
    try {
      posts.assignAll(await socialApiService.getPosts(token: token));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMyPostsWithToken(String token) async {
    myPosts.assignAll(await socialApiService.getMyPosts(token: token));
  }

  Future<void> loadPosts() async {
    final token = authController.token.value;
    if (token == null) return;
    await loadPostsWithToken(token);
  }

  Future<void> loadMyPosts() async {
    final token = authController.token.value;
    if (token == null) return;
    await loadMyPostsWithToken(token);
  }

  Future<void> createPost({required String content, XFile? media}) async {
    final token = authController.token.value;
    if (token == null) throw Exception('Utilisateur non connecte.');
    await socialApiService.createPost(token: token, content: content, media: media);
    await loadPosts();
    await loadMyPosts();
  }

  Future<void> toggleLike(String postId) async {
    final token = authController.token.value;
    if (token == null) throw Exception('Utilisateur non connecte.');
    final updated = await socialApiService.toggleLike(token: token, postId: postId);
    _replacePost(updated);
  }

  Future<void> addComment(String postId, String content) async {
    final token = authController.token.value;
    if (token == null) throw Exception('Utilisateur non connecte.');
    final updated = await socialApiService.addComment(token: token, postId: postId, content: content);
    _replacePost(updated);
  }

  Future<void> updatePost({required String postId, required String content, XFile? media}) async {
    final token = authController.token.value;
    if (token == null) throw Exception('Utilisateur non connecte.');
    final updated = await socialApiService.updatePost(token: token, postId: postId, content: content, media: media);
    _replacePost(updated);
    await loadMyPosts();
  }

  Future<void> deletePost(String postId) async {
    final token = authController.token.value;
    if (token == null) throw Exception('Utilisateur non connecte.');
    await socialApiService.deletePost(token: token, postId: postId);
    posts.removeWhere((post) => post.id == postId);
    myPosts.removeWhere((post) => post.id == postId);
  }

  void _replacePost(Post updated) {
    final index = posts.indexWhere((post) => post.id == updated.id);
    if (index >= 0) {
      posts[index] = updated;
      posts.refresh();
    }
    final personalIndex = myPosts.indexWhere((post) => post.id == updated.id);
    if (personalIndex >= 0) {
      myPosts[personalIndex] = updated;
      myPosts.refresh();
    }
  }
}
