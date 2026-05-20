import 'package:get/get.dart';
import 'package:health_ai_application/models/user_profile.dart';
import 'package:health_ai_application/services/auth_api_service.dart';
import 'package:health_ai_application/services/user_api_service.dart';

class AuthController extends GetxController {
  AuthController({required this.authApiService, required this.userApiService});

  final AuthApiService authApiService;
  final UserApiService userApiService;

  final RxnString token = RxnString();
  final Rxn<UserProfile> currentUser = Rxn<UserProfile>();
  final RxBool isLoading = false.obs;

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final jwt = await authApiService.login(email: email, password: password);
      token.value = jwt;
      currentUser.value = await userApiService.getMe(jwt);
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

  void logout() {
    token.value = null;
    currentUser.value = null;
  }
}
