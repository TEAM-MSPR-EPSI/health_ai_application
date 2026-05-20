import 'package:flutter/material.dart';
import 'package:health_ai_application/services/fake_social_repository.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    FakeSocialRepository.instance.addPost(text);
    _controller.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Actualité publiée avec succès.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une actualité')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Écris une publication comme dans une app sociale.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              minLines: 6,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Exemple : séance validée aujourd\'hui, objectif de la semaine, conseil nutrition...',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              label: const Text('Publier'),
            ),
          ],
        ),
      ),
    );
  }
}


