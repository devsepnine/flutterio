import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';
import 'package:flutterio/actors/water_enemy.dart';
import 'package:flutterio/objects/star.dart';
import 'package:flutterio/objects/ground_block.dart';
import 'package:flutterio/objects/platform_block.dart';
import 'package:flutterio/flutterio.dart';

class FlutterioPlayer extends SpriteAnimationComponent
    with CollisionCallbacks, KeyboardHandler, HasGameRef<Flutterio> {
  FlutterioPlayer({required super.position})
      : super(size: Vector2.all(64), anchor: Anchor.center);

  final Vector2 velocity = Vector2.zero();
  final double moveSpeed = 200;
  final double gravity = 15;
  final double jumpSpeed = 600;
  final double terminalVelocity = 250;
  final Vector2 fromAbove = Vector2(0, -1);

  bool isOnGround = false;
  bool hasJumped = false;
  bool hitByEnemy = false;
  int horizontalDirection = 0;

  @override
  Future<void> onLoad() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('ember.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.12,
      ),
    );
    add(CircleHitbox());
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalDirection = 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyA) ||
            (keysPressed.contains(LogicalKeyboardKey.arrowLeft))
        ? -1
        : 0);
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyD) ||
            (keysPressed.contains(LogicalKeyboardKey.arrowRight))
        ? 1
        : 0);
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    return true;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GroundBlock || other is PlatformBlock) {
      if (intersectionPoints.length == 2) {
        // 충돌 분리 거리 계산
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionNormal = absoluteCenter - mid;
        final separationDistance = (size.x / 2) - collisionNormal.length;
        collisionNormal.normalize();

        // 그라운드 충돌일 경우 플레이어는 땅위에 있어야 한다
        if (fromAbove.dot(collisionNormal) > 0.9) {
          isOnGround = true;
        }

        // 플레이어 이동으로 충돌 해결
        position += collisionNormal.scaled(separationDistance);
      }
    }
    if (other is Star) {
      other.removeFromParent();
    }

    if (other is WaterEnemy) {
      hit();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void update(dt) {
    velocity.x = horizontalDirection * moveSpeed;
    velocity.y += gravity;
    // Prevent ember from jumping to crazy fast as well as descending too fast and
    // crashing through the ground or a platform.
    velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);
    if (hasJumped) {
      if (isOnGround) {
        velocity.y = -jumpSpeed;
        isOnGround = false;
      }
    }
    if (horizontalDirection < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection > 0 && scale.x < 0) {
      flipHorizontally();
    }
    game.objectSpeed = 0;
    // Prevent ember from going backwards at screen edge.
    if (position.x - 36 <= 0 && horizontalDirection < 0) {
      velocity.x = 0;
    }
    // Prevent ember from going beyond half screen.
    if (position.x + 64 >= game.size.x / 2 && horizontalDirection > 0) {
      velocity.x = 0;
      game.objectSpeed = -moveSpeed;
    }

    position += velocity * dt;
    super.update(dt);
  }

  void hit() {
    if (!hitByEnemy) {
      hitByEnemy = true;
    }
    add(OpacityEffect.fadeOut(
      EffectController(
        alternate: true,
        duration: 0.1,
        repeatCount: 6,
      ),
    )..onComplete = () {
        hitByEnemy = false;
      });
  }
}
