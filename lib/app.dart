import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health_ai_application/controllers/auth_controller.dart';
import 'package:health_ai_application/controllers/feed_controller.dart';
import 'package:health_ai_application/controllers/navigation_controller.dart';
import 'package:health_ai_application/pages/login_page.dart';
import 'package:health_ai_application/pages/main_navigation_page.dart';
import 'package:health_ai_application/services/auth_api_service.dart';
import 'package:health_ai_application/services/social_api_service.dart';
import 'package:health_ai_application/services/user_api_service.dart';
import 'theme/app_theme.dart';

class HealthAiApp extends StatelessWidget {
  const HealthAiApp({super.key});

  void _initDependencies() {
    if (!Get.isRegistered<AuthApiService>()) {
      Get.put(AuthApiService(), permanent: true);
    }
    if (!Get.isRegistered<UserApiService>()) {
      Get.put(UserApiService(), permanent: true);
    }
    if (!Get.isRegistered<SocialApiService>()) {
      Get.put(SocialApiService(), permanent: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put(
        AuthController(
          authApiService: Get.find<AuthApiService>(),
          userApiService: Get.find<UserApiService>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<FeedController>()) {
      Get.put(
        FeedController(
          socialApiService: Get.find<SocialApiService>(),
          authController: Get.find<AuthController>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<NavigationController>()) {
      Get.put(NavigationController(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    _initDependencies();
    final authController = Get.find<AuthController>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthAI Mobile',
      theme: AppTheme.lightTheme,
      home: Obx(
        () => authController.token.value == null
            ? const LoginPage()
            : const MainNavigationPage(),
      ),
    );
  }
}


