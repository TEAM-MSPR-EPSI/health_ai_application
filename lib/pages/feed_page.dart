import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health_ai_application/controllers/auth_controller.dart';
import 'package:health_ai_application/controllers/feed_controller.dart';
import 'package:health_ai_application/widgets/frosted_surface.dart';
import 'package:health_ai_application/widgets/post_card.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final feedController = Get.find<FeedController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 72,
        title: const Text('Fil d\'actualité'),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackdrop()),
          Obx(
            () {
              if (feedController.isLoading.value && feedController.posts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: feedController.loadPosts,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Obx(
                      () {
                        final warning = authController.bootstrapError.value;
                        if (warning == null || warning.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            warning,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        );
                      },
                    ),
                    const FrostedSurface(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Vos publications, images et vidéos sont synchronisées en temps réel depuis le service social.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ...feedController.posts.map((post) => PostCard(post: post)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


