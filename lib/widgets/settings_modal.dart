import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsModal extends StatefulWidget {
  final bool sfx;
  final bool showGuidelines;
  final String defaultDifficulty;
  final Function(bool sfx, bool showGuidelines, String defaultDiff) onSave;
  final VoidCallback onClose;

  const SettingsModal({
    super.key,
    required this.sfx,
    required this.showGuidelines,
    required this.defaultDifficulty,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late bool sfx;
  late bool showGuidelines;
  late String defaultDiff;

  @override
  void initState() {
    super.initState();
    sfx = widget.sfx;
    showGuidelines = widget.showGuidelines;
    defaultDiff = widget.defaultDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xEE0B1A13),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFC800).withOpacity(0.4), width: 1.5),
          boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 30)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.settings, color: Color(0xFFFFC800)),
                    const SizedBox(width: 8),
                    Text(
                      'GAME SETTINGS',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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

            _buildSettingRow(
              title: 'Sound Effects & SFX',
              desc: 'Kicks, whistle, and combo audio',
              value: sfx,
              onChanged: (val) {
                setState(() => sfx = val);
                widget.onSave(sfx, showGuidelines, defaultDiff);
              },
            ),
            const Divider(color: Colors.white10, height: 24),

            _buildSettingRow(
              title: 'Passing Guidelines',
              desc: 'Vector line preview & defender shadow cone',
              value: showGuidelines,
              onChanged: (val) {
                setState(() => showGuidelines = val);
                widget.onSave(sfx, showGuidelines, defaultDiff);
              },
            ),
            const Divider(color: Colors.white10, height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default AI Difficulty',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Speed & prediction quality',
                      style: GoogleFonts.inter(color: const Color(0xFF8E9BAE), fontSize: 11),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: defaultDiff,
                  dropdownColor: const Color(0xFF0B1A13),
                  style: GoogleFonts.outfit(color: const Color(0xFFFFC800), fontWeight: FontWeight.bold),
                  items: ['easy', 'medium', 'hard', 'pro'].map((diff) {
                    return DropdownMenuItem(
                      value: diff,
                      child: Text(diff.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => defaultDiff = val);
                      widget.onSave(sfx, showGuidelines, defaultDiff);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required String title,
    required String desc,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text(desc, style: GoogleFonts.inter(color: const Color(0xFF8E9BAE), fontSize: 11)),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF00FF87),
        ),
      ],
    );
  }
}
