import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ai/defender_ai.dart';
import '../ai/teammate_ai.dart';
import '../audio/sound_manager.dart';

import '../models/ball.dart';
import '../models/player.dart';
import 'physics.dart';

class FloatingText {
  String text;
  double x;
  double y;
  Color color;
  double opacity;
  double scale;

  FloatingText({
    required this.text,
    required this.x,
    required this.y,
    this.color = const Color(0xFF00FF87),
    this.opacity = 1.0,
    this.scale = 1.2,
  });
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.life = 1.0,
    this.color = const Color(0xFF00FF87),
  });
}

class GameEngine extends ChangeNotifier {
  String state = 'MENU'; // MENU, PLAYING, PAUSED, TURNOVER
  String mode = 'solo'; // solo, local
  int numHumans = 1;
  String difficulty = 'medium';

  double width = 800.0;
  double height = 600.0;
  double pitchCenterX = 400.0;
  double pitchCenterY = 300.0;
  double rondoRadius = 200.0;

  List<Player> players = [];
  Player? defender;
  final Ball ball = Ball();

  int score = 0;
  int passStreak = 0;
  int bestStreak = 0;
  int comboMultiplier = 1;
  bool defenderTriggered = false;

  Player? hoveredTarget;
  double aiPassTimer = 0.0;

  bool sfx = true;
  bool showGuidelines = true;
  String defaultDifficulty = 'medium';

  final List<FloatingText> floatingTexts = [];
  final List<Particle> particles = [];

  Function(Map<String, dynamic>)? onTurnoverCallback;

  GameEngine() {
    _loadBestStreak();
  }

  Future<void> _loadBestStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bestStreak = prefs.getInt('rondo_best_streak') ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveBestStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('rondo_best_streak', bestStreak);
    } catch (_) {}
  }

  void init({String mode = 'solo', int numHumans = 1, String difficulty = 'medium'}) {
    this.mode = mode;
    this.numHumans = numHumans;
    this.difficulty = difficulty;

    score = 0;
    passStreak = 0;
    comboMultiplier = 1;
    defenderTriggered = false;

    resizePitch(width, height);
    setupEntities();
    state = 'PLAYING';
    notifyListeners();
  }

  void resizePitch(double w, double h) {
    width = w;
    height = h;
    pitchCenterX = w / 2;
    pitchCenterY = h / 2;
    rondoRadius = min(w, h) * 0.34;
  }

  void setupEntities() {
    players.clear();

    final starAttackers = [
      {
        'name': 'Messi',
        'number': 10,
        'jerseyColor': const Color(0xFFFF007F),
        'secondaryColor': const Color(0xFF00E5FF),
        'hairColor': const Color(0xFF4A2C11),
        'skinColor': const Color(0xFFF5CDA7),
        'beard': true,
        'style': 'messi',
      },
      {
        'name': 'Mbappé',
        'number': 9,
        'jerseyColor': const Color(0xFF0038A8),
        'secondaryColor': Colors.white,
        'hairColor': const Color(0xFF121212),
        'skinColor': const Color(0xFF7A4E2D),
        'headband': Colors.white,
        'style': 'mbappe',
      },
      {
        'name': 'Ronaldo',
        'number': 7,
        'jerseyColor': const Color(0xFFD6001C),
        'secondaryColor': const Color(0xFFFFC800),
        'hairColor': const Color(0xFF1A1A1A),
        'skinColor': const Color(0xFFE5B88F),
        'style': 'ronaldo',
      },
      {
        'name': 'Neymar',
        'number': 11,
        'jerseyColor': const Color(0xFFFFEA00),
        'secondaryColor': const Color(0xFF009B3A),
        'hairColor': const Color(0xFFE0C068),
        'skinColor': const Color(0xFFC68D5C),
        'headband': const Color(0xFF121212),
        'style': 'neymar',
      },
      {
        'name': 'Haaland',
        'number': 99,
        'jerseyColor': const Color(0xFF6CABDD),
        'secondaryColor': Colors.white,
        'hairColor': const Color(0xFFF7E28B),
        'skinColor': const Color(0xFFFBE3D0),
        'ponytail': true,
        'style': 'haaland',
      },
    ];

    for (int i = 0; i < 5; i++) {
      final angle = i * (pi * 2 / 5);
      final isHuman = (mode == 'solo' || numHumans == 1) ? true : (i < numHumans);
      final info = starAttackers[i];

      final p = Player(
        id: i + 1,
        name: info['name'] as String,
        role: 'attacker',
        isHuman: isHuman,
        number: info['number'] as int,
        jerseyColor: info['jerseyColor'] as Color,
        secondaryColor: info['secondaryColor'] as Color,
        hairColor: info['hairColor'] as Color,
        skinColor: info['skinColor'] as Color,
        beard: info['beard'] == true,
        headband: info['headband'] as Color?,
        ponytail: info['ponytail'] == true,
        style: info['style'] as String,
      );

      p.baseAngle = angle;
      p.setPosition(
        pitchCenterX + cos(angle) * rondoRadius,
        pitchCenterY + sin(angle) * rondoRadius,
      );
      players.add(p);
    }

    defender = Player(
      id: 6,
      name: 'Maldini',
      role: 'defender',
      isHuman: false,
      number: 3,
      jerseyColor: const Color(0xFF990000),
      secondaryColor: Colors.white,
      hairColor: const Color(0xFF362215),
      skinColor: const Color(0xFFD9A77C),
      stripeColor: const Color(0xFF1A1A1A),
      armband: const Color(0xFFFFEA00),
      style: 'maldini',
    )..setPosition(pitchCenterX, pitchCenterY);
    defenderTriggered = false;

    final startingPlayer = players[0];
    startingPlayer.hasBall = true;
    ball.reset(startingPlayer.x, startingPlayer.y);
    ball.owner = startingPlayer;
  }

  void update(double deltaTime) {
    if (state != 'PLAYING') return;

    final currentDef = defender;
    if (currentDef == null) return;

    TeammateAI.updatePositioning(players, currentDef, pitchCenterX, pitchCenterY, rondoRadius);

    for (final p in players) {
      p.update(pitchCenterX, pitchCenterY, rondoRadius);
    }
    currentDef.update(pitchCenterX, pitchCenterY, rondoRadius);

    if (!currentDef.isHuman) {
      if (defenderTriggered) {
        DefenderAI.update(currentDef, ball, players, pitchCenterX, pitchCenterY, difficulty: difficulty, deltaTime: deltaTime);
      } else {
        currentDef.targetX = pitchCenterX;
        currentDef.targetY = pitchCenterY;
      }
    }

    ball.update();
    checkBallInteractions();
    handleAIPasses(deltaTime);
    updateEffects();
    notifyListeners();
  }

  void checkBallInteractions() {
    final currentDef = defender;
    if (currentDef == null) return;

    final defDist = Physics.distance(currentDef.x, currentDef.y, ball.x, ball.y);
    final interceptRadius = currentDef.radius + ball.radius + 6.0;

    if (defDist <= interceptRadius && (ball.owner == null || ball.owner!.id != currentDef.id)) {
      handleInterception();
      return;
    }

    if (ball.isMoving && ball.owner == null) {
      for (final player in players) {
        final dist = Physics.distance(player.x, player.y, ball.x, ball.y);
        final catchRadius = player.radius + ball.radius + 4.0;

        if (dist <= catchRadius && ball.passSender != null && ball.passSender!.id != player.id) {
          ball.owner = player;
          player.hasBall = true;
          if (ball.passSender != null) ball.passSender!.hasBall = false;

          onPassCompleted(ball.passSender!, player);
        }
      }
    }
  }

  void onPassCompleted(Player sender, Player receiver) {
    score++;
    passStreak++;

    if (passStreak > bestStreak) {
      bestStreak = passStreak;
      _saveBestStreak();
    }

    final prevDifficulty = difficulty;
    if (passStreak >= 25) {
      difficulty = 'pro';
    } else if (passStreak >= 15) {
      difficulty = 'hard';
    } else if (passStreak >= 7 && prevDifficulty == 'easy') {
      difficulty = 'medium';
    }

    if (difficulty != prevDifficulty && defender != null) {
      addFloatingText('MALDINI UPGRADED TO ${difficulty.toUpperCase()}! 🔥', defender!.x, defender!.y - 35, const Color(0xFFFF3B5C));
      SoundManager.instance.playCombo(3);
    }

    final newMultiplier = (passStreak ~/ 10) + 1;
    if (newMultiplier > comboMultiplier) {
      comboMultiplier = newMultiplier;
      SoundManager.instance.playCombo(comboMultiplier);
      addFloatingText('$passStreak STREAK! ${comboMultiplier}x COMBO!', receiver.x, receiver.y - 20, const Color(0xFFFFC800));
    } else {
      addFloatingText('+1', receiver.x, receiver.y - 20, const Color(0xFF00FF87));
    }

    addImpactParticles(receiver.x, receiver.y, count: 10, color: receiver.jerseyColor);
    SoundManager.instance.playCatch();
  }

  void handleInterception() {
    SoundManager.instance.playInterception();
    SoundManager.instance.playWhistle();
    state = 'TURNOVER';
    defenderTriggered = false;

    final lastPasser = ball.passSender ?? players[0];
    String nextDefenderName = 'AI Defender';
    if (numHumans > 1) {
      nextDefenderName = lastPasser.name;
    }

    passStreak = 0;
    comboMultiplier = 1;

    if (onTurnoverCallback != null) {
      onTurnoverCallback!({
        'passer': lastPasser,
        'nextDefenderName': nextDefenderName,
        'finalScore': score,
        'bestStreak': bestStreak,
      });
    }
    notifyListeners();
  }

  void executePass(Player fromPlayer, Player targetPlayer) {
    if (!fromPlayer.hasBall || fromPlayer.id == targetPlayer.id || ball.isMoving) return;

    defenderTriggered = true;

    fromPlayer.hasBall = false;
    fromPlayer.facingAngle = Physics.angleBetween(fromPlayer.x, fromPlayer.y, targetPlayer.x, targetPlayer.y);

    final dist = Physics.distance(fromPlayer.x, fromPlayer.y, targetPlayer.x, targetPlayer.y);
    final power = max(9.0, min(15.0, dist * 0.045));

    ball.kick(fromPlayer, targetPlayer, power: power);
    SoundManager.instance.playPass(power / 10.0);
  }

  void handleAIPasses(double deltaTime) {
    // Automatic AI pass loop removed so ball stays with receiver until user initiates pass
    aiPassTimer = 0.0;
  }

  void handlePointerMove(double mouseX, double mouseY) {
    if (state != 'PLAYING') return;

    Player? closest;
    double minDist = 50.0;

    for (final p in players) {
      if (ball.owner != null && p.id == ball.owner!.id) continue;
      final dist = sqrt(pow(p.x - mouseX, 2) + pow(p.y - mouseY, 2));
      if (dist < minDist) {
        minDist = dist;
        closest = p;
      }
    }

    hoveredTarget = closest;
    notifyListeners();
  }

  void handlePointerClick([double? mouseX, double? mouseY]) {
    if (state != 'PLAYING' || ball.owner == null) return;

    final carrier = ball.owner!;

    Player? targetToPass = hoveredTarget;

    if (targetToPass == null && mouseX != null && mouseY != null) {
      final clickAngle = atan2(mouseY - carrier.y, mouseX - carrier.x);
      Player? bestMatch;
      double smallestAngleDiff = 0.55;

      for (final p in players) {
        if (p.id == carrier.id) continue;
        final pAngle = atan2(p.y - carrier.y, p.x - carrier.x);
        double angleDiff = (clickAngle - pAngle).abs();
        if (angleDiff > pi) angleDiff = 2 * pi - angleDiff;

        if (angleDiff < smallestAngleDiff) {
          smallestAngleDiff = angleDiff;
          bestMatch = p;
        }
      }

      targetToPass = bestMatch;
    }

    if (targetToPass != null) {
      executePass(carrier, targetToPass);
    }
  }

  void handleKeyPress(String key) {
    if (state != 'PLAYING' || ball.owner == null) return;

    final num = int.tryParse(key);
    if (num != null && num >= 1 && num <= 5) {
      final target = players.firstWhere((p) => p.number == num, orElse: () => players[0]);
      if (target.id != ball.owner!.id) {
        executePass(ball.owner!, target);
      }
    }

    if (key == ' ' || key == 'Space') {
      handlePointerClick();
    }
  }

  void addFloatingText(String text, double x, double y, Color color) {
    floatingTexts.add(FloatingText(text: text, x: x, y: y, color: color));
  }

  void addImpactParticles(double x, double y, {int count = 8, Color color = const Color(0xFF00FF87)}) {
    final random = Random();
    for (int i = 0; i < count; i++) {
      final angle = random.nextDouble() * pi * 2;
      final speed = 1.0 + random.nextDouble() * 4.0;
      particles.add(Particle(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        color: color,
      ));
    }
  }

  void updateEffects() {
    for (int i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.life -= 0.04;
      if (p.life <= 0) particles.removeAt(i);
    }

    for (int i = floatingTexts.length - 1; i >= 0; i--) {
      final ft = floatingTexts[i];
      ft.y -= 1.2;
      ft.opacity -= 0.025;
      ft.scale = max(1.0, ft.scale - 0.01);
      if (ft.opacity <= 0) floatingTexts.removeAt(i);
    }
  }
}
