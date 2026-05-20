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
  final RxBool isLoading = false.obs;

  Future<void> loadPosts() async {
    isLoading.value = true;
    try {
      posts.assignAll(await socialApiService.getPosts());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPost({required String content, XFile? media}) async {
    final token = authController.token.value;
    if (token == null) throw Exception('Utilisateur non connecte.');
    await socialApiService.createPost(token: token, content: content, media: media);
    await loadPosts();
  }

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }
}
