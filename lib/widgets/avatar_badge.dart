import 'package:flutter/material.dart';

class AvatarBadge extends StatelessWidget {
  final String? imageUrl;
  final String? emoji;
  final String fallbackLabel;
  final double radius;

  const AvatarBadge({
    super.key,
    required this.fallbackLabel,
    this.imageUrl,
    this.emoji,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final content = (imageUrl ?? '').isNotEmpty
        ? ClipOval(
            child: Image.network(
              imageUrl!,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _emojiOrInitial(context),
            ),
          )
        : _emojiOrInitial(context);

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: content,
    );
  }

  Widget _emojiOrInitial(BuildContext context) {
    final safeEmoji = (emoji ?? '').trim();
    if (safeEmoji.isNotEmpty) {
      return Text(
        safeEmoji,
        style: TextStyle(fontSize: radius * 0.95),
      );
    }
    final label = fallbackLabel.trim();
    return Text(
      label.isNotEmpty ? label[0].toUpperCase() : 'U',
      style: TextStyle(
        fontSize: radius * 0.8,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
