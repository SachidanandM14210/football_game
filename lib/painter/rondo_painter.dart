import 'dart:math';
import 'package:flutter/material.dart';
import '../engine/game_engine.dart';
import '../engine/physics.dart';
import '../models/ball.dart';
import '../models/player.dart';

class RondoPainter extends CustomPainter {
  final GameEngine game;

  RondoPainter(this.game) : super(repaint: game);

  @override
  void paint(Canvas canvas, Size size) {
    // 0. Clear Viewport
    final bgPaint = Paint()..color = const Color(0xFF06100B);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final pitchCenterX = size.width / 2;
    final pitchCenterY = size.height / 2;
    final rondoRadius = min(size.width, size.height) * 0.34;

    // 1. Draw Pitch
    drawPitch(canvas, pitchCenterX, pitchCenterY, rondoRadius);

    // 2. Draw Guidelines & Danger Cones
    if (game.showGuidelines && game.ball.owner != null) {
      drawGuidelines(canvas, game.ball.owner!, game.players, game.defender, game.hoveredTarget);
    }

    // 3. Draw Particles
    drawParticles(canvas);

    // 4. Draw Players
    for (final p in game.players) {
      drawPlayer(canvas, p, game.ball.owner == p, game.hoveredTarget == p);
    }

    // 5. Draw Defender
    if (game.defender != null) {
      drawDefender(canvas, game.defender!);
    }

    // 6. Draw Ball
    drawBall(canvas, game.ball, game.comboMultiplier);

    // 7. Draw Floating Texts
    drawFloatingTexts(canvas);
  }

  void drawPitch(Canvas canvas, double cx, double cy, double radius) {
    final pitchGrad = RadialGradient(
      colors: const [Color(0xFF0C2419), Color(0xFF071810), Color(0xFF040D09)],
      stops: const [0.0, 0.7, 1.0],
    );
    final pitchPaint = Paint()..shader = pitchGrad.createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius * 1.5));
    canvas.drawCircle(Offset(cx, cy), radius * 1.5, pitchPaint);

    // Circular Grass Rings
    const ringCount = 5;
    for (int i = ringCount; i >= 1; i--) {
      final ringPaint = Paint()
        ..color = i % 2 == 0 ? const Color(0x0500FF87) : const Color(0x0A000000);
      canvas.drawCircle(Offset(cx, cy), (radius * 1.4) * (i / ringCount), ringPaint);
    }

    // Rondo Boundary Line
    final boundaryPaint = Paint()
      ..color = const Color(0x4000FF87)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Dashed Boundary Line
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final circumference = 2 * pi * radius;
    final dashes = (circumference / (dashWidth + dashSpace)).floor();
    for (int i = 0; i < dashes; i++) {
      final startAngle = (i * (dashWidth + dashSpace)) / radius;
      final sweepAngle = dashWidth / radius;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle,
        sweepAngle,
        false,
        boundaryPaint,
      );
    }

    // Pitch Center Spot
    final centerSpotPaint = Paint()..color = const Color(0x6600FF87);
    canvas.drawCircle(Offset(cx, cy), 6.0, centerSpotPaint);

    // Inner Defender Zone
    final defenderZonePaint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), radius * 0.45, defenderZonePaint);
  }

  void drawGuidelines(Canvas canvas, Player carrier, List<Player> players, Player? defender, Player? hoveredTarget) {
    if (defender != null) {
      final defDist = Physics.distance(carrier.x, carrier.y, defender.x, defender.y);
      final defAngle = Physics.angleBetween(carrier.x, carrier.y, defender.x, defender.y);
      final coneWidth = min(0.6, 50.0 / max(1.0, defDist));

      final conePaint = Paint()..color = const Color(0x15FF3B5C);
      final path = Path()
        ..moveTo(carrier.x, carrier.y)
        ..arcTo(
          Rect.fromCircle(center: Offset(carrier.x, carrier.y), radius: 350.0),
          defAngle - coneWidth,
          coneWidth * 2,
          false,
        )
        ..close();
      canvas.drawPath(path, conePaint);
    }

    if (hoveredTarget != null && hoveredTarget.id != carrier.id) {
      final passLinePaint = Paint()
        ..color = const Color(0xB200E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawLine(Offset(carrier.x, carrier.y), Offset(hoveredTarget.x, hoveredTarget.y), passLinePaint);

      final targetRingPaint = Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(hoveredTarget.x, hoveredTarget.y), 24.0, targetRingPaint);
    }
  }

  void drawPlayer(Canvas canvas, Player p, bool hasBall, bool isHovered) {
    const headR = 24.0;

    // Drop Shadow
    final shadowPaint = Paint()..color = const Color(0x73000000);
    canvas.drawOval(Rect.fromCenter(center: Offset(p.x, p.y + 32), width: 44, height: 18), shadowPaint);

    // Active Glow / Target Ring
    if (hasBall) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFC800)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawCircle(Offset(p.x, p.y - 4), headR + 8, glowPaint);
    } else if (isHovered) {
      final hoverRingPaint = Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(Offset(p.x, p.y - 4), headR + 6, hoverRingPaint);
    }

    // Tiny Body & Kit
    final bodyY = p.y + 14;
    final jerseyPaint = Paint()..color = p.jerseyColor;
    canvas.drawRRect(RRect.fromLTRBR(p.x - 12, bodyY, p.x + 12, bodyY + 16, const Radius.circular(4)), jerseyPaint);

    // Collar
    final collarPaint = Paint()
      ..color = p.secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final collarPath = Path()
      ..moveTo(p.x - 6, bodyY)
      ..lineTo(p.x, bodyY + 6)
      ..lineTo(p.x + 6, bodyY);
    canvas.drawPath(collarPath, collarPaint);

    // Shorts & Legs
    final shortsPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(p.x - 10, bodyY + 16, 20, 6), shortsPaint);

    final skinPaint = Paint()..color = p.skinColor;
    canvas.drawRect(Rect.fromLTWH(p.x - 8, bodyY + 22, 5, 8), skinPaint);
    canvas.drawRect(Rect.fromLTWH(p.x + 3, bodyY + 22, 5, 8), skinPaint);

    final bootPaint = Paint()..color = p.secondaryColor;
    canvas.drawRect(Rect.fromLTWH(p.x - 9, bodyY + 28, 7, 3), bootPaint);
    canvas.drawRect(Rect.fromLTWH(p.x + 2, bodyY + 28, 7, 3), bootPaint);

    // Big Comedy Ears
    final earOutline = Paint()
      ..color = const Color(0x4D000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawOval(Rect.fromCenter(center: Offset(p.x - headR - 2, p.y - 2), width: 12, height: 18), skinPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(p.x - headR - 2, p.y - 2), width: 12, height: 18), earOutline);

    canvas.drawOval(Rect.fromCenter(center: Offset(p.x + headR + 2, p.y - 2), width: 12, height: 18), skinPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(p.x + headR + 2, p.y - 2), width: 12, height: 18), earOutline);

    // Big Head
    canvas.drawCircle(Offset(p.x, p.y - 6), headR, skinPaint);
    final headOutline = Paint()
      ..color = const Color(0xFF121212)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(p.x, p.y - 6), headR, headOutline);

    // Hairstyles & Styling
    final hairPaint = Paint()..color = p.hairColor;

    if (p.style == 'messi') {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(p.x - 2, p.y - 12), radius: headR * 0.95),
        pi * 0.8,
        pi * 1.15,
        true,
        hairPaint,
      );

      final beardPaint = Paint()..color = const Color(0xFF8B4513);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(p.x, p.y - 2), radius: headR * 0.9),
        0.2,
        pi - 0.4,
        true,
        beardPaint,
      );

      final armbandPaint = Paint()..color = const Color(0xFFFF9100);
      canvas.drawRect(Rect.fromLTWH(p.x - 12, bodyY + 3, 5, 8), armbandPaint);
    } else if (p.style == 'mbappe') {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(p.x, p.y - 8), radius: headR * 0.98),
        pi * 0.85,
        pi * 1.3,
        true,
        hairPaint,
      );

      final headbandPaint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(p.x - headR + 1, p.y - 12, headR * 2 - 2, 5), headbandPaint);
    } else if (p.style == 'ronaldo') {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(p.x + 2, p.y - 10), radius: headR * 0.92),
        pi * 0.8,
        pi * 1.25,
        true,
        hairPaint,
      );

      final earStudPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(p.x - headR - 2, p.y + 2), 2.0, earStudPaint);
    } else if (p.style == 'neymar') {
      final neymarHair = Paint()..color = const Color(0xFFE0C068);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(p.x, p.y - 10), radius: headR * 0.9),
        pi * 0.75,
        pi * 1.5,
        true,
        neymarHair,
      );

      final hbPaint = Paint()..color = const Color(0xFF121212);
      canvas.drawRect(Rect.fromLTWH(p.x - headR + 2, p.y - 8, headR * 2 - 4, 4), hbPaint);
    } else if (p.style == 'haaland') {
      final haalandHair = Paint()..color = const Color(0xFFF7E28B);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(p.x, p.y - 8), radius: headR),
        pi * 0.9,
        pi * 1.2,
        true,
        haalandHair,
      );

      canvas.drawCircle(Offset(p.x, p.y - headR - 10), 6.0, haalandHair);
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(p.x, p.y - 8), radius: headR),
        pi,
        pi,
        true,
        hairPaint,
      );
    }

    // Caricature Eyes
    const eyeOffset = 6.0;
    final eyeY = p.y - 6;
    final eyeDirX = cos(p.facingAngle) * 2.5;
    final eyeDirY = sin(p.facingAngle) * 2.5;

    final whiteEye = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(p.x - eyeOffset, eyeY), 4.5, whiteEye);
    canvas.drawCircle(Offset(p.x + eyeOffset, eyeY), 4.5, whiteEye);

    final pupilPaint = Paint()..color = const Color(0xFF121212);
    canvas.drawCircle(Offset(p.x - eyeOffset + eyeDirX, eyeY + eyeDirY), 2.2, pupilPaint);
    canvas.drawCircle(Offset(p.x + eyeOffset + eyeDirX, eyeY + eyeDirY), 2.2, pupilPaint);

    // Eyebrows
    final browPaint = Paint()
      ..color = p.hairColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(p.x - eyeOffset - 4, eyeY - 6), Offset(p.x - eyeOffset + 3, eyeY - 6), browPaint);
    canvas.drawLine(Offset(p.x + eyeOffset - 3, eyeY - 6), Offset(p.x + eyeOffset + 4, eyeY - 6), browPaint);

    // Nameplate
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${p.name.toUpperCase()} #${p.number}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(p.x - textPainter.width / 2, p.y + 44));

    if (hasBall) {
      final activeText = TextPainter(
        text: const TextSpan(
          text: '⭐ ACTIVE ⭐',
          style: TextStyle(
            color: Color(0xFFFFC800),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      activeText.paint(canvas, Offset(p.x - activeText.width / 2, p.y - headR - 16));
    }
  }

  void drawDefender(Canvas canvas, Player def) {
    const headR = 24.0;

    // Danger Zone Circle
    final dangerZonePaint = Paint()..color = const Color(0x29FF3B5C);
    canvas.drawCircle(Offset(def.x, def.y), headR * 2.8, dangerZonePaint);

    // Drop Shadow
    final shadowPaint = Paint()..color = const Color(0x73000000);
    canvas.drawOval(Rect.fromCenter(center: Offset(def.x, def.y + 32), width: 44, height: 18), shadowPaint);

    // AC Milan Red & Black Striped Jersey
    final bodyY = def.y + 14;
    final redJersey = Paint()..color = const Color(0xFF990000);
    canvas.drawRRect(RRect.fromLTRBR(def.x - 12, bodyY, def.x + 12, bodyY + 16, const Radius.circular(4)), redJersey);

    final blackStripe = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawRect(Rect.fromLTWH(def.x - 8, bodyY, 4, 16), blackStripe);
    canvas.drawRect(Rect.fromLTWH(def.x + 4, bodyY, 4, 16), blackStripe);

    // Shorts & Boots
    final shortsPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(def.x - 10, bodyY + 16, 20, 6), shortsPaint);

    final skinPaint = Paint()..color = def.skinColor;
    canvas.drawRect(Rect.fromLTWH(def.x - 8, bodyY + 22, 5, 8), skinPaint);
    canvas.drawRect(Rect.fromLTWH(def.x + 3, bodyY + 22, 5, 8), skinPaint);

    final defBootPaint = Paint()..color = const Color(0xFFFF3B5C);
    canvas.drawRect(Rect.fromLTWH(def.x - 9, bodyY + 28, 7, 3), defBootPaint);
    canvas.drawRect(Rect.fromLTWH(def.x + 2, bodyY + 28, 7, 3), defBootPaint);

    // Captain Armband
    final armbandPaint = Paint()..color = const Color(0xFFFFEA00);
    canvas.drawRect(Rect.fromLTWH(def.x - 12, bodyY + 3, 5, 8), armbandPaint);

    // Ears
    final earOutline = Paint()
      ..color = const Color(0x4D000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(Rect.fromCenter(center: Offset(def.x - headR - 2, def.y - 2), width: 12, height: 18), skinPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(def.x - headR - 2, def.y - 2), width: 12, height: 18), earOutline);
    canvas.drawOval(Rect.fromCenter(center: Offset(def.x + headR + 2, def.y - 2), width: 12, height: 18), skinPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(def.x + headR + 2, def.y - 2), width: 12, height: 18), earOutline);

    // Maldini Hair & Head
    final hairPaint = Paint()..color = def.hairColor;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(def.x, def.y - 6), radius: headR * 1.12),
      pi * 0.7,
      pi * 1.6,
      true,
      hairPaint,
    );

    canvas.drawCircle(Offset(def.x, def.y - 6), headR, skinPaint);
    final headOutline = Paint()
      ..color = const Color(0xFF121212)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(def.x, def.y - 6), headR, headOutline);

    // Intimidating Eyes
    const eyeOffset = 6.0;
    final eyeY = def.y - 6;
    final eyeDirX = cos(def.facingAngle) * 2.5;
    final eyeDirY = sin(def.facingAngle) * 2.5;

    final whiteEye = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(def.x - eyeOffset, eyeY), 4.5, whiteEye);
    canvas.drawCircle(Offset(def.x + eyeOffset, eyeY), 4.5, whiteEye);

    final redPupil = Paint()..color = const Color(0xFFFF0000);
    canvas.drawCircle(Offset(def.x - eyeOffset + eyeDirX, eyeY + eyeDirY), 2.2, redPupil);
    canvas.drawCircle(Offset(def.x + eyeOffset + eyeDirX, eyeY + eyeDirY), 2.2, redPupil);

    // Nameplate
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'MALDINI #3',
        style: TextStyle(
          color: Color(0xFFFF3B5C),
          fontSize: 13,
          fontWeight: FontWeight.w900,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(def.x - textPainter.width / 2, def.y + 44));
  }

  void drawBall(Canvas canvas, Ball ball, int comboMultiplier) {
    // Shadow
    final shadowScale = max(0.4, 1.0 - ball.z * 0.02);
    final shadowOffset = 4.0 + ball.z * 0.8;
    final shadowPaint = Paint()..color = Color.fromRGBO(0, 0, 0, 0.45 * shadowScale);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(ball.x, ball.y + shadowOffset),
        width: ball.radius * 2 * shadowScale,
        height: ball.radius * shadowScale,
      ),
      shadowPaint,
    );

    // Trail
    for (final t in ball.trail) {
      final trailPaint = Paint()
        ..color = comboMultiplier > 1
            ? Color.fromRGBO(255, 200, 0, t.alpha * 0.6)
            : Color.fromRGBO(0, 255, 135, t.alpha * 0.4);
      canvas.drawCircle(Offset(t.x, t.y - t.z), ball.radius * t.alpha, trailPaint);
    }

    // Render Ball
    final renderY = ball.y - ball.z;
    final ballPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(ball.x, renderY), ball.radius, ballPaint);

    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(ball.x, renderY), ball.radius * 0.5, linePaint);
  }

  void drawParticles(Canvas canvas) {
    for (final p in game.particles) {
      final pPaint = Paint()..color = p.color.withOpacity(max(0.0, min(1.0, p.life)));
      canvas.drawCircle(Offset(p.x, p.y), 3.0 * p.life, pPaint);
    }
  }

  void drawFloatingTexts(Canvas canvas) {
    for (final ft in game.floatingTexts) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: ft.text,
          style: TextStyle(
            color: ft.color.withOpacity(max(0.0, min(1.0, ft.opacity))),
            fontSize: 20 * ft.scale,
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(ft.x - textPainter.width / 2, ft.y));
    }
  }

  @override
  bool shouldRepaint(covariant RondoPainter oldDelegate) => true;
}
