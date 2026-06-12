import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:health_ai_application/controllers/auth_controller.dart';
import 'package:health_ai_application/controllers/feed_controller.dart';
import 'package:health_ai_application/models/post.dart';
import 'package:health_ai_application/widgets/media_viewer.dart';
import 'package:health_ai_application/widgets/avatar_badge.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  double _videoVisibleFraction = 0;

  @override
  void initState() {
    super.initState();
    if (widget.post.mediaType == 'video' && widget.post.mediaUrl != null) {
      try {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.post.mediaUrl!))
          ..initialize().then((_) {
            if (!mounted) return;
            _videoController?.setLooping(true);
            setState(() {});
            _syncVideoPlayback();
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

  void _syncVideoPlayback() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (_videoVisibleFraction >= 0.5) {
      if (!controller.value.isPlaying) {
        controller.play();
      }
    } else if (controller.value.isPlaying) {
      controller.pause();
    }
  }

  Future<void> _openMediaViewer() async {
    final mediaUrl = widget.post.mediaUrl;
    final mediaType = widget.post.mediaType;
    if (mediaUrl == null || mediaType == null) return;

    _videoController?.pause();

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'media-viewer',
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return MediaViewer(mediaUrl: mediaUrl, mediaType: mediaType);
      },
    );

    _syncVideoPlayback();
  }

  Widget _buildVideoPreview() {
    final controller = _videoController;
    final isReady = controller != null && controller.value.isInitialized;

    return VisibilityDetector(
      key: ValueKey('video-${widget.post.id}'),
      onVisibilityChanged: (visibilityInfo) {
        _videoVisibleFraction = visibilityInfo.visibleFraction;
        _syncVideoPlayback();
        if (mounted) {
          setState(() {});
        }
      },
      child: GestureDetector(
        onTap: _openMediaViewer,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: isReady
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: controller.value.isPlaying ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 120),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.15),
                            child: const Center(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14),
                                  child: Icon(Icons.play_arrow, color: Colors.white, size: 42),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: FloatingActionButton.small(
                        heroTag: null,
                        onPressed: () {
                          setState(() {
                            if (controller.value.isPlaying) {
                              controller.pause();
                            } else {
                              controller.play();
                            }
                          });
                        },
                        child: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                      ),
                    ),
                  ],
                )
              : Container(
                  height: 200,
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }

  Future<bool> _checkFileSize(XFile file, {int maxMb = 10}) async {
    final sizeInBytes = await file.length();
    final sizeInMb = sizeInBytes / (1024 * 1024);

    if (sizeInMb > maxMb) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le fichier est trop volumineux (${sizeInMb.toStringAsFixed(1)} Mo). La limite est de $maxMb Mo.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _openEditSheet(FeedController feedController) async {
    final contentController = TextEditingController(text: widget.post.content);
    XFile? selectedMedia;
    String? selectedMediaType;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickImage() async {
              final choice = await showModalBottomSheet<ImageSource>(
                context: context,
                showDragHandle: true,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Galerie'),
                        onTap: () => Navigator.pop(context, ImageSource.gallery),
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Appareil photo'),
                        onTap: () => Navigator.pop(context, ImageSource.camera),
                      ),
                    ],
                  ),
                ),
              );
              if (choice == null) return;
              final file = await _picker.pickImage(source: choice);
              if (file == null) return;
              if (!(await _checkFileSize(file, maxMb: 5))) return;
              setModalState(() {
                selectedMedia = file;
                selectedMediaType = 'image';
              });
            }

            Future<void> pickVideo() async {
              final choice = await showModalBottomSheet<ImageSource>(
                context: context,
                showDragHandle: true,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.video_library),
                        title: const Text('Galerie'),
                        onTap: () => Navigator.pop(context, ImageSource.gallery),
                      ),
                      ListTile(
                        leading: const Icon(Icons.videocam),
                        title: const Text('Appareil photo'),
                        onTap: () => Navigator.pop(context, ImageSource.camera),
                      ),
                    ],
                  ),
                ),
              );
              if (choice == null) return;
              final file = await _picker.pickVideo(source: choice);
              if (file == null) return;
              if (!(await _checkFileSize(file, maxMb: 20))) return;
              setModalState(() {
                selectedMedia = file;
                selectedMediaType = 'video';
              });
            }

            void clearSelectedMedia() {
              setModalState(() {
                selectedMedia = null;
                selectedMediaType = null;
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
                      if (selectedMedia != null)
                        IconButton(
                          onPressed: clearSelectedMedia,
                          icon: const Icon(Icons.close),
                          tooltip: 'Supprimer le média sélectionné',
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
        content: const Text('Cette action est définitive.'),
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
              GestureDetector(
                onTap: _openMediaViewer,
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(post.mediaUrl!, fit: BoxFit.cover),
                  ),
                ),
              ),
            if (post.mediaUrl != null && post.mediaType == 'video')
              SizedBox(
                height: 220,
                width: double.infinity,
                child: _buildVideoPreview(),
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
                      useSafeArea: true,
                      showDragHandle: true,
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
                                  const Text('Commentaires de la publication', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                    child: Text(_isCommenting ? 'Enregistrement...' : 'Ajouter le commentaire'),
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


