import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../flutterio.dart';

class PlatformBlock extends SpriteComponent with HasGameRef<Flutterio> {
  final Vector2 velocity = Vector2.zero();
  final Vector2 gridPosition;
  double xOffset;

  PlatformBlock({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  Future<void> onLoad() async {
    final platformImage = game.images.fromCache('block.png');
    sprite = Sprite(platformImage);
    position = Vector2(
      (gridPosition.x * size.x) + xOffset,
      game.size.y - (gridPosition.y * size.y),
    );
    add( PolygonHitbox(
      [
        Vector2(0, 0),
        Vector2(64, 0),
        Vector2(64, 64),
        Vector2(0, 64),
      ],
    )..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;
    if (position.x < -size.x) removeFromParent();
    super.update(dt);
  }
}
