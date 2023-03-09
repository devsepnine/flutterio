import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'actors/rio.dart';
import 'actors/mushroom_enemy.dart';
import 'managers/segment_manager.dart';
import 'objects/ground_block.dart';
import 'objects/platform_block.dart';
import 'objects/star.dart';

class Flutterio extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  Flutterio();

  late double lastBlockXPosition = 0.0;
  late UniqueKey lastBlockKey;

  late FlutterioPlayer _rio;
  double objectSpeed = 0.0;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'block.png',
      'ember.png',
      'ground.png',
      'heart_half.png',
      'heart.png',
      'star.png',
      'mushroom.png',
      'zelda.png',
    ]);
    initializeGame();
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  void loadGameSegments(int segmentIndex, double xPositionOffset) {
    for (final block in segments[segmentIndex]) {
      switch (block.blockType) {
        case GroundBlock:
          add(GroundBlock(
              gridPosition: block.gridPosition, xOffset: xPositionOffset));
          break;
        case PlatformBlock:
          add(PlatformBlock(
              gridPosition: block.gridPosition, xOffset: xPositionOffset));
          break;
        case Star:
          add(Star(gridPosition: block.gridPosition, xOffset: xPositionOffset));
          break;
        case MushroomEnemy:
          add(MushroomEnemy(
              gridPosition: block.gridPosition, xOffset: xPositionOffset));
          break;
      }
    }
  }

  void initializeGame() {
    final segmentsToLoad = (size.x / 640).ceil();
    segmentsToLoad.clamp(0, segments.length);

    for (var i = 0; i <= segmentsToLoad; i++) {
      loadGameSegments(i, (640 * i).toDouble());
    }
    _rio = FlutterioPlayer(position: Vector2(60, canvasSize.y - 120));
    add(_rio);
  }
}
