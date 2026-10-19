import 'package:flutter/material.dart';

import '../models/game.dart';

class GameStatusColors {
  const GameStatusColors({
    required this.wantToPlay,
    required this.playing,
    required this.finished,
    required this.dropped,
  });

  final Color wantToPlay;
  final Color playing;
  final Color finished;
  final Color dropped;

  factory GameStatusColors.forBrightness(Brightness brightness) {
    if (brightness == Brightness.light) {
      return const GameStatusColors(
        wantToPlay: Color(0xFF3555B8),
        playing: Color(0xFF8A5B00),
        finished: Color(0xFF326B50),
        dropped: Color(0xFF9B4944),
      );
    } else {
      return const GameStatusColors(
        wantToPlay: Color(0xFFAFC0FF),
        playing: Color(0xFFE9C36F),
        finished: Color(0xFF8FC9A0),
        dropped: Color(0xFFE99A97),
      );
    }
  }

  Color colorFor(GameStatus status) {
    if (status == GameStatus.backlog) {
      return wantToPlay;
    } else if (status == GameStatus.playing) {
      return playing;
    } else if (status == GameStatus.finished) {
      return finished;
    } else {
      return dropped;
    }
  }
}
