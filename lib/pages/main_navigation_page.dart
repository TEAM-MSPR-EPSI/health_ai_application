import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health_ai_application/controllers/navigation_controller.dart';
import 'package:health_ai_application/pages/create_post_page.dart';
import 'package:health_ai_application/pages/feed_page.dart';
import 'package:health_ai_application/pages/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  final NavigationController _navigationController = Get.find<NavigationController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: _navigationController.currentIndex.value,
          children: const [
            FeedPage(key: PageStorageKey('feed-page')),
            CreatePostPage(key: PageStorageKey('create-post-page')),
            ProfilePage(key: PageStorageKey('profile-page')),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _navigationController.currentIndex.value,
          onDestinationSelected: _navigationController.setIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dynamic_feed_outlined),
              selectedIcon: Icon(Icons.dynamic_feed),
              label: 'Fil',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_box_outlined),
              selectedIcon: Icon(Icons.add_box),
              label: 'Publier',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Compte',
            ),
          ],
        ),
      ),
    );
  }
}


