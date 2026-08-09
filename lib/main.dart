import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'engine/game_engine.dart';
import 'painter/rondo_painter.dart';
import 'widgets/game_over_modal.dart';
import 'widgets/hud_overlay.dart';
import 'widgets/main_menu_modal.dart';
import 'widgets/mode_select_modal.dart';
import 'widgets/pause_modal.dart';
import 'widgets/settings_modal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const RondoApp());
}

class RondoApp extends StatelessWidget {
  const RondoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rondo FC - Master of Keep-Away (5v1 Football)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF06100B),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late final GameEngine gameEngine;
  late final AnimationController _ticker;
  Duration _lastFrameTime = Duration.zero;

  bool showModeSelect = false;
  bool showSettings = false;

  @override
  void initState() {
    super.initState();
    gameEngine = GameEngine();

    gameEngine.onTurnoverCallback = (data) {
      setState(() {});
    };

    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _ticker.addListener(_onFrameTick);
  }

  void _onFrameTick() {
    final now = _ticker.lastElapsedDuration ?? Duration.zero;
    final dt = _lastFrameTime == Duration.zero ? 0.016 : (now - _lastFrameTime).inMicroseconds / 1000000.0;
    _lastFrameTime = now;

    if (gameEngine.state == 'PLAYING') {
      gameEngine.update(dt.clamp(0.001, 0.05));
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _startSoloGame() {
    setState(() {
      showModeSelect = false;
      showSettings = false;
      gameEngine.init(mode: 'solo', numHumans: 1, difficulty: gameEngine.defaultDifficulty);
    });
  }

  void _startLocalGame(int numHumans, String diff) {
    setState(() {
      showModeSelect = false;
      showSettings = false;
      gameEngine.init(mode: 'local', numHumans: numHumans, difficulty: diff);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          gameEngine.resizePitch(constraints.maxWidth, constraints.maxHeight);

          return KeyboardListener(
            focusNode: FocusNode()..requestFocus(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.escape) {
                  if (gameEngine.state == 'PLAYING') {
                    setState(() => gameEngine.state = 'PAUSED');
                  } else if (gameEngine.state == 'PAUSED') {
                    setState(() => gameEngine.state = 'PLAYING');
                  }
                } else if (event.logicalKey == LogicalKeyboardKey.digit1 || event.character == '1') {
                  gameEngine.handleKeyPress('1');
                } else if (event.logicalKey == LogicalKeyboardKey.digit2 || event.character == '2') {
                  gameEngine.handleKeyPress('2');
                } else if (event.logicalKey == LogicalKeyboardKey.digit3 || event.character == '3') {
                  gameEngine.handleKeyPress('3');
                } else if (event.logicalKey == LogicalKeyboardKey.digit4 || event.character == '4') {
                  gameEngine.handleKeyPress('4');
                } else if (event.logicalKey == LogicalKeyboardKey.digit5 || event.character == '5') {
                  gameEngine.handleKeyPress('5');
                } else if (event.logicalKey == LogicalKeyboardKey.space) {
                  gameEngine.handleKeyPress('Space');
                }
              }
            },
            child: MouseRegion(
              onHover: (event) {
                gameEngine.handlePointerMove(event.position.dx, event.position.dy);
              },
              child: GestureDetector(
                onTapDown: (details) {
                  gameEngine.handlePointerClick(details.localPosition.dx, details.localPosition.dy);
                },
                child: Stack(
                  children: [
                    // Canvas Game Render View
                    Positioned.fill(
                      child: CustomPaint(
                        painter: RondoPainter(gameEngine),
                      ),
                    ),

                    // HUD Overlay
                    HudOverlay(
                      game: gameEngine,
                      onPause: () => setState(() => gameEngine.state = 'PAUSED'),
                      onToggleSound: () => setState(() => gameEngine.sfx = !gameEngine.sfx),
                    ),

                    // Modals
                    if (gameEngine.state == 'MENU' && !showModeSelect && !showSettings)
                      MainMenuModal(
                        bestStreak: gameEngine.bestStreak,
                        onStartSolo: _startSoloGame,
                        onOpenMultiplayer: () => setState(() => showModeSelect = true),
                        onOpenSettings: () => setState(() => showSettings = true),
                      ),

                    if (showModeSelect)
                      ModeSelectModal(
                        onStartGame: _startLocalGame,
                        onClose: () => setState(() => showModeSelect = false),
                      ),

                    if (showSettings)
                      SettingsModal(
                        sfx: gameEngine.sfx,
                        showGuidelines: gameEngine.showGuidelines,
                        defaultDifficulty: gameEngine.defaultDifficulty,
                        onSave: (sfx, guidelines, diff) {
                          setState(() {
                            gameEngine.sfx = sfx;
                            gameEngine.showGuidelines = guidelines;
                            gameEngine.defaultDifficulty = diff;
                          });
                        },
                        onClose: () => setState(() => showSettings = false),
                      ),

                    if (gameEngine.state == 'PAUSED')
                      PauseModal(
                        onResume: () => setState(() => gameEngine.state = 'PLAYING'),
                        onRestart: _startSoloGame,
                        onQuit: () => setState(() => gameEngine.state = 'MENU'),
                      ),

                    if (gameEngine.state == 'TURNOVER')
                      GameOverModal(
                        finalScore: gameEngine.score,
                        comboTier: gameEngine.comboMultiplier,
                        nextDefenderName: 'Maldini',
                        onPlayAgain: _startSoloGame,
                        onMainMenu: () => setState(() => gameEngine.state = 'MENU'),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
