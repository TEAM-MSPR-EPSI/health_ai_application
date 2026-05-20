import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health_ai_application/controllers/feed_controller.dart';
import 'package:health_ai_application/widgets/post_card.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final feedController = Get.find<FeedController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fil d\'actualité'),
      ),
      body: Obx(
        () {
          if (feedController.isLoading.value && feedController.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: feedController.loadPosts,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Fil social MongoDB: texte, photo et video partages en temps reel API.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ...feedController.posts.map((post) => PostCard(post: post)),
              ],
            ),
          );
        },
      ),
    );
  }
}


