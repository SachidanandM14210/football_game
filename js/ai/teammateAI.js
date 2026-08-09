// AI Teammate Positioning & Safe Passing Decision Engine

import { Physics } from '../engine/physics.js';

export class TeammateAI {
    static updatePositioning(teammates, defender, pitchCenter, rondoRadius) {
        teammates.forEach((p, idx) => {
            // Base slot angle (equal distribution around rondo circle: 72 degrees apart)
            const baseAngle = p.baseAngle || (idx * (Math.PI * 2 / 5));
            
            // Calculate vector from defender to player
            const angleFromDefender = Physics.angleBetween(defender, p);
            
            // Subtle arc shifting to open up passing lanes away from defender
            let shiftOffset = 0;
            const distToDefender = Physics.distance(p, defender);
            
            if (distToDefender < rondoRadius * 0.9) {
                // If defender gets close, shift away along perimeter
                const defenderAngleOnCircle = Physics.angleBetween(pitchCenter, defender);
                const angleDiff = baseAngle - defenderAngleOnCircle;
                
                // Shift in the direction away from defender
                shiftOffset = Math.sign(Math.sin(angleDiff)) * 0.22;
            }

            const targetAngle = baseAngle + shiftOffset;
            
            p.targetX = pitchCenter.x + Math.cos(targetAngle) * rondoRadius;
            p.targetY = pitchCenter.y + Math.sin(targetAngle) * rondoRadius;
            p.facingAngle = Physics.angleBetween(p, defender);
        });
    }

    static chooseSafestPassTarget(ballCarrier, teammates, defender, passSender = null) {
        let candidates = teammates.filter(p => p.id !== ballCarrier.id && (!passSender || p.id !== passSender.id));
        if (candidates.length === 0) {
            candidates = teammates.filter(p => p.id !== ballCarrier.id);
        }
        if (candidates.length === 0) return null;

        let bestCandidate = null;
        let highestSafetyScore = -Infinity;

        candidates.forEach(candidate => {
            // Distance to candidate
            const passDist = Physics.distance(ballCarrier, candidate);
            
            // Distance from defender to pass trajectory segment
            const defenderDistToPassLine = Physics.distanceToSegment(defender, ballCarrier, candidate);
            
            // Angle between pass direction and defender vector
            const passAngle = Physics.angleBetween(ballCarrier, candidate);
            const defAngle = Physics.angleBetween(ballCarrier, defender);
            let angleDiff = Math.abs(passAngle - defAngle);
            if (angleDiff > Math.PI) angleDiff = 2 * Math.PI - angleDiff;

            // Safety formula:
            // 1. High defender clearance distance (+3.0x weight)
            // 2. High angle separation from defender (+2.0x weight)
            // 3. Moderate pass distance (avoid ultra long risky ground passes if defender is centered)
            let safetyScore = (defenderDistToPassLine * 3.5) + (angleDiff * 45) - (passDist * 0.15);

            // Penalize heavily if defender is directly on the passing lane
            if (defenderDistToPassLine < 35 && angleDiff < 0.6) {
                safetyScore -= 300;
            }

            if (safetyScore > highestSafetyScore) {
                highestSafetyScore = safetyScore;
                bestCandidate = candidate;
            }
        });

        return bestCandidate;
    }
}
