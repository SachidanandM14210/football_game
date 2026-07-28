// Ball Entity Module

import { Physics } from '../engine/physics.js';
import { sound } from '../audio/sound.js';

export class Ball {
    constructor(x = 0, y = 0) {
        this.x = x;
        this.y = y;
        this.z = 0; // Height off ground
        this.vx = 0;
        this.vy = 0;
        this.vz = 0;
        
        this.radius = 8;
        this.friction = 0.985;
        this.gravity = 0.4;
        
        this.owner = null; // Player currently holding ball
        this.passSender = null; // Player who kicked ball
        this.targetReceiver = null; // Intended target player
        
        this.isMoving = false;
        this.speed = 0;
        
        // Particle trail history
        this.trail = [];
    }

    reset(x, y) {
        this.x = x;
        this.y = y;
        this.z = 0;
        this.vx = 0;
        this.vy = 0;
        this.vz = 0;
        this.owner = null;
        this.passSender = null;
        this.targetReceiver = null;
        this.isMoving = false;
        this.trail = [];
    }

    kick(fromPlayer, targetPlayer, power = 10, isLob = false) {
        this.owner = null;
        this.passSender = fromPlayer;
        this.targetReceiver = targetPlayer;
        
        const angle = Physics.angleBetween(fromPlayer, targetPlayer);
        this.speed = power;
        
        this.vx = Math.cos(angle) * power;
        this.vy = Math.sin(angle) * power;
        
        if (isLob) {
            this.vz = 6;
        } else {
            this.vz = 1.5;
        }
        
        this.isMoving = true;
        sound.playPass(power / 10);
    }

    update() {
        if (this.owner) {
            // Ball sticks near owner's feet
            const offsetDist = 12;
            const facingAngle = this.owner.facingAngle || 0;
            this.x = Physics.lerp(this.x, this.owner.x + Math.cos(facingAngle) * offsetDist, 0.4);
            this.y = Physics.lerp(this.y, this.owner.y + Math.sin(facingAngle) * offsetDist, 0.4);
            this.z = 0;
            this.vx = 0;
            this.vy = 0;
            this.vz = 0;
            this.isMoving = false;
            return;
        }

        if (this.isMoving) {
            this.x += this.vx;
            this.y += this.vy;
            
            // Height elevation physics
            this.z += this.vz;
            if (this.z > 0) {
                this.vz -= this.gravity;
            } else {
                this.z = 0;
                this.vz = -this.vz * 0.4; // Bounce dampening
                if (Math.abs(this.vz) < 0.5) this.vz = 0;
            }

            // Ground friction
            this.vx *= this.friction;
            this.vy *= this.friction;
            
            this.speed = Math.sqrt(this.vx * this.vx + this.vy * this.vy);
            
            if (this.speed < 0.2 && this.z <= 0) {
                this.isMoving = false;
                this.vx = 0;
                this.vy = 0;
            }

            // Store trail particle points
            if (this.speed > 2) {
                this.trail.unshift({ x: this.x, y: this.y, z: this.z, alpha: 1.0 });
                if (this.trail.length > 12) this.trail.pop();
            }
        }

        // Fade trail
        this.trail.forEach(t => t.alpha *= 0.85);
    }
}
