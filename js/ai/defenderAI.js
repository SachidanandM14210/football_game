// AI Defender Press & Interception Strategy Engine

import { Physics } from '../engine/physics.js';

export const DIFFICULTY_CONFIG = {
    easy: {
        speed: 2.6,
        reactionDelay: 320, // ms
        interceptionRadius: 28,
        predictiveCut: 0.2, // 0 to 1
        pressAggression: 0.5
    },
    medium: {
        speed: 3.3,
        reactionDelay: 180,
        interceptionRadius: 34,
        predictiveCut: 0.5,
        pressAggression: 0.75
    },
    hard: {
        speed: 4.0,
        reactionDelay: 90,
        interceptionRadius: 40,
        predictiveCut: 0.8,
        pressAggression: 0.95
    },
    pro: {
        speed: 4.6,
        reactionDelay: 30,
        interceptionRadius: 46,
        predictiveCut: 1.0,
        pressAggression: 1.2
    }
};

export class DefenderAI {
    static update(defender, ball, teammates, pitchCenter, difficulty = 'medium', deltaTime = 0.016) {
        const config = DIFFICULTY_CONFIG[difficulty] || DIFFICULTY_CONFIG.medium;
        defender.baseSpeed = config.speed;

        // If ball is in motion (pass in air or ground)
        if (ball.isMoving) {
            // Predict closest point on ball trajectory vector to intercept
            const ballStart = { x: ball.x, y: ball.y };
            const ballEnd = { 
                x: ball.x + ball.vx * 20 * config.predictiveCut, 
                y: ball.y + ball.vy * 20 * config.predictiveCut 
            };

            const interceptTarget = Physics.closestPointOnSegment(defender, ballStart, ballEnd);
            defender.targetX = Physics.lerp(defender.x, interceptTarget.x, 0.2);
            defender.targetY = Physics.lerp(defender.y, interceptTarget.y, 0.2);
            defender.facingAngle = Physics.angleBetween(defender, ball);
            return;
        }

        // If ball is held by a player (Active Player) -> defender directly approaches the player!
        if (ball.owner) {
            const carrier = ball.owner;
            
            // Defender continuously closes down and approaches the ball carrier directly
            defender.targetX = carrier.x;
            defender.targetY = carrier.y;
            defender.facingAngle = Physics.angleBetween(defender, carrier);
            return;
        }

        // Fallback: Return to pitch center
        defender.targetX = pitchCenter.x;
        defender.targetY = pitchCenter.y;
    }
}
