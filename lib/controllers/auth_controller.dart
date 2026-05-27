import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:health_ai_application/models/user_profile.dart';
import 'package:health_ai_application/controllers/feed_controller.dart';
import 'package:health_ai_application/controllers/navigation_controller.dart';
import 'package:health_ai_application/services/auth_api_service.dart';
import 'package:health_ai_application/services/user_api_service.dart';

class AuthController extends GetxController {
  AuthController({required this.authApiService, required this.userApiService});

  final AuthApiService authApiService;
  final UserApiService userApiService;

  final RxnString token = RxnString();
  final Rxn<UserProfile> currentUser = Rxn<UserProfile>();
  final RxnString bootstrapError = RxnString();
  final RxBool isLoading = false.obs;

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    bootstrapError.value = null;
    try {
      final jwt = await authApiService.login(email: email, password: password);
      UserProfile profile;
      try {
        profile = await userApiService.getMe(jwt);
      } catch (error) {
        bootstrapError.value = 'Connexion OK, mais le profil ne répond pas: $error';
        rethrow;
      }

      token.value = jwt;
      currentUser.value = profile;

      if (Get.isRegistered<FeedController>()) {
        final feedController = Get.find<FeedController>();
        try {
          await feedController.loadPostsWithToken(jwt);
          await feedController.loadMyPostsWithToken(jwt);
        } catch (error) {
          bootstrapError.value = 'Connexion OK, mais le chargement du fil a échoué: $error';
          Get.snackbar(
            'Connexion partielle',
            'Le profil est chargé, mais le fil social n’a pas pu être récupéré.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }

      if (Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().setIndex(0);
      }
    } catch (error) {
      logout(clearBootstrapError: false);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshMe() async {
    final jwt = token.value;
    if (jwt == null) return;
    currentUser.value = await userApiService.getMe(jwt);
  }

  Future<void> updateProfile(UserProfile profile) async {
    final jwt = token.value;
    if (jwt == null) throw Exception('Utilisateur non connecte.');
    currentUser.value = await userApiService.updateMe(jwt, profile);
  }

  Future<void> updateAvatar({String? emoji, XFile? image}) async {
    final jwt = token.value;
    if (jwt == null) throw Exception('Utilisateur non connecte.');
    currentUser.value = await userApiService.updateAvatar(
      token: jwt,
      emoji: emoji,
      image: image,
    );
    if (Get.isRegistered<FeedController>()) {
      await Get.find<FeedController>().loadPosts();
      await Get.find<FeedController>().loadMyPosts();
    }
  }

  void logout({bool clearBootstrapError = true}) {
    token.value = null;
    currentUser.value = null;
    if (clearBootstrapError) {
      bootstrapError.value = null;
    }
    if (Get.isRegistered<FeedController>()) {
      Get.find<FeedController>().posts.clear();
      Get.find<FeedController>().myPosts.clear();
    }
  }
}
