import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:health_ai_application/services/fake_social_repository.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedMedia;
  String? _pickedMediaType; // 'image' or 'video'

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty && _pickedMedia == null) {
      // prevent empty post when no media attached
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter du texte ou une image/vidéo.')),
      );
      return;
    }

    FakeSocialRepository.instance.addPost(
      text,
      mediaPath: _pickedMedia?.path,
      mediaType: _pickedMediaType,
    );
    _controller.clear();
    setState(() {
      _pickedMedia = null;
      _pickedMediaType = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Actualité publiée avec succès.')),
    );
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _pickedMedia = file;
      _pickedMediaType = 'image';
    });
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _pickedMedia = file;
      _pickedMediaType = 'video';
    });
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
            const SizedBox(height: 12),
            // Media picker row
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo),
                  label: const Text('Image'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _pickVideo,
                  icon: const Icon(Icons.videocam),
                  label: const Text('Vidéo'),
                ),
                const SizedBox(width: 12),
                if (_pickedMedia != null) Expanded(child: Text('Fichier: ${_pickedMedia!.name}')),
              ],
            ),
            const SizedBox(height: 12),
            if (_pickedMedia != null && _pickedMediaType == 'image')
              SizedBox(
                height: 200,
                child: Image.file(File(_pickedMedia!.path), fit: BoxFit.cover),
              ),
            if (_pickedMedia != null && _pickedMediaType == 'video')
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videocam, size: 36),
                    const SizedBox(height: 6),
                    Text('Vidéo sélectionnée : ${_pickedMedia!.name}'),
                  ],
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


