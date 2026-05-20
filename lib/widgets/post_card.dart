import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:health_ai_application/models/post.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.post.mediaType == 'video' && widget.post.mediaUrl != null) {
      try {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.post.mediaUrl!))
          ..initialize().then((_) {
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
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    return 'il y a ${diff.inDays} j';
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(post.authorName.substring(0, 1)),
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
          ],
        ),
      ),
    );
  }
}


