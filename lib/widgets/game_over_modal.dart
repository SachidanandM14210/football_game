import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameOverModal extends StatelessWidget {
  final int finalScore;
  final int comboTier;
  final String nextDefenderName;
  final VoidCallback onPlayAgain;
  final VoidCallback onMainMenu;

  const GameOverModal({
    super.key,
    required this.finalScore,
    required this.comboTier,
    required this.nextDefenderName,
    required this.onPlayAgain,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xEE0B1A13),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFF3B5C).withOpacity(0.5), width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x44FF3B5C), blurRadius: 25)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0x22FF3B5C),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield, color: Color(0xFFFF3B5C), size: 40),
            ),
            const SizedBox(height: 12),
            Text(
              'INTERCEPTED!',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFF3B5C),
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Maldini intercepted the pass!',
              style: GoogleFonts.inter(color: const Color(0xFF8E9BAE), fontSize: 12),
            ),
            const SizedBox(height: 24),

            // Summary Stats Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text('CONSECUTIVE PASSES', style: GoogleFonts.outfit(color: const Color(0xFF8E9BAE), fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('$finalScore', style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text('MAX COMBO TIER', style: GoogleFonts.outfit(color: const Color(0xFF8E9BAE), fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${comboTier}x', style: GoogleFonts.outfit(color: const Color(0xFFFFC800), fontSize: 24, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons
            ElevatedButton(
              onPressed: onPlayAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF87),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.replay),
                  const SizedBox(width: 8),
                  Text('PLAY AGAIN / NEXT ROUND', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onMainMenu,
              child: Text('MAIN MENU', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
