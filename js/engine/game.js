// Core Game Logic & Rondo FC State Machine

import { Physics } from './physics.js';
import { Player } from '../entities/player.js';
import { Ball } from '../entities/ball.js';
import { TeammateAI } from '../ai/teammateAI.js';
import { DefenderAI } from '../ai/defenderAI.js';
import { sound } from '../audio/sound.js';

export class GameEngine {
    constructor(canvas, renderer) {
        this.canvas = canvas;
        this.renderer = renderer;

        this.state = 'MENU'; // MENU, PLAYING, PAUSED, TURNOVER
        this.mode = 'solo'; // solo, local, online
        this.numHumans = 1;
        this.difficulty = 'medium';

        this.pitchCenter = { x: 0, y: 0 };
        this.rondoRadius = 240;

        this.players = [];
        this.defender = null;
        this.ball = new Ball();

        this.score = 0;
        this.passStreak = 0;
        this.bestStreak = parseInt(localStorage.getItem('rondo_best_streak') || '0', 10);
        this.comboMultiplier = 1;

        this.hoveredTarget = null;
        this.aiPassTimer = 0;

        this.settings = {
            sfx: true,
            showGuidelines: true,
            defaultDifficulty: 'medium'
        };

        this.activeDefenderIndex = 5; // 0-4 attackers, 5 center defender
    }

    init(mode = 'solo', numHumans = 1, difficulty = 'medium') {
        this.mode = mode;
        this.numHumans = numHumans;
        this.difficulty = difficulty;

        this.score = 0;
        this.passStreak = 0;
        this.comboMultiplier = 1;

        this.resizePitch();
        this.setupEntities();
        this.state = 'PLAYING';
    }

    resizePitch() {
        this.pitchCenter = {
            x: this.canvas.width / 2,
            y: this.canvas.height / 2
        };
        this.rondoRadius = Math.min(this.canvas.width, this.canvas.height) * 0.34;
    }

    setupEntities() {
        this.players = [];

        // Iconic Cartoon Football Stars Definitions
        const starAttackers = [
            { name: 'Messi', number: 10, jerseyColor: '#ff007f', secondaryColor: '#00e5ff', hairColor: '#4a2c11', skinColor: '#f5cda7', beard: true, style: 'messi' },
            { name: 'Mbappé', number: 9, jerseyColor: '#0038a8', secondaryColor: '#ffffff', hairColor: '#121212', skinColor: '#7a4e2d', headband: '#ffffff', style: 'mbappe' },
            { name: 'Ronaldo', number: 7, jerseyColor: '#d6001c', secondaryColor: '#ffc800', hairColor: '#1a1a1a', skinColor: '#e5b88f', style: 'ronaldo' },
            { name: 'Neymar', number: 11, jerseyColor: '#ffea00', secondaryColor: '#009b3a', hairColor: '#e0c068', skinColor: '#c68d5c', headband: '#121212', style: 'neymar' },
            { name: 'Haaland', number: 99, jerseyColor: '#6cabdd', secondaryColor: '#ffffff', hairColor: '#f7e28b', skinColor: '#fbe3d0', ponytail: true, style: 'haaland' }
        ];

        // Create 5 Cartoon Star Attackers around rondo circle
        for (let i = 0; i < 5; i++) {
            const angle = i * (Math.PI * 2 / 5);
            const isHuman = (this.mode === 'solo' || this.numHumans === 1) ? true : (i < this.numHumans);
            const charInfo = starAttackers[i];
            
            const player = new Player(i + 1, charInfo.name, 'attacker', isHuman, charInfo.number, charInfo.jerseyColor, charInfo);
            player.baseAngle = angle;
            player.setPosition(
                this.pitchCenter.x + Math.cos(angle) * this.rondoRadius,
                this.pitchCenter.y + Math.sin(angle) * this.rondoRadius
            );
            this.players.push(player);
        }

        // Create Defender Maldini
        const maldiniInfo = {
            name: 'Maldini',
            number: 3,
            jerseyColor: '#990000',
            stripeColor: '#1a1a1a',
            skinColor: '#d9a77c',
            hairColor: '#362215',
            armband: '#ffea00',
            style: 'maldini'
        };

        const defenderIsHuman = false;
        this.defender = new Player(6, 'Maldini', 'defender', defenderIsHuman, 3, '#990000', maldiniInfo);
        this.defender.setPosition(this.pitchCenter.x, this.pitchCenter.y);

        // Give Ball to Messi initially (Initial Active Player)
        const startingPlayer = this.players[0];
        startingPlayer.hasBall = true;
        this.ball.reset(startingPlayer.x, startingPlayer.y);
        this.ball.owner = startingPlayer;
    }

    update(deltaTime = 0.016) {
        if (this.state !== 'PLAYING') return;

        // 1. Update AI Teammate Positions along Perimeter
        TeammateAI.updatePositioning(this.players, this.defender, this.pitchCenter, this.rondoRadius);

        // 2. Update Players (smooth movement)
        this.players.forEach(p => p.update(this.pitchCenter, this.rondoRadius));
        this.defender.update(this.pitchCenter, this.rondoRadius);

        // 3. Update Defender AI Strategy
        if (!this.defender.isHuman) {
            DefenderAI.update(this.defender, this.ball, this.players, this.pitchCenter, this.difficulty, deltaTime);
        }

        // 4. Update Ball Physics
        this.ball.update();

        // 5. Check Interceptions & Catching Logic
        this.checkBallInteractions();

        // 6. Handle AI Teammate Auto-Passes
        this.handleAIPasses(deltaTime);
    }

    checkBallInteractions() {
        const ball = this.ball;

        // A. Defender Interception Check
        const defDist = Physics.distance(this.defender, ball);
        const interceptRadius = this.defender.radius + ball.radius + 6;

        if (defDist <= interceptRadius && (!ball.owner || ball.owner.id !== this.defender.id)) {
            // TURNOVER / INTERCEPTION TRIGGERED!
            this.handleInterception();
            return;
        }

        // B. Ball Reception Check (if ball is in flight/loose)
        if (ball.isMoving && !ball.owner) {
            this.players.forEach(player => {
                const dist = Physics.distance(player, ball);
                const catchRadius = player.radius + ball.radius + 4;

                // Player catches the ball if within reach and not the sender
                if (dist <= catchRadius && ball.passSender && ball.passSender.id !== player.id) {
                    ball.owner = player;
                    player.hasBall = true;
                    if (ball.passSender) ball.passSender.hasBall = false;

                    // Successful Pass Completed!
                    this.onPassCompleted(ball.passSender, player);
                }
            });
        }
    }

    onPassCompleted(sender, receiver) {
        this.score++;
        this.passStreak++;

        if (this.passStreak > this.bestStreak) {
            this.bestStreak = this.passStreak;
            localStorage.setItem('rondo_best_streak', this.bestStreak.toString());
        }

        // Dynamic difficulty level progression as streak increases!
        const prevDifficulty = this.difficulty;
        if (this.passStreak >= 25) {
            this.difficulty = 'pro';
        } else if (this.passStreak >= 15) {
            this.difficulty = 'hard';
        } else if (this.passStreak >= 7 && (prevDifficulty === 'easy')) {
            this.difficulty = 'medium';
        }

        // Show difficulty level up alert on screen if difficulty changes
        if (this.difficulty !== prevDifficulty) {
            this.renderer.addFloatingText(`MALDINI UPGRADED TO ${this.difficulty.toUpperCase()}! 🔥`, this.defender.x, this.defender.y - 35, '#ff3b5c');
            sound.playCombo(3);
        }

        // Combo Multiplier calculation (Every 10 passes = +1x multiplier)
        const newMultiplier = Math.floor(this.passStreak / 10) + 1;
        if (newMultiplier > this.comboMultiplier) {
            this.comboMultiplier = newMultiplier;
            sound.playCombo(this.comboMultiplier);
            this.renderer.addFloatingText(`${this.passStreak} STREAK! ${this.comboMultiplier}x COMBO!`, receiver.x, receiver.y - 20, '#ffc800');
        } else {
            this.renderer.addFloatingText('+1', receiver.x, receiver.y - 20, '#00ff87');
        }

        this.renderer.addImpactParticles(receiver.x, receiver.y, 10, receiver.color);
        sound.playCatch();
    }

    handleInterception() {
        sound.playInterception();
        sound.playWhistle();
        this.state = 'TURNOVER';

        const lastPasser = this.ball.passSender || this.players[0];

        // Multiplayer defender switch rule: passer becomes next defender!
        let nextDefenderName = 'AI Defender';
        if (this.numHumans > 1 && lastPasser) {
            nextDefenderName = lastPasser.name;
        }

        // Reset streak
        this.passStreak = 0;
        this.comboMultiplier = 1;

        // Callback to UI module
        if (this.onTurnoverCallback) {
            this.onTurnoverCallback({
                passer: lastPasser,
                nextDefenderName,
                finalScore: this.score,
                bestStreak: this.bestStreak
            });
        }
    }

    executePass(fromPlayer, targetPlayer) {
        if (!fromPlayer || !targetPlayer || !fromPlayer.hasBall || fromPlayer.id === targetPlayer.id) return;
        if (this.ball.isMoving) return;

        fromPlayer.hasBall = false;
        fromPlayer.facingAngle = Physics.angleBetween(fromPlayer, targetPlayer);
        
        // Pass power scales slightly with distance
        const dist = Physics.distance(fromPlayer, targetPlayer);
        const power = Math.max(9, Math.min(15, dist * 0.045));

        this.ball.kick(fromPlayer, targetPlayer, power, false);
    }

    handleAIPasses(deltaTime) {
        if (!this.ball.owner) return;
        const carrier = this.ball.owner;

        // If carrier is AI
        if (!carrier.isHuman) {
            this.aiPassTimer += deltaTime;
            // AI reaction delay before passing (200ms - 400ms)
            if (this.aiPassTimer > 0.35) {
                this.aiPassTimer = 0;
                const target = TeammateAI.chooseSafestPassTarget(carrier, this.players, this.defender);
                if (target) {
                    this.executePass(carrier, target);
                }
            }
        } else {
            this.aiPassTimer = 0;
        }
    }

    handlePointerMove(mouseX, mouseY) {
        if (this.state !== 'PLAYING') return;
        
        // Find hovered target player
        let closest = null;
        let minDist = 50;

        this.players.forEach(p => {
            if (this.ball.owner && p.id === this.ball.owner.id) return;
            const dist = Math.hypot(p.x - mouseX, p.y - mouseY);
            if (dist < minDist) {
                minDist = dist;
                closest = p;
            }
        });

        this.hoveredTarget = closest;
    }

    handlePointerClick(mouseX, mouseY) {
        if (this.state !== 'PLAYING' || !this.ball.owner) return;

        const carrier = this.ball.owner;
        if (!carrier.isHuman) return;

        let targetToPass = this.hoveredTarget;

        // If click coordinates provided and no direct hover, check direction of click relative to carrier
        if (!targetToPass && mouseX !== undefined && mouseY !== undefined) {
            const clickAngle = Math.atan2(mouseY - carrier.y, mouseX - carrier.x);
            let bestMatch = null;
            let smallestAngleDiff = 0.55; // Angle cone tolerance (~30 degrees)

            this.players.forEach(p => {
                if (p.id === carrier.id) return;
                const pAngle = Math.atan2(p.y - carrier.y, p.x - carrier.x);
                let angleDiff = Math.abs(clickAngle - pAngle);
                if (angleDiff > Math.PI) angleDiff = 2 * Math.PI - angleDiff;

                if (angleDiff < smallestAngleDiff) {
                    smallestAngleDiff = angleDiff;
                    bestMatch = p;
                }
            });

            targetToPass = bestMatch;
        }

        // Only execute pass if user explicitly aimed at or selected a teammate!
        if (targetToPass) {
            this.executePass(carrier, targetToPass);
        }
    }

    handleKeyPress(key) {
        if (this.state !== 'PLAYING' || !this.ball.owner || !this.ball.owner.isHuman) return;

        // Keys 1-5 target specific teammate number!
        const num = parseInt(key, 10);
        if (num >= 1 && num <= 5) {
            const target = this.players.find(p => p.number === num);
            if (target && target.id !== this.ball.owner.id) {
                this.executePass(this.ball.owner, target);
            }
        }

        // Spacebar passes to hovered or safest teammate
        if (key === ' ' || key === 'Space') {
            this.handlePointerClick();
        }
    }
}
