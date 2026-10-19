enum ConstraintCase {
  longName('Filename width'),
  shortTile('Tile height'),
  actionRow('Selection bar');

  const ConstraintCase(this.label);
  final String label;
}

enum GameConstraintCase {
  longName('Game name width'),
  shortTile('Game tile height'),
  actionRow('Game action row');

  const GameConstraintCase(this.label);
  final String label;
}

class GameConstraintPreview {
  const GameConstraintPreview({required this.type, required this.showError});

  final GameConstraintCase type;
  final bool showError;

  bool get showActionOverflow =>
      type == GameConstraintCase.actionRow && showError;
}
