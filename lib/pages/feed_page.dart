import 'package:flutter/material.dart';
import 'package:health_ai_application/services/fake_social_repository.dart';
import 'package:health_ai_application/widgets/post_card.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    final posts = FakeSocialRepository.instance.getPosts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fil d\'actualité'),
      ),
      body: ListView(
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
              'Base mobile MSPR 3 : tu peux déjà lire le fil, créer une actualité et modifier ton profil.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ...posts.map((post) => PostCard(post: post)),
        ],
      ),
    );
  }
}


