import 'dart:math';
import 'package:flutter/material.dart';
import '../engine/physics.dart';

class Player {
  final int id;
  final String name;
  final String role; // 'attacker' or 'defender'
  bool isHuman;
  final int number;
  final Color jerseyColor;
  final Color secondaryColor;
  final Color hairColor;
  final Color skinColor;
  final Color? stripeColor;
  final bool beard;
  final Color? headband;
  final bool ponytail;
  final Color? armband;
  final String style;

  double x = 0;
  double y = 0;
  double vx = 0;
  double vy = 0;

  double radius = 20.0;
  double baseSpeed = 3.0;
  double facingAngle = 0.0;

  double baseAngle = 0.0;
  double targetX = 0.0;
  double targetY = 0.0;

  int passCooldown = 0;
  bool hasBall = false;

  Player({
    required this.id,
    required this.name,
    this.role = 'attacker',
    this.isHuman = false,
    required this.number,
    required this.jerseyColor,
    this.secondaryColor = Colors.white,
    this.hairColor = const Color(0xFF1A1A1A),
    this.skinColor = const Color(0xFFF5CDA7),
    this.stripeColor,
    this.beard = false,
    this.headband,
    this.ponytail = false,
    this.armband,
    this.style = 'default',
  }) {
    baseSpeed = role == 'defender' ? 3.4 : 3.0;
  }

  void setPosition(double newX, double newY) {
    x = newX;
    y = newY;
    targetX = newX;
    targetY = newY;
  }

  void update(double pitchCenterX, double pitchCenterY, double rondoRadius) {
    if (passCooldown > 0) passCooldown--;

    final dx = targetX - x;
    final dy = targetY - y;
    final dist = sqrt(dx * dx + dy * dy);

    if (dist > 1.0) {
      final moveSpeed = min(baseSpeed, dist * 0.15);
      vx = (dx / dist) * moveSpeed;
      vy = (dy / dist) * moveSpeed;
      x += vx;
      y += vy;
    } else {
      vx = 0;
      vy = 0;
    }

    if (role == 'attacker') {
      final distFromCenter = Physics.distance(x, y, pitchCenterX, pitchCenterY);
      if ((distFromCenter - rondoRadius).abs() > 40.0) {
        final angle = Physics.angleBetween(pitchCenterX, pitchCenterY, x, y);
        x = pitchCenterX + cos(angle) * rondoRadius;
        y = pitchCenterY + sin(angle) * rondoRadius;
      }
    }
  }
}
