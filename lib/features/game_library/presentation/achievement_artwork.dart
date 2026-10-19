import 'package:flutter/material.dart';

class AchievementArtwork extends StatelessWidget {
  const AchievementArtwork({super.key, required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _placeholder(context, false);
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            } else {
              return _placeholder(context, true);
            }
          },
          errorBuilder: (context, error, stackTrace) {
            return _placeholder(context, false);
          },
        ),
      );
    }
  }

  Widget _placeholder(BuildContext context, bool loading) {
    final colors = Theme.of(context).colorScheme;
    Widget child;
    if (loading) {
      child = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      child = Icon(Icons.emoji_events_outlined, color: colors.onSurfaceVariant);
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: child),
    );
  }
}
