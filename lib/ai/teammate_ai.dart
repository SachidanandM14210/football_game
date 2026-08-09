import 'dart:math';
import '../engine/physics.dart';
import '../models/player.dart';

class TeammateAI {
  static void updatePositioning(
    List<Player> teammates,
    Player defender,
    double pitchCenterX,
    double pitchCenterY,
    double rondoRadius,
  ) {
    for (int idx = 0; idx < teammates.length; idx++) {
      final p = teammates[idx];
      final baseAngle = p.baseAngle != 0.0 ? p.baseAngle : (idx * (pi * 2 / 5));

      double shiftOffset = 0.0;
      final distToDefender = Physics.distance(p.x, p.y, defender.x, defender.y);

      if (distToDefender < rondoRadius * 0.9) {
        final defenderAngleOnCircle = Physics.angleBetween(pitchCenterX, pitchCenterY, defender.x, defender.y);
        final angleDiff = baseAngle - defenderAngleOnCircle;

        shiftOffset = (sin(angleDiff) >= 0 ? 1.0 : -1.0) * 0.22;
      }

      final targetAngle = baseAngle + shiftOffset;

      p.targetX = pitchCenterX + cos(targetAngle) * rondoRadius;
      p.targetY = pitchCenterY + sin(targetAngle) * rondoRadius;
      p.facingAngle = Physics.angleBetween(p.x, p.y, defender.x, defender.y);
    }
  }

  static Player? chooseSafestPassTarget(
    Player ballCarrier,
    List<Player> teammates,
    Player defender, {
    Player? passSender,
  }) {
    List<Player> candidates = teammates
        .where((p) => p.id != ballCarrier.id && (passSender == null || p.id != passSender.id))
        .toList();
    if (candidates.isEmpty) {
      candidates = teammates.where((p) => p.id != ballCarrier.id).toList();
    }
    if (candidates.isEmpty) return null;

    Player? bestCandidate;
    double highestSafetyScore = double.negativeInfinity;

    for (final candidate in candidates) {
      final passDist = Physics.distance(ballCarrier.x, ballCarrier.y, candidate.x, candidate.y);
      final defenderDistToPassLine = Physics.distanceToSegment(
        defender.x,
        defender.y,
        ballCarrier.x,
        ballCarrier.y,
        candidate.x,
        candidate.y,
      );

      final passAngle = Physics.angleBetween(ballCarrier.x, ballCarrier.y, candidate.x, candidate.y);
      final defAngle = Physics.angleBetween(ballCarrier.x, ballCarrier.y, defender.x, defender.y);
      double angleDiff = (passAngle - defAngle).abs();
      if (angleDiff > pi) angleDiff = 2 * pi - angleDiff;

      double safetyScore = (defenderDistToPassLine * 3.5) + (angleDiff * 45) - (passDist * 0.15);

      if (defenderDistToPassLine < 35.0 && angleDiff < 0.6) {
        safetyScore -= 300.0;
      }

      if (safetyScore > highestSafetyScore) {
        highestSafetyScore = safetyScore;
        bestCandidate = candidate;
      }
    }

    return bestCandidate;
  }
}
