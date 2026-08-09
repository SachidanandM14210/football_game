import 'package:flutter/foundation.dart';

class SoundManager {
  static final SoundManager instance = SoundManager._internal();
  SoundManager._internal();

  bool sfxEnabled = true;

  void playPass([double intensity = 1.0]) {
    if (!sfxEnabled) return;
    debugPrint('SFX: Pass (intensity: $intensity)');
  }

  void playCatch() {
    if (!sfxEnabled) return;
    debugPrint('SFX: Catch');
  }

  void playWhistle() {
    if (!sfxEnabled) return;
    debugPrint('SFX: Whistle');
  }

  void playInterception() {
    if (!sfxEnabled) return;
    debugPrint('SFX: Interception');
  }

  void playCombo(int tier) {
    if (!sfxEnabled) return;
    debugPrint('SFX: Combo Tier $tier');
  }
}
