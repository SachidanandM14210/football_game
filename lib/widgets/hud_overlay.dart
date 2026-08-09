import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../engine/game_engine.dart';

class HudOverlay extends StatelessWidget {
  final GameEngine game;
  final VoidCallback onPause;
  final VoidCallback onToggleSound;

  const HudOverlay({
    super.key,
    required this.game,
    required this.onPause,
    required this.onToggleSound,
  });

  @override
  Widget build(BuildContext context) {
    if (game.state != 'PLAYING') return const SizedBox.shrink();

    final progress = ((game.passStreak % 10) / 10.0).clamp(0.0, 1.0);
    final activeCarrier = game.ball.owner;

    return SafeArea(
      child: Stack(
        children: [
          // Top HUD Bar
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score Card
                Flexible(
                  child: _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PASSES',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF8E9BAE),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          '${game.score}',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Combo Card
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildGlassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'COMBO',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF8E9BAE),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC800),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${game.comboMultiplier}x',
                                  style: GoogleFonts.outfit(
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC800)),
                              minHeight: 5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${game.passStreak % 10}/10 to next',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF8E9BAE),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Best Streak Card
                Flexible(
                  child: _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'BEST',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF8E9BAE),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${game.bestStreak}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFC800),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom HUD Bar
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Defender Badge Card
                Flexible(
                  child: _buildGlassCard(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield, color: Color(0xFFFF3B5C), size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'DEFENDER',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(color: const Color(0xFF8E9BAE), fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Maldini',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0x33FF3B5C),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFFF3B5C)),
                          ),
                          child: Text(
                            game.difficulty.toUpperCase(),
                            style: GoogleFonts.outfit(color: const Color(0xFFFF3B5C), fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Active Ball Carrier Badge
                if (activeCarrier != null)
                  Flexible(
                    child: _buildGlassCard(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Color(0xFF00FF87), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              activeCarrier.name,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Control Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                      onPressed: onToggleSound,
                      icon: Icon(
                        game.sfx ? Icons.volume_up : Icons.volume_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1)),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                      onPressed: onPause,
                      icon: const Icon(Icons.pause, color: Colors.white, size: 20),
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Control Tip Center Bottom
          Positioned(
            bottom: 72,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  '💡 Tap teammate or use keys 1-5 / Space to pass!',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xCC0D1F17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
      ),
      child: child,
    );
  }
}
