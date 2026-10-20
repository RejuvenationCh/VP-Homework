import 'package:flutter/material.dart';

class GameStatusTheme extends ThemeExtension<GameStatusTheme> {
  const GameStatusTheme({
    required this.toPlay,
    required this.playing,
    required this.finished,
    required this.dropped,
  });

  final Color toPlay;
  final Color playing;
  final Color finished;
  final Color dropped;

  factory GameStatusTheme.forBrightness(Brightness brightness) {
    if (brightness == Brightness.light) {
      return const GameStatusTheme(
        toPlay: Color(0xFF3555B8),
        playing: Color(0xFF8A5B00),
        finished: Color(0xFF326B50),
        dropped: Color(0xFF9B4944),
      );
    } else {
      return const GameStatusTheme(
        toPlay: Color(0xFFAFC0FF),
        playing: Color(0xFFE9C36F),
        finished: Color(0xFF8FC9A0),
        dropped: Color(0xFFE99A97),
      );
    }
  }

  @override
  GameStatusTheme copyWith({
    Color? toPlay,
    Color? playing,
    Color? finished,
    Color? dropped,
  }) {
    return GameStatusTheme(
      toPlay: _keepColor(toPlay, this.toPlay),
      playing: _keepColor(playing, this.playing),
      finished: _keepColor(finished, this.finished),
      dropped: _keepColor(dropped, this.dropped),
    );
  }

  @override
  GameStatusTheme lerp(covariant GameStatusTheme? other, double t) {
    if (other == null) return this;
    return GameStatusTheme(
      toPlay: Color.lerp(toPlay, other.toPlay, t)!,
      playing: Color.lerp(playing, other.playing, t)!,
      finished: Color.lerp(finished, other.finished, t)!,
      dropped: Color.lerp(dropped, other.dropped, t)!,
    );
  }
}

Color _keepColor(Color? value, Color previous) {
  if (value == null) {
    return previous;
  } else {
    return value;
  }
}
