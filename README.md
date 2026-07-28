# ⚽ Rondo FC - Master of Keep-Away (5v1 Football)

[![HTML5 Canvas](https://img.shields.io/badge/HTML5-Canvas-orange.svg)](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API)
[![JavaScript](https://img.shields.io/badge/JavaScript-ES6+-yellow.svg)](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
[![WebRTC Multiplayer](https://img.shields.io/badge/WebRTC-PeerJS-blue.svg)](https://peerjs.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An interactive, high-performance HTML5 Canvas **5v1 Football Rondo Keep-Away** simulation game. Master open passing lanes, maintain possession, outsmart dynamic AI defenders, or challenge your friends in local pass-and-play and online WebRTC peer-to-peer multiplayer!

---

## 🌟 Key Features

- 🎮 **Multiple Game Modes**:
  - **Solo Mode**: You + 4 smart AI teammates vs dynamic AI Defender(s).
  - **Local Multiplayer**: 2 to 6 human players sharing controls on the same device.
  - **Online P2P Multiplayer**: Low-latency WebRTC peer-to-peer multiplayer powered by PeerJS. Host custom room codes or join friends instantly.
- 🤖 **Smart AI Systems**:
  - Predictive defender positioning with configurable difficulty levels (**Easy**, **Medium**, **Hard**, **Pro**).
  - Teammate AI with dynamic off-ball movement, tactical spacing, and pass request awareness.
- ⚡ **Physics & Rendering**:
  - Smooth ball physics with velocity decay, realistic spin/curve, and passing animations.
  - Canvas graphics engine featuring stadium smoke overlay, dynamic ambient lighting, and sleek UI overlays.
- 🎵 **Immersive Audio**:
  - Web Audio API synthesizer fallback + custom sound effects for kicks, catches, whistles, and combo streak milestones.
- 🔥 **Combo Multiplier & Streak Tracker**:
  - Build consecutive pass streaks to unlock combo multipliers (1x to 5x) and set high score records.

---

## 🕹️ Controls

| Action | Control / Keyboard Shortcut |
|---|---|
| **Aim & Pass** | Mouse cursor + Left Click / Spacebar |
| **Select Teammate directly** | Number keys `1` - `5` |
| **Pass Power Adjustment** | Hold Click / Spacebar to charge pass power |
| **Pause Game** | `Esc` key or Pause button on HUD |
| **Toggle Audio** | Mute button on HUD |

---

## 🚀 Quick Start / How to Run

No heavy build steps required! You can run the game directly in any modern browser:

### Option 1: Direct File Launch
Simply open `index.html` in your favorite Web Browser (Chrome, Firefox, Edge, Safari).

### Option 2: Local HTTP Server (Recommended for WebRTC Multiplayer)
Using Node.js:
```bash
npm start
```
Or using Python:
```bash
python -m http.server 8000
```
Then navigate to `http://localhost:8000` in your browser.

---

## 📁 Repository Structure

```
gmme3/
├── index.html            # Main HTML document & UI overlay modals
├── css/
│   └── styles.css        # Modern glassmorphism UI & responsive styles
├── js/
│   ├── app.js            # Main application entry point & UI event wiring
│   ├── engine/
│   │   ├── game.js       # Game loop & main state management
│   │   └── physics.js    # Physics simulation engine
│   ├── entities/
│   │   ├── player.js     # Player class (human & AI state)
│   │   └── ball.js       # Ball physics & movement logic
│   ├── ai/
│   │   ├── defenderAI.js # Defender AI decision & interception logic
│   │   └── teammateAI.js # Teammate AI spacing & positioning logic
│   ├── graphics/
│   │   └── renderer.js   # HTML5 Canvas 2D render pipeline
│   ├── audio/
│   │   └── sound.js      # Web Audio sound generator & audio manager
│   └── net/
│       └── multiplayer.js# PeerJS WebRTC P2P networking manager
├── package.json          # Project metadata & npm scripts
└── .gitignore            # Git ignore file rules
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check out [Issues](https://github.com/SachidanandM14210/football/issues) page.

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.
