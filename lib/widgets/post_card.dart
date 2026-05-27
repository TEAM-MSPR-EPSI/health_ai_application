import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:health_ai_application/controllers/auth_controller.dart';
import 'package:health_ai_application/controllers/feed_controller.dart';
import 'package:health_ai_application/models/post.dart';
import 'package:health_ai_application/widgets/avatar_badge.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _videoController;
  final _commentController = TextEditingController();
  bool _isCommenting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.post.mediaType == 'video' && widget.post.mediaUrl != null) {
      try {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.post.mediaUrl!))
          ..initialize().then((_) {
            if (!mounted) return;
            setState(() {});
          });
      } catch (_) {
        // ignore initialization errors for now
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    return 'il y a ${diff.inDays} j';
  }

  Future<void> _openEditSheet(FeedController feedController) async {
    final contentController = TextEditingController(text: widget.post.content);
    XFile? selectedMedia;
    String? selectedMediaType;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickImage() async {
              final file = await _picker.pickImage(source: ImageSource.gallery);
              if (file == null) return;
              setModalState(() {
                selectedMedia = file;
                selectedMediaType = 'image';
              });
            }

            Future<void> pickVideo() async {
              final file = await _picker.pickVideo(source: ImageSource.gallery);
              if (file == null) return;
              setModalState(() {
                selectedMedia = file;
                selectedMediaType = 'video';
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Modifier la publication', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(hintText: 'Texte de la publication'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.photo),
                        label: const Text('Image'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: pickVideo,
                        icon: const Icon(Icons.videocam),
                        label: const Text('Vidéo'),
                      ),
                    ],
                  ),
                  if (selectedMedia != null) ...[
                    const SizedBox(height: 12),
                    Text('Fichier: ${selectedMedia!.name}'),
                    const SizedBox(height: 8),
                    if (selectedMediaType == 'image')
                      SizedBox(height: 180, child: Image.file(File(selectedMedia!.path), fit: BoxFit.cover)),
                    if (selectedMediaType == 'video')
                      Container(
                        height: 120,
                        alignment: Alignment.center,
                        color: Colors.black12,
                        child: const Icon(Icons.videocam, size: 48),
                      ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      final content = contentController.text.trim();
                      if (content.isEmpty && selectedMedia == null) return;
                      await feedController.updatePost(
                        postId: widget.post.id,
                        content: content,
                        media: selectedMedia,
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    contentController.dispose();
  }

  Future<void> _confirmDelete(FeedController feedController) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la publication ?'),
        content: const Text('Cette action est definitive.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      await feedController.deletePost(widget.post.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final feedController = Get.find<FeedController>();
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser.value;
    final canEdit = currentUser?.id == post.authorUserId;
    final canDelete = canEdit || currentUser?.isAdmin == true;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarBadge(
                  radius: 22,
                  fallbackLabel: post.authorName,
                  imageUrl: post.authorAvatarUrl,
                  emoji: post.authorAvatarEmoji,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${post.authorHandle} • ${_formatDate(post.createdAt)}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (post.authorRole == 'admin')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'ADMIN',
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (canEdit || canDelete)
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await _openEditSheet(feedController);
                          }
                          if (value == 'delete') {
                            await _confirmDelete(feedController);
                          }
                        },
                        itemBuilder: (context) => [
                          if (canEdit)
                            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                          if (canDelete)
                            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content, style: const TextStyle(fontSize: 15, height: 1.4)),
            if (post.mediaUrl != null) const SizedBox(height: 12),
            if (post.mediaUrl != null && post.mediaType == 'image')
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(post.mediaUrl!, fit: BoxFit.cover),
                ),
              ),
            if (post.mediaUrl != null && post.mediaType == 'video')
              SizedBox(
                height: 220,
                width: double.infinity,
                child: _videoController != null && _videoController!.value.isInitialized
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!)),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: FloatingActionButton.small(
                              onPressed: () {
                                setState(() {
                                  if (_videoController!.value.isPlaying) {
                                    _videoController!.pause();
                                  } else {
                                    _videoController!.play();
                                  }
                                });
                              },
                              child: Icon(_videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)),
                        child: const Center(child: Icon(Icons.videocam, size: 48)),
                      ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await feedController.toggleLike(post.id);
                  },
                  icon: Icon(post.likedByMe ? Icons.favorite : Icons.favorite_border, color: post.likedByMe ? Colors.red : null),
                  label: Text('${post.likeCount}'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                          ),
                          child: StatefulBuilder(
                            builder: (context, setModalState) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Commentaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxHeight: 260),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: post.comments.length,
                                      itemBuilder: (context, index) {
                                        final comment = post.comments[index];
                                        return ListTile(
                                          leading: AvatarBadge(
                                            radius: 16,
                                            fallbackLabel: comment.authorName,
                                            imageUrl: comment.authorAvatarUrl,
                                            emoji: comment.authorAvatarEmoji,
                                          ),
                                          title: Row(
                                            children: [
                                              Expanded(child: Text(comment.authorName)),
                                              if (comment.authorRole == 'admin')
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade100,
                                                    borderRadius: BorderRadius.circular(999),
                                                  ),
                                                  child: Text(
                                                    'ADMIN',
                                                    style: TextStyle(
                                                      color: Colors.red.shade800,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          subtitle: Text(comment.content),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _commentController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(hintText: 'Ajouter un commentaire...'),
                                  ),
                                  const SizedBox(height: 8),
                                  FilledButton(
                                    onPressed: _isCommenting
                                        ? null
                                        : () async {
                                            final content = _commentController.text.trim();
                                            if (content.isEmpty) return;
                                            setState(() => _isCommenting = true);
                                            try {
                                              await feedController.addComment(post.id, content);
                                              _commentController.clear();
                                              if (context.mounted) Navigator.pop(context);
                                            } finally {
                                              if (mounted) setState(() => _isCommenting = false);
                                            }
                                          },
                                    child: Text(_isCommenting ? 'Ajout...' : 'Publier'),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.mode_comment_outlined),
                  label: Text('${post.commentCount}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


