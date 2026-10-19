import 'package:flutter/material.dart';

class GameArtwork extends StatelessWidget {
  const GameArtwork({super.key, required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return SizedBox(width: 100, height: 56, child: _buildImage(context, url));
  }

  Widget _buildImage(BuildContext context, String? url) {
    if (url == null || url.isEmpty) {
      return _buildPlaceholder(context, false);
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            } else {
              return _buildPlaceholder(context, true);
            }
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(context, false);
          },
        ),
      );
    }
  }

  Widget _buildPlaceholder(BuildContext context, bool loading) {
    final colors = Theme.of(context).colorScheme;
    Widget child;
    if (loading) {
      child = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      child = Icon(
        Icons.videogame_asset_outlined,
        color: colors.onSurfaceVariant,
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: child),
    );
  }
}
