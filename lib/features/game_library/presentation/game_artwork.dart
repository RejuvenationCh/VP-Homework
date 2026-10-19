import 'package:flutter/material.dart';

class GameArtwork extends StatelessWidget {
  const GameArtwork({
    super.key,
    required this.imageUrl,
    this.width = 100,
    this.height = 56,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final String? imageUrl;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: ClipRRect(borderRadius: borderRadius, child: _image(context)),
  );

  Widget _image(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _placeholder(context, false);
    } else {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          } else {
            return _placeholder(context, true);
          }
        },
        errorBuilder: (context, error, stackTrace) =>
            _placeholder(context, false),
      );
    }
  }

  Widget _placeholder(BuildContext context, bool loading) {
    final colors = Theme.of(context).colorScheme;
    Widget child;
    if (loading) {
      child = const SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      child = Icon(
        Icons.videogame_asset_outlined,
        size: 36,
        color: colors.onSurfaceVariant,
      );
    }
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(child: child),
    );
  }
}
