import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaViewer extends StatefulWidget {
  const MediaViewer({super.key, required this.mediaUrl, required this.mediaType});

  final String mediaUrl;
  final String mediaType;

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  VideoPlayerController? _videoController;
  Future<void>? _initialization;
  double _dragOffsetY = 0;

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == 'video') {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl));
      _initialization = _videoController!.initialize().then((_) {
        if (!mounted) return;
        _videoController!.setLooping(true);
        _videoController!.play();
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _close() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 250 || _dragOffsetY > 120) {
      _close();
      return;
    }

    setState(() {
      _dragOffsetY = 0;
    });
  }

  Widget _buildContent(BuildContext context) {
    if (widget.mediaType == 'image') {
      return GestureDetector(
        onTap: _close,
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Image.network(widget.mediaUrl, fit: BoxFit.contain),
        ),
      );
    }

    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        final controller = _videoController;
        if (controller == null || snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
            Positioned(
              bottom: 18,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (controller.value.isPlaying) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    });
                  },
                  iconSize: 36,
                  color: Colors.white,
                  icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.95),
      child: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _close,
          onVerticalDragUpdate: (details) {
            setState(() {
              _dragOffsetY = (_dragOffsetY + details.delta.dy).clamp(0, double.infinity);
            });
          },
          onVerticalDragEnd: _handleVerticalDragEnd,
          child: SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.only(
                      top: _dragOffsetY * 0.05,
                      bottom: _dragOffsetY * 0.05,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildContent(context),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _close,
                      icon: const Icon(Icons.close, color: Colors.white),
                      tooltip: 'Fermer',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
