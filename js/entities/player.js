// Player Entity Module

import { Physics } from '../engine/physics.js';

export class Player {
    constructor(id, name, role = 'attacker', isHuman = false, number = 1, color = '#00ff87', charData = {}) {
        this.id = id;
        this.name = name;
        this.role = role; // 'attacker' or 'defender'
        this.isHuman = isHuman;
        this.number = number;
        this.color = color;
        
        // Cartoon Character Attributes
        this.skinColor = charData.skinColor || '#f5cda7';
        this.hairColor = charData.hairColor || '#1a1a1a';
        this.jerseyColor = charData.jerseyColor || color;
        this.secondaryColor = charData.secondaryColor || '#ffffff';
        this.stripeColor = charData.stripeColor || null;
        this.beard = charData.beard || false;
        this.headband = charData.headband || null;
        this.ponytail = charData.ponytail || false;
        this.armband = charData.armband || null;
        this.style = charData.style || 'default';
        
        this.x = 0;
        this.y = 0;
        this.vx = 0;
        this.vy = 0;
        
        this.radius = 20; // Increased radius for clear cartoon avatar details
        this.baseSpeed = role === 'defender' ? 3.4 : 3.0;
        this.facingAngle = 0;
        
        // Designated home slot on perimeter (for attackers)
        this.baseAngle = 0;
        this.targetX = 0;
        this.targetY = 0;
        
        // Pass selection state
        this.selectedTarget = null;
        this.passCooldown = 0;
        this.hasBall = false;
        
        // AI State
        this.aiShiftAngle = 0;
    }

    setPosition(x, y) {
        this.x = x;
        this.y = y;
        this.targetX = x;
        this.targetY = y;
    }

    update(pitchCenter, rondoRadius) {
        // Cooldown timer
        if (this.passCooldown > 0) this.passCooldown--;

        // Move towards target position smoothly
        const dx = this.targetX - this.x;
        const dy = this.targetY - this.y;
        const dist = Math.sqrt(dx * dx + dy * dy);
        
        if (dist > 1) {
            const moveSpeed = Math.min(this.baseSpeed, dist * 0.15);
            this.vx = (dx / dist) * moveSpeed;
            this.vy = (dy / dist) * moveSpeed;
            this.x += this.vx;
            this.y += this.vy;
        } else {
            this.vx = 0;
            this.vy = 0;
        }

        // Clamp to field perimeter if attacker
        if (this.role === 'attacker') {
            const distFromCenter = Physics.distance(this, pitchCenter);
            if (Math.abs(distFromCenter - rondoRadius) > 40) {
                const angle = Physics.angleBetween(pitchCenter, this);
                this.x = pitchCenter.x + Math.cos(angle) * rondoRadius;
                this.y = pitchCenter.y + Math.sin(angle) * rondoRadius;
            }
        }
    }
}
