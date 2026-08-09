import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainMenuModal extends StatelessWidget {
  final int bestStreak;
  final VoidCallback onStartSolo;
  final VoidCallback onOpenMultiplayer;
  final VoidCallback onOpenSettings;

  const MainMenuModal({
    super.key,
    required this.bestStreak,
    required this.onStartSolo,
    required this.onOpenMultiplayer,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xEE0B1A13),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF00FF87).withOpacity(0.3), width: 1.5),
          boxShadow: const [
            BoxShadow(color: Color(0x6600FF87), blurRadius: 20, spreadRadius: 1),
            BoxShadow(color: Colors.black, blurRadius: 30),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Brand Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x3300FF87),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00FF87)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sports_soccer, color: Color(0xFF00FF87), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '5v1 KEEP-AWAY',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF00FF87),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'RONDO ',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00FF87), Color(0xFF00E5FF)],
                  ).createShader(bounds),
                  child: Text(
                    'FC',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Master spacing, open passing lanes, & maintain ultimate possession.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF8E9BAE),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),

            // Menu Buttons
            _buildMenuButton(
              title: 'SOLO MODE',
              subtitle: '1 Human Player + 4 AI Teammates vs AI Defender',
              icon: Icons.person,
              color: const Color(0xFF00FF87),
              onTap: onStartSolo,
            ),
            const SizedBox(height: 14),
            _buildMenuButton(
              title: 'MULTIPLAYER MODE',
              subtitle: '2 to 6 Players (Local Pass & Play)',
              icon: Icons.groups,
              color: const Color(0xFF00E5FF),
              onTap: onOpenMultiplayer,
            ),
            const SizedBox(height: 14),
            _buildMenuButton(
              title: 'SETTINGS & DIFFICULTY',
              subtitle: 'Adjust AI behavior, sound, controls, & visuals',
              icon: Icons.settings,
              color: const Color(0xFFFFC800),
              onTap: onOpenSettings,
            ),
            const SizedBox(height: 24),

            // Footer Best Record
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, color: Color(0xFFFFC800), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'ALL-TIME RECORD: ',
                    style: GoogleFonts.outfit(color: const Color(0xFF8E9BAE), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$bestStreak PASSES',
                    style: GoogleFonts.outfit(color: const Color(0xFFFFC800), fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildMenuButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8E9BAE),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
