import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModeSelectModal extends StatefulWidget {
  final Function(int numHumans, String difficulty) onStartGame;
  final VoidCallback onClose;

  const ModeSelectModal({
    super.key,
    required this.onStartGame,
    required this.onClose,
  });

  @override
  State<ModeSelectModal> createState() => _ModeSelectModalState();
}

class _ModeSelectModalState extends State<ModeSelectModal> {
  int selectedHumans = 2;
  String selectedDifficulty = 'medium';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xEE0B1A13),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4), width: 1.5),
          boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 30)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.gamepad, color: Color(0xFF00E5FF)),
                    const SizedBox(width: 8),
                    Text(
                      'CHOOSE PLAYERS & MODE',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Select Number of Human Players
            Text(
              'Select Number of Human Players:',
              style: GoogleFonts.outfit(color: const Color(0xFF8E9BAE), fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [2, 3, 4, 5, 6].map((count) {
                final isSelected = selectedHumans == count;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () => setState(() => selectedHumans = count),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00E5FF) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? const Color(0xFF00E5FF) : Colors.white12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$count',
                              style: GoogleFonts.outfit(
                                color: isSelected ? Colors.black : Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'P',
                              style: GoogleFonts.inter(
                                color: isSelected ? Colors.black87 : const Color(0xFF8E9BAE),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Select AI Difficulty
            Text(
              'AI Defender Difficulty:',
              style: GoogleFonts.outfit(color: const Color(0xFF8E9BAE), fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: ['easy', 'medium', 'hard', 'pro'].map((diff) {
                final isSelected = selectedDifficulty == diff;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () => setState(() => selectedDifficulty = diff),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFF3B5C) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? const Color(0xFFFF3B5C) : Colors.white12),
                        ),
                        child: Center(
                          child: Text(
                            diff.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: isSelected ? Colors.white : const Color(0xFF8E9BAE),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Start Match Button
            ElevatedButton(
              onPressed: () => widget.onStartGame(selectedHumans, selectedDifficulty),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF87),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'START LOCAL MATCH',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.play_arrow, size: 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
