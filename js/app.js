// Application Bootstrapper & UI Controller

import { Renderer } from './graphics/renderer.js';
import { GameEngine } from './engine/game.js';
import { sound } from './audio/sound.js';
import { net } from './net/multiplayer.js';

class App {
    constructor() {
        this.canvas = document.getElementById('game-canvas');
        this.renderer = new Renderer(this.canvas);
        this.game = new GameEngine(this.canvas, this.renderer);

        this.selectedHumanCount = 4;
        this.selectedDifficulty = 'medium';

        this.initDOM();
        this.bindEvents();
        this.resize();
        this.updateHUD();

        // Start render loop
        this.lastTime = performance.now();
        requestAnimationFrame((time) => this.loop(time));
    }

    initDOM() {
        // DOM Elements
        this.hudOverlay = document.getElementById('hud-overlay');
        this.mainMenuModal = document.getElementById('main-menu-modal');
        this.modeSelectModal = document.getElementById('mode-select-modal');
        this.settingsModal = document.getElementById('settings-modal');
        this.pauseModal = document.getElementById('pause-modal');
        this.gameOverModal = document.getElementById('game-over-modal');

        // Phone Chassis & View Toggle
        this.phoneChassis = document.getElementById('phone-chassis');
        this.btnToggleView = document.getElementById('btn-toggle-view-mode');
        this.toggleViewText = document.getElementById('toggle-view-text');

        // HUD Elements
        this.hudScoreValue = document.getElementById('hud-score-value');
        this.hudComboMultiplier = document.getElementById('hud-combo-multiplier');
        this.hudComboProgress = document.getElementById('hud-combo-progress');
        this.hudComboStreakText = document.getElementById('hud-combo-streak-text');
        this.hudBestStreak = document.getElementById('hud-best-streak');
        this.hudDefenderName = document.getElementById('hud-defender-name');
        this.hudDifficultyTag = document.getElementById('hud-difficulty-tag');
        this.hudCarrierName = document.getElementById('hud-carrier-name');
        this.menuRecordScore = document.getElementById('menu-record-score');

        // Load Record Score
        const best = localStorage.getItem('rondo_best_streak') || '0';
        this.menuRecordScore.innerText = best;
        this.hudBestStreak.innerText = best;

        this.startPhoneClock();
    }

    startPhoneClock() {
        const updateClock = () => {
            const now = new Date();
            const hours = now.getHours().toString().padStart(2, '0');
            const mins = now.getMinutes().toString().padStart(2, '0');
            const clockElem = document.getElementById('phone-clock');
            if (clockElem) clockElem.innerText = `${hours}:${mins}`;
        };
        updateClock();
        setInterval(updateClock, 10000);
    }

    bindEvents() {
        window.addEventListener('resize', () => this.resize());

        // Desktop View Mode Toggle (Phone View vs Fullscreen)
        if (this.btnToggleView) {
            this.btnToggleView.addEventListener('click', () => {
                sound.playClick();
                if (this.phoneChassis.classList.contains('fullscreen-mode')) {
                    this.phoneChassis.classList.remove('fullscreen-mode');
                    this.toggleViewText.innerText = 'Full Screen';
                } else {
                    this.phoneChassis.classList.add('fullscreen-mode');
                    this.toggleViewText.innerText = 'Phone View';
                }
                setTimeout(() => this.resize(), 100);
            });
        }

        // Pointer / Mouse events on canvas
        this.canvas.addEventListener('mousemove', (e) => {
            const rect = this.canvas.getBoundingClientRect();
            this.game.handlePointerMove(e.clientX - rect.left, e.clientY - rect.top);
        });

        this.canvas.addEventListener('click', (e) => {
            sound.ensureContext();
            const rect = this.canvas.getBoundingClientRect();
            this.game.handlePointerClick(e.clientX - rect.left, e.clientY - rect.top);
        });

        // Touch events on canvas for low-latency mobile touch
        this.canvas.addEventListener('touchstart', (e) => {
            sound.ensureContext();
            if (e.touches.length > 0) {
                const touch = e.touches[0];
                const rect = this.canvas.getBoundingClientRect();
                this.game.handlePointerClick(touch.clientX - rect.left, touch.clientY - rect.top);
            }
        }, { passive: true });

        // Mobile Quick Thumb Pass Selector Buttons
        document.querySelectorAll('.mobile-pass-btn').forEach(btn => {
            const handlePassBtn = (e) => {
                e.preventDefault();
                sound.ensureContext();
                const playerNum = btn.dataset.player;
                if (playerNum) {
                    this.game.handleKeyPress(playerNum);
                }
            };
            btn.addEventListener('click', handlePassBtn);
            btn.addEventListener('touchstart', handlePassBtn, { passive: false });
        });

        // Keybindings
        window.addEventListener('keydown', (e) => {
            sound.ensureContext();
            if (e.key === 'Escape' || e.key === 'p' || e.key === 'P') {
                this.togglePause();
            } else {
                this.game.handleKeyPress(e.key);
            }
        });

        // Main Menu Buttons
        document.getElementById('btn-start-solo').addEventListener('click', () => {
            sound.playClick();
            this.startMatch('solo', 1, this.selectedDifficulty);
        });

        document.getElementById('btn-open-multiplayer').addEventListener('click', () => {
            sound.playClick();
            this.openModal(this.modeSelectModal);
        });

        document.getElementById('btn-open-settings').addEventListener('click', () => {
            sound.playClick();
            this.openModal(this.settingsModal);
        });

        // Close Buttons
        document.getElementById('btn-close-mode-modal').addEventListener('click', () => {
            sound.playClick();
            this.closeModal(this.modeSelectModal);
        });

        document.getElementById('btn-close-settings-modal').addEventListener('click', () => {
            sound.playClick();
            this.closeModal(this.settingsModal);
        });

        // Local Player Selection Count buttons
        document.querySelectorAll('.count-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                sound.playClick();
                document.querySelectorAll('.count-btn').forEach(b => b.classList.remove('active'));
                const target = e.currentTarget;
                target.classList.add('active');
                this.selectedHumanCount = parseInt(target.dataset.humans, 10);
            });
        });

        // Difficulty buttons
        document.querySelectorAll('.diff-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                sound.playClick();
                document.querySelectorAll('.diff-btn').forEach(b => b.classList.remove('active'));
                const target = e.currentTarget;
                target.classList.add('active');
                this.selectedDifficulty = target.dataset.diff;
            });
        });

        // Launch Match Button
        document.getElementById('btn-launch-local-game').addEventListener('click', () => {
            sound.playClick();
            this.closeModal(this.modeSelectModal);
            this.startMatch('local', this.selectedHumanCount, this.selectedDifficulty);
        });

        // Tabs
        document.getElementById('tab-local-mode').addEventListener('click', () => {
            sound.playClick();
            document.getElementById('tab-local-mode').classList.add('active');
            document.getElementById('tab-online-mode').classList.remove('active');
            document.getElementById('local-mode-section').classList.remove('hidden');
            document.getElementById('online-mode-section').classList.add('hidden');
        });

        document.getElementById('tab-online-mode').addEventListener('click', () => {
            sound.playClick();
            document.getElementById('tab-online-mode').classList.add('active');
            document.getElementById('tab-local-mode').classList.remove('active');
            document.getElementById('online-mode-section').classList.remove('hidden');
            document.getElementById('local-mode-section').classList.add('hidden');
        });

        // Online Lobby Buttons
        document.getElementById('btn-create-room').addEventListener('click', () => {
            sound.playClick();
            net.createRoom((code) => {
                document.getElementById('lobby-room-code').innerText = code;
                document.getElementById('online-lobby-status').classList.remove('hidden');
                document.getElementById('btn-start-online-game').removeAttribute('disabled');
            });
        });

        document.getElementById('btn-join-room').addEventListener('click', () => {
            const input = document.getElementById('room-code-input').value.trim();
            if (input.length > 0) {
                sound.playClick();
                net.joinRoom(input, (code) => {
                    document.getElementById('lobby-room-code').innerText = code;
                    document.getElementById('online-lobby-status').classList.remove('hidden');
                });
            }
        });

        document.getElementById('btn-start-online-game').addEventListener('click', () => {
            sound.playClick();
            this.closeModal(this.modeSelectModal);
            this.startMatch('online', 2, this.selectedDifficulty);
        });

        // HUD Buttons
        document.getElementById('btn-sound-toggle').addEventListener('click', () => {
            const enabled = sound.toggleSound();
            document.getElementById('btn-sound-toggle').innerHTML = enabled 
                ? '<i class="fa-solid fa-volume-high"></i>' 
                : '<i class="fa-solid fa-volume-xmark"></i>';
        });

        document.getElementById('btn-pause-game').addEventListener('click', () => {
            this.togglePause();
        });

        document.getElementById('btn-resume-game').addEventListener('click', () => {
            this.togglePause();
        });

        document.getElementById('btn-restart-game').addEventListener('click', () => {
            this.closeModal(this.pauseModal);
            this.startMatch(this.game.mode, this.game.numHumans, this.game.difficulty);
        });

        document.getElementById('btn-quit-to-menu').addEventListener('click', () => {
            this.closeModal(this.pauseModal);
            this.closeModal(this.gameOverModal);
            this.hudOverlay.classList.add('hidden');
            this.openModal(this.mainMenuModal);
            this.game.state = 'MENU';
        });

        document.getElementById('btn-play-again').addEventListener('click', () => {
            this.closeModal(this.gameOverModal);
            this.startMatch(this.game.mode, this.game.numHumans, this.game.difficulty);
        });

        document.getElementById('btn-game-over-menu').addEventListener('click', () => {
            this.closeModal(this.gameOverModal);
            this.hudOverlay.classList.add('hidden');
            this.openModal(this.mainMenuModal);
            this.game.state = 'MENU';
        });

        // Settings Toggles
        document.getElementById('setting-sfx').addEventListener('change', (e) => {
            sound.toggleSound(e.target.checked);
        });

        document.getElementById('setting-guidelines').addEventListener('change', (e) => {
            this.game.settings.showGuidelines = e.target.checked;
        });

        document.getElementById('setting-default-diff').addEventListener('change', (e) => {
            this.selectedDifficulty = e.target.value;
            if (this.game) {
                this.game.difficulty = e.target.value;
            }
        });

        // Turnover callback from game engine
        this.game.onTurnoverCallback = (data) => {
            this.handleGameTurnover(data);
        };
    }

    startMatch(mode, numHumans, difficulty) {
        this.closeModal(this.mainMenuModal);
        this.closeModal(this.modeSelectModal);
        this.closeModal(this.pauseModal);
        this.closeModal(this.gameOverModal);

        this.hudOverlay.classList.remove('hidden');

        // Set difficulty badge tag
        this.hudDifficultyTag.innerText = difficulty.toUpperCase();
        this.hudDifficultyTag.className = `difficulty-tag tag-${difficulty}`;

        this.game.init(mode, numHumans, difficulty);
        sound.playWhistle();
    }

    togglePause() {
        if (this.game.state === 'PLAYING') {
            this.game.state = 'PAUSED';
            this.openModal(this.pauseModal);
        } else if (this.game.state === 'PAUSED') {
            this.game.state = 'PLAYING';
            this.closeModal(this.pauseModal);
        }
    }

    handleGameTurnover(data) {
        document.getElementById('final-pass-count').innerText = data.finalScore;
        document.getElementById('final-combo-tier').innerText = `${this.game.comboMultiplier}x`;
        document.getElementById('turnover-desc-text').innerText = `${data.passer ? data.passer.name : 'Attacker'}'s pass was intercepted!`;

        const nextDefBanner = document.getElementById('next-defender-banner');
        if (this.game.numHumans > 1) {
            nextDefBanner.classList.remove('hidden');
            document.getElementById('next-defender-name').innerText = data.nextDefenderName;
        } else {
            nextDefBanner.classList.add('hidden');
        }

        const best = localStorage.getItem('rondo_best_streak') || '0';
        this.menuRecordScore.innerText = best;
        this.hudBestStreak.innerText = best;

        this.openModal(this.gameOverModal);
    }

    openModal(modal) {
        modal.classList.remove('hidden');
    }

    closeModal(modal) {
        modal.classList.add('hidden');
    }

    resize() {
        const viewport = this.canvas.parentElement || document.body;
        const width = viewport.clientWidth || window.innerWidth;
        const height = viewport.clientHeight || window.innerHeight;
        this.renderer.resize(width, height);
        this.game.resizePitch();
    }

    updateHUD() {
        this.hudScoreValue.innerText = this.game.score;
        this.hudComboMultiplier.innerText = `${this.game.comboMultiplier}x`;
        
        // Progress within 10-pass combo tier
        const progressInTier = this.game.passStreak % 10;
        const progressPct = (progressInTier / 10) * 100;
        this.hudComboProgress.style.width = `${progressPct}%`;
        this.hudComboStreakText.innerText = `${progressInTier} / 10 passes to next tier`;

        // Dynamically update HUD Difficulty Tag Badge
        if (this.game.difficulty) {
            this.hudDifficultyTag.innerText = this.game.difficulty.toUpperCase();
            this.hudDifficultyTag.className = `difficulty-tag tag-${this.game.difficulty}`;
        }

        if (this.game.ball.owner) {
            this.hudCarrierName.innerText = `${this.game.ball.owner.name} (Active Player)`;
        } else if (this.game.ball.isMoving) {
            this.hudCarrierName.innerText = 'Pass in air...';
        }
    }

    loop(currentTime) {
        const deltaTime = (currentTime - this.lastTime) / 1000;
        this.lastTime = currentTime;

        // Update Game Loop
        this.game.update(deltaTime);

        // Render Frame
        this.renderer.render({
            pitchCenter: this.game.pitchCenter,
            rondoRadius: this.game.rondoRadius,
            ball: this.game.ball,
            players: this.game.players,
            defender: this.game.defender,
            hoveredTarget: this.game.hoveredTarget,
            settings: this.game.settings,
            comboMultiplier: this.game.comboMultiplier
        });

        // Update HUD text
        if (this.game.state === 'PLAYING') {
            this.updateHUD();
        }

        requestAnimationFrame((time) => this.loop(time));
    }
}

// Instantiate on DOM load
window.addEventListener('DOMContentLoaded', () => {
    new App();
});
