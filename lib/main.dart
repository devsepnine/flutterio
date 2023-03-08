import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import 'flutterio.dart';

void main() {
  final game = FlameGame();
  runApp(const GameWidget<Flutterio>.controlled(
    gameFactory: Flutterio.new,
  ));
}
