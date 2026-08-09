import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PauseModal extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const PauseModal({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xEE0B1A13),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF00FF87).withOpacity(0.4), width: 1.5),
          boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 30)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle, color: Color(0xFF00FF87), size: 48),
            const SizedBox(height: 12),
            Text(
              'MATCH PAUSED',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF87),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('RESUME MATCH', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onRestart,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('RESTART MATCH', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onQuit,
              child: Text('QUIT TO MAIN MENU', style: GoogleFonts.outfit(color: const Color(0xFFFF3B5C), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
