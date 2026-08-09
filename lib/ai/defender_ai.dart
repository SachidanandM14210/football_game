import '../engine/physics.dart';
import '../models/ball.dart';
import '../models/player.dart';

class DifficultyConfig {
  final double speed;
  final int reactionDelay;
  final double interceptionRadius;
  final double predictiveCut;
  final double pressAggression;

  const DifficultyConfig({
    required this.speed,
    required this.reactionDelay,
    required this.interceptionRadius,
    required this.predictiveCut,
    required this.pressAggression,
  });
}

class DefenderAI {
  static const Map<String, DifficultyConfig> difficultyConfigs = {
    'easy': DifficultyConfig(
      speed: 2.6,
      reactionDelay: 320,
      interceptionRadius: 28,
      predictiveCut: 0.2,
      pressAggression: 0.5,
    ),
    'medium': DifficultyConfig(
      speed: 3.3,
      reactionDelay: 180,
      interceptionRadius: 34,
      predictiveCut: 0.5,
      pressAggression: 0.75,
    ),
    'hard': DifficultyConfig(
      speed: 4.0,
      reactionDelay: 90,
      interceptionRadius: 40,
      predictiveCut: 0.8,
      pressAggression: 0.95,
    ),
    'pro': DifficultyConfig(
      speed: 4.6,
      reactionDelay: 30,
      interceptionRadius: 46,
      predictiveCut: 1.0,
      pressAggression: 1.2,
    ),
  };

  static void update(
    Player defender,
    Ball ball,
    List<Player> teammates,
    double pitchCenterX,
    double pitchCenterY, {
    String difficulty = 'medium',
    double deltaTime = 0.016,
  }) {
    final config = difficultyConfigs[difficulty] ?? difficultyConfigs['medium']!;
    defender.baseSpeed = config.speed;

    if (ball.isMoving) {
      final ballStartX = ball.x;
      final ballStartY = ball.y;
      final ballEndX = ball.x + ball.vx * 20.0 * config.predictiveCut;
      final ballEndY = ball.y + ball.vy * 20.0 * config.predictiveCut;

      final interceptTarget = Physics.closestPointOnSegment(
        defender.x,
        defender.y,
        ballStartX,
        ballStartY,
        ballEndX,
        ballEndY,
      );

      defender.targetX = Physics.lerp(defender.x, interceptTarget.x, 0.2);
      defender.targetY = Physics.lerp(defender.y, interceptTarget.y, 0.2);
      defender.facingAngle = Physics.angleBetween(defender.x, defender.y, ball.x, ball.y);
      return;
    }

    final ballOwner = ball.owner;
    if (ballOwner != null) {
      defender.targetX = ballOwner.x;
      defender.targetY = ballOwner.y;
      defender.facingAngle = Physics.angleBetween(defender.x, defender.y, ballOwner.x, ballOwner.y);
      return;
    }

    defender.targetX = pitchCenterX;
    defender.targetY = pitchCenterY;
  }
}
