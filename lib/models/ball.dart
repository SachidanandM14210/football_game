import 'dart:math';
import '../engine/physics.dart';
import 'player.dart';

class TrailPoint {
  double x;
  double y;
  double z;
  double alpha;

  TrailPoint({required this.x, required this.y, required this.z, required this.alpha});
}

class Ball {
  double x;
  double y;
  double z;
  double vx = 0;
  double vy = 0;
  double vz = 0;

  double radius = 8.0;
  double friction = 0.985;
  double gravity = 0.4;

  Player? owner;
  Player? passSender;
  Player? targetReceiver;

  bool isMoving = false;
  double speed = 0;

  final List<TrailPoint> trail = [];

  Ball({this.x = 0, this.y = 0, this.z = 0});

  void reset(double newX, double newY) {
    x = newX;
    y = newY;
    z = 0;
    vx = 0;
    vy = 0;
    vz = 0;
    owner = null;
    passSender = null;
    targetReceiver = null;
    isMoving = false;
    trail.clear();
  }

  void kick(Player fromPlayer, Player targetPlayer, {double power = 10.0, bool isLob = false}) {
    owner = null;
    passSender = fromPlayer;
    targetReceiver = targetPlayer;

    final angle = Physics.angleBetween(fromPlayer.x, fromPlayer.y, targetPlayer.x, targetPlayer.y);
    speed = power;

    vx = cos(angle) * power;
    vy = sin(angle) * power;
    vz = isLob ? 6.0 : 1.5;

    isMoving = true;
  }

  void update() {
    final currentOwner = owner;
    if (currentOwner != null) {
      const offsetDist = 12.0;
      final facingAngle = currentOwner.facingAngle;
      x = Physics.lerp(x, currentOwner.x + cos(facingAngle) * offsetDist, 0.4);
      y = Physics.lerp(y, currentOwner.y + sin(facingAngle) * offsetDist, 0.4);
      z = 0;
      vx = 0;
      vy = 0;
      vz = 0;
      isMoving = false;
      return;
    }

    if (isMoving) {
      x += vx;
      y += vy;

      z += vz;
      if (z > 0) {
        vz -= gravity;
      } else {
        z = 0;
        vz = -vz * 0.4;
        if (vz.abs() < 0.5) vz = 0;
      }

      vx *= friction;
      vy *= friction;

      speed = sqrt(vx * vx + vy * vy);

      if (speed < 0.2 && z <= 0) {
        isMoving = false;
        vx = 0;
        vy = 0;
      }

      if (speed > 2.0) {
        trail.insert(0, TrailPoint(x: x, y: y, z: z, alpha: 1.0));
        if (trail.length > 12) trail.removeLast();
      }
    }

    for (final t in trail) {
      t.alpha *= 0.85;
    }
  }
}
