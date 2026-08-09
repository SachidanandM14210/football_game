// Canvas 2D Renderer Engine

import { Physics } from '../engine/physics.js';

export class Renderer {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.particles = [];
        this.floatingTexts = [];
        this.messiImg = new Image();
        this.messiImg.src = 'images/messi.png';
    }

    resize(width, height) {
        this.canvas.width = width;
        this.canvas.height = height;
    }

    render(gameState) {
        const ctx = this.ctx;
        const w = this.canvas.width;
        const h = this.canvas.height;

        // Clear Viewport
        ctx.fillStyle = '#06100b';
        ctx.fillRect(0, 0, w, h);

        const { pitchCenter, rondoRadius, ball, players, defender, hoveredTarget, settings, comboMultiplier } = gameState;

        // 1. Draw Pitch Grass & Markings
        this.drawPitch(pitchCenter, rondoRadius);

        // 2. Draw Passing Lane & Defender Shadow Cone Guidelines (if enabled)
        if (settings.showGuidelines && ball.owner) {
            this.drawGuidelines(ball.owner, players, defender, hoveredTarget);
        }

        // 3. Draw Particles (pass trails, impact bursts)
        this.drawParticles();

        // 4. Draw Players
        players.forEach(p => this.drawPlayer(p, ball.owner === p, hoveredTarget === p));

        // 5. Draw Defender
        if (defender) {
            this.drawDefender(defender);
        }

        // 6. Draw Ball (with elevation shadow)
        if (ball) {
            this.drawBall(ball, comboMultiplier);
        }

        // 7. Draw Floating Combo / Score Texts
        this.drawFloatingTexts();
    }

    drawPitch(center, radius) {
        const ctx = this.ctx;
        
        // Pitch Base Gradient
        const pitchGrad = ctx.createRadialGradient(center.x, center.y, 10, center.x, center.y, radius * 1.6);
        pitchGrad.addColorStop(0, '#0c2419');
        pitchGrad.addColorStop(0.7, '#071810');
        pitchGrad.addColorStop(1, '#040d09');

        ctx.fillStyle = pitchGrad;
        ctx.beginPath();
        ctx.arc(center.x, center.y, radius * 1.5, 0, Math.PI * 2);
        ctx.fill();

        // Rondo Circular Grass Stripes
        const ringCount = 5;
        for (let i = ringCount; i >= 1; i--) {
            ctx.fillStyle = i % 2 === 0 ? 'rgba(0, 255, 135, 0.02)' : 'rgba(0, 0, 0, 0.04)';
            ctx.beginPath();
            ctx.arc(center.x, center.y, (radius * 1.4) * (i / ringCount), 0, Math.PI * 2);
            ctx.fill();
        }

        // Outer Rondo Boundary Circle Line
        ctx.strokeStyle = 'rgba(0, 255, 135, 0.25)';
        ctx.lineWidth = 3;
        ctx.setLineDash([8, 6]);
        ctx.beginPath();
        ctx.arc(center.x, center.y, radius, 0, Math.PI * 2);
        ctx.stroke();
        ctx.setLineDash([]);

        // Pitch Center Spot
        ctx.fillStyle = 'rgba(0, 255, 135, 0.4)';
        ctx.beginPath();
        ctx.arc(center.x, center.y, 6, 0, Math.PI * 2);
        ctx.fill();

        // Inner Defender Zone boundary
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.08)';
        ctx.lineWidth = 1.5;
        ctx.beginPath();
        ctx.arc(center.x, center.y, radius * 0.45, 0, Math.PI * 2);
        ctx.stroke();
    }

    drawGuidelines(carrier, players, defender, hoveredTarget) {
        const ctx = this.ctx;

        // Defender shadow cone (danger angle)
        const defDist = Physics.distance(carrier, defender);
        const defAngle = Physics.angleBetween(carrier, defender);
        const coneWidth = Math.min(0.6, 50 / defDist);

        ctx.fillStyle = 'rgba(255, 59, 92, 0.08)';
        ctx.beginPath();
        ctx.moveTo(carrier.x, carrier.y);
        ctx.arc(carrier.x, carrier.y, 350, defAngle - coneWidth, defAngle + coneWidth);
        ctx.closePath();
        ctx.fill();

        // Target Pass Preview Line
        if (hoveredTarget && hoveredTarget.id !== carrier.id) {
            ctx.strokeStyle = 'rgba(0, 229, 255, 0.7)';
            ctx.lineWidth = 3;
            ctx.setLineDash([6, 4]);
            ctx.beginPath();
            ctx.moveTo(carrier.x, carrier.y);
            ctx.lineTo(hoveredTarget.x, hoveredTarget.y);
            ctx.stroke();
            ctx.setLineDash([]);

            // Target ring pulse
            ctx.strokeStyle = '#00e5ff';
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.arc(hoveredTarget.x, hoveredTarget.y, 24, 0, Math.PI * 2);
            ctx.stroke();
        }
    }

    drawPlayer(p, hasBall, isHovered) {
        const ctx = this.ctx;
        const headR = 24; // Big comedy caricature head radius

        // 1. Drop Shadow
        ctx.fillStyle = 'rgba(0, 0, 0, 0.45)';
        ctx.beginPath();
        ctx.ellipse(p.x, p.y + 32, 22, 9, 0, 0, Math.PI * 2);
        ctx.fill();

        // 2. Active Player Glow / Target Highlight
        if (hasBall) {
            ctx.shadowColor = '#ffc800';
            ctx.shadowBlur = 22;
            ctx.strokeStyle = '#ffc800';
            ctx.lineWidth = 4;
            ctx.beginPath();
            ctx.arc(p.x, p.y - 4, headR + 8, 0, Math.PI * 2);
            ctx.stroke();
            ctx.shadowBlur = 0;
        } else if (isHovered) {
            ctx.strokeStyle = '#00e5ff';
            ctx.lineWidth = 3;
            ctx.beginPath();
            ctx.arc(p.x, p.y - 4, headR + 6, 0, Math.PI * 2);
            ctx.stroke();
        }

        // 3. Tiny Body & Kit
        const bodyY = p.y + 14;
        ctx.fillStyle = p.jerseyColor || '#00ff87';
        ctx.beginPath();
        ctx.roundRect(p.x - 12, bodyY, 24, 16, 4);
        ctx.fill();

        // Collar trim
        ctx.strokeStyle = p.secondaryColor || '#ffffff';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(p.x - 6, bodyY);
        ctx.lineTo(p.x, bodyY + 6);
        ctx.lineTo(p.x + 6, bodyY);
        ctx.stroke();

        // Shorts & Tiny Legs
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(p.x - 10, bodyY + 16, 20, 6); // Shorts
        
        ctx.fillStyle = p.skinColor || '#f5cda7';
        ctx.fillRect(p.x - 8, bodyY + 22, 5, 8); // Left leg
        ctx.fillRect(p.x + 3, bodyY + 22, 5, 8); // Right leg

        ctx.fillStyle = p.secondaryColor || '#ffffff';
        ctx.fillRect(p.x - 9, bodyY + 28, 7, 3); // Left boot
        ctx.fillRect(p.x + 2, bodyY + 28, 7, 3); // Right boot

        // 4. Big Comedy Caricature Ears (Sticking out on sides like reference image!)
        ctx.fillStyle = p.skinColor || '#f5cda7';
        ctx.strokeStyle = 'rgba(0, 0, 0, 0.3)';
        ctx.lineWidth = 1.5;

        // Left Ear
        ctx.beginPath();
        ctx.ellipse(p.x - headR - 2, p.y - 2, 6, 9, -0.2, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();

        // Right Ear
        ctx.beginPath();
        ctx.ellipse(p.x + headR + 2, p.y - 2, 6, 9, 0.2, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();

        // 5. Big Caricature Head
        if (p.style === 'messi' && this.messiImg.complete && this.messiImg.naturalWidth !== 0) {
            // Draw custom Messi picture avatar in small scale
            ctx.save();
            ctx.beginPath();
            ctx.arc(p.x, p.y - 6, headR + 2, 0, Math.PI * 2);
            ctx.clip();

            const imgDim = (headR + 4) * 2;
            ctx.drawImage(this.messiImg, p.x - imgDim / 2, (p.y - 6) - imgDim / 2, imgDim, imgDim);
            ctx.restore();

            // Head border ring & captain armband
            ctx.strokeStyle = '#ff007f';
            ctx.lineWidth = 2.5;
            ctx.beginPath();
            ctx.arc(p.x, p.y - 6, headR + 2, 0, Math.PI * 2);
            ctx.stroke();

            ctx.fillStyle = '#ff9100';
            ctx.fillRect(p.x - 12, bodyY + 3, 5, 8);
        } else {
            ctx.fillStyle = p.skinColor || '#f5cda7';
            ctx.beginPath();
            ctx.arc(p.x, p.y - 6, headR, 0, Math.PI * 2);
            ctx.fill();

            ctx.strokeStyle = '#121212';
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.arc(p.x, p.y - 6, headR, 0, Math.PI * 2);
            ctx.stroke();

            // 6. Character Specific Hairstyles & Comedy Details
            ctx.fillStyle = p.hairColor || '#1a1a1a';

            if (p.style === 'messi') {
                // Messi Brown Comb-Over
                ctx.beginPath();
                ctx.arc(p.x - 2, p.y - 12, headR * 0.95, Math.PI * 0.8, Math.PI * 1.95);
                ctx.fill();

                // Messi Big Reddish-Brown Beard
                ctx.fillStyle = '#8b4513';
                ctx.beginPath();
                ctx.arc(p.x, p.y - 2, headR * 0.9, 0.2, Math.PI - 0.2);
                ctx.fill();

                // Mouth inside beard
                ctx.fillStyle = '#121212';
                ctx.beginPath();
                ctx.arc(p.x, p.y + 4, 3, 0, Math.PI);
                ctx.fill();

                // Captain Armband
                ctx.fillStyle = '#ff9100';
                ctx.fillRect(p.x - 12, bodyY + 3, 5, 8);
            } else if (p.style === 'mbappe') {
                // Mbappé Buzzcut + White Headband
                ctx.beginPath();
                ctx.arc(p.x, p.y - 8, headR * 0.98, Math.PI * 0.85, Math.PI * 2.15);
                ctx.fill();

                // White Headband
                ctx.fillStyle = '#ffffff';
                ctx.fillRect(p.x - headR + 1, p.y - 12, headR * 2 - 2, 5);

                // Cheerful Wide Smile
                ctx.fillStyle = '#ffffff';
                ctx.beginPath();
                ctx.arc(p.x, p.y + 3, 6, 0, Math.PI);
                ctx.fill();
                ctx.strokeStyle = '#121212';
                ctx.lineWidth = 1.5;
                ctx.stroke();
            } else if (p.style === 'ronaldo') {
                // CR7 Sharp Fade Haircut
                ctx.beginPath();
                ctx.arc(p.x + 2, p.y - 10, headR * 0.92, Math.PI * 0.8, Math.PI * 2.05);
                ctx.fill();

                // Ear Diamond Stud Sparkle
                ctx.fillStyle = '#ffffff';
                ctx.beginPath();
                ctx.arc(p.x - headR - 2, p.y + 2, 2, 0, Math.PI * 2);
                ctx.fill();

                // Confident Smirk
                ctx.strokeStyle = '#121212';
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.arc(p.x + 2, p.y + 3, 5, 0.2, Math.PI * 0.8);
                ctx.stroke();
            } else if (p.style === 'neymar') {
                // Neymar Blonde Curly Top
                ctx.fillStyle = p.hairColor || '#e0c068';
                ctx.beginPath();
                ctx.arc(p.x, p.y - 10, headR * 0.9, Math.PI * 0.75, Math.PI * 2.25);
                ctx.fill();

                // Dark Headband
                ctx.fillStyle = '#121212';
                ctx.fillRect(p.x - headR + 2, p.y - 8, headR * 2 - 4, 4);
            } else if (p.style === 'haaland') {
                // Haaland Bright Blonde Hair
                ctx.fillStyle = '#f7e28b';
                ctx.beginPath();
                ctx.arc(p.x, p.y - 8, headR, Math.PI * 0.9, Math.PI * 2.1);
                ctx.fill();

                // Viking Topknot Ponytail
                ctx.beginPath();
                ctx.arc(p.x, p.y - headR - 10, 6, 0, Math.PI * 2);
                ctx.fill();
            } else {
                // Default Hair
                ctx.beginPath();
                ctx.arc(p.x, p.y - 8, headR, Math.PI, Math.PI * 2);
                ctx.fill();
            }

            // 7. Expressive Caricature Eyes
            const eyeOffset = 6;
            const eyeY = p.y - 6;
            const eyeDirX = Math.cos(p.facingAngle) * 2.5;
            const eyeDirY = Math.sin(p.facingAngle) * 2.5;

            ctx.fillStyle = '#ffffff';
            ctx.beginPath();
            ctx.arc(p.x - eyeOffset, eyeY, 4.5, 0, Math.PI * 2);
            ctx.arc(p.x + eyeOffset, eyeY, 4.5, 0, Math.PI * 2);
            ctx.fill();

            ctx.strokeStyle = '#121212';
            ctx.lineWidth = 1.5;
            ctx.stroke();

            // Pupils
            ctx.fillStyle = '#121212';
            ctx.beginPath();
            ctx.arc(p.x - eyeOffset + eyeDirX, eyeY + eyeDirY, 2.2, 0, Math.PI * 2);
            ctx.arc(p.x + eyeOffset + eyeDirX, eyeY + eyeDirY, 2.2, 0, Math.PI * 2);
            ctx.fill();

            // Eyebrows
            ctx.strokeStyle = p.hairColor || '#121212';
            ctx.lineWidth = 2.5;
            ctx.beginPath();
            ctx.moveTo(p.x - eyeOffset - 4, eyeY - 6);
            ctx.lineTo(p.x - eyeOffset + 3, eyeY - 6);
            ctx.moveTo(p.x + eyeOffset - 3, eyeY - 6);
            ctx.lineTo(p.x + eyeOffset + 4, eyeY - 6);
            ctx.stroke();
        }

        // 8. Nameplate & Active Indicator
        ctx.fillStyle = '#ffffff';
        ctx.font = '900 12px Outfit, sans-serif';
        ctx.textAlign = 'center';
        ctx.shadowColor = '#000000';
        ctx.shadowBlur = 5;
        ctx.fillText(`${p.name.toUpperCase()} #${p.number}`, p.x, p.y + 44);

        if (hasBall) {
            ctx.fillStyle = '#ffc800';
            ctx.font = '900 11px Outfit, sans-serif';
            ctx.fillText('⭐ ACTIVE ⭐', p.x, p.y - headR - 14);
        }
        ctx.shadowBlur = 0;
    }

    drawDefender(def) {
        const ctx = this.ctx;
        const headR = 24;

        // 1. Defender Danger Tackle Zone Circle
        ctx.fillStyle = 'rgba(255, 59, 92, 0.16)';
        ctx.beginPath();
        ctx.arc(def.x, def.y, headR * 2.8, 0, Math.PI * 2);
        ctx.fill();

        // 2. Drop Shadow
        ctx.fillStyle = 'rgba(0, 0, 0, 0.45)';
        ctx.beginPath();
        ctx.ellipse(def.x, def.y + 32, 22, 9, 0, 0, Math.PI * 2);
        ctx.fill();

        // 3. AC Milan Red & Black Stripe Jersey Body
        const bodyY = def.y + 14;
        ctx.fillStyle = '#990000';
        ctx.beginPath();
        ctx.roundRect(def.x - 12, bodyY, 24, 16, 4);
        ctx.fill();

        ctx.fillStyle = '#1a1a1a';
        ctx.fillRect(def.x - 8, bodyY, 4, 16);
        ctx.fillRect(def.x + 4, bodyY, 4, 16);

        // Shorts & Boots
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(def.x - 10, bodyY + 16, 20, 6);
        ctx.fillStyle = def.skinColor || '#d9a77c';
        ctx.fillRect(def.x - 8, bodyY + 22, 5, 8);
        ctx.fillRect(def.x + 3, bodyY + 22, 5, 8);
        ctx.fillStyle = '#ff3b5c';
        ctx.fillRect(def.x - 9, bodyY + 28, 7, 3);
        ctx.fillRect(def.x + 2, bodyY + 28, 7, 3);

        // Captain Armband
        ctx.fillStyle = '#ffea00';
        ctx.fillRect(def.x - 12, bodyY + 3, 5, 8);
        ctx.fillStyle = '#000000';
        ctx.font = 'bold 7px Inter, sans-serif';
        ctx.fillText('C', def.x - 10, bodyY + 9);

        // 4. Maldini Ears
        ctx.fillStyle = def.skinColor || '#d9a77c';
        ctx.strokeStyle = 'rgba(0, 0, 0, 0.3)';
        ctx.lineWidth = 1.5;

        ctx.beginPath();
        ctx.ellipse(def.x - headR - 2, def.y - 2, 6, 9, -0.2, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();

        ctx.beginPath();
        ctx.ellipse(def.x + headR + 2, def.y - 2, 6, 9, 0.2, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();

        // 5. Maldini Big Head & Long Wavy Hair
        ctx.fillStyle = def.hairColor || '#362215';
        ctx.beginPath();
        ctx.arc(def.x, def.y - 6, headR * 1.12, Math.PI * 0.7, Math.PI * 2.3);
        ctx.fill();

        ctx.fillStyle = def.skinColor || '#d9a77c';
        ctx.beginPath();
        ctx.arc(def.x, def.y - 6, headR, 0, Math.PI * 2);
        ctx.fill();

        ctx.strokeStyle = '#121212';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.arc(def.x, def.y - 6, headR, 0, Math.PI * 2);
        ctx.stroke();

        // Wavy Hair Locks overlay
        ctx.fillStyle = def.hairColor || '#362215';
        ctx.beginPath();
        ctx.arc(def.x, def.y - 12, headR * 0.9, Math.PI * 0.8, Math.PI * 2.2);
        ctx.fill();

        // Intimidating Defender Eyes
        const eyeOffset = 6;
        const eyeY = def.y - 6;
        const eyeDirX = Math.cos(def.facingAngle) * 2.5;
        const eyeDirY = Math.sin(def.facingAngle) * 2.5;

        ctx.fillStyle = '#ffffff';
        ctx.beginPath();
        ctx.arc(def.x - eyeOffset, eyeY, 4.5, 0, Math.PI * 2);
        ctx.arc(def.x + eyeOffset, eyeY, 4.5, 0, Math.PI * 2);
        ctx.fill();

        ctx.fillStyle = '#ff0000';
        ctx.beginPath();
        ctx.arc(def.x - eyeOffset + eyeDirX, eyeY + eyeDirY, 2.2, 0, Math.PI * 2);
        ctx.arc(def.x + eyeOffset + eyeDirX, eyeY + eyeDirY, 2.2, 0, Math.PI * 2);
        ctx.fill();

        // Defender Brow
        ctx.strokeStyle = '#362215';
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.moveTo(def.x - eyeOffset - 4, eyeY - 5);
        ctx.lineTo(def.x - eyeOffset + 3, eyeY - 3);
        ctx.moveTo(def.x + eyeOffset - 3, eyeY - 3);
        ctx.lineTo(def.x + eyeOffset + 4, eyeY - 5);
        ctx.stroke();

        // 6. Maldini Nameplate
        ctx.fillStyle = '#ff3b5c';
        ctx.font = '900 13px Outfit, sans-serif';
        ctx.textAlign = 'center';
        ctx.shadowColor = '#000000';
        ctx.shadowBlur = 5;
        ctx.fillText('MALDINI #3', def.x, def.y + 44);
        ctx.shadowBlur = 0;
    }

    drawBall(ball, comboMultiplier = 1) {
        const ctx = this.ctx;

        // 1. Draw Ball Ground Shadow (Offset increases with ball.z height)
        const shadowScale = Math.max(0.4, 1 - ball.z * 0.02);
        const shadowOffset = 4 + ball.z * 0.8;
        ctx.fillStyle = `rgba(0, 0, 0, ${0.45 * shadowScale})`;
        ctx.beginPath();
        ctx.ellipse(ball.x, ball.y + shadowOffset, ball.radius * shadowScale, (ball.radius * 0.5) * shadowScale, 0, 0, Math.PI * 2);
        ctx.fill();

        // 2. Draw Ball Trail (Combo fire effect)
        ball.trail.forEach(t => {
            ctx.fillStyle = comboMultiplier > 1 
                ? `rgba(255, 200, 0, ${t.alpha * 0.6})` 
                : `rgba(0, 255, 135, ${t.alpha * 0.4})`;
            ctx.beginPath();
            ctx.arc(t.x, t.y - t.z, ball.radius * t.alpha, 0, Math.PI * 2);
            ctx.fill();
        });

        // 3. Draw Actual Ball (Offset up by ball.z height)
        const renderY = ball.y - ball.z;

        // Ball Glow
        if (comboMultiplier > 1) {
            ctx.shadowColor = '#ffc800';
            ctx.shadowBlur = 15;
        } else {
            ctx.shadowColor = '#00ff87';
            ctx.shadowBlur = 8;
        }

        ctx.fillStyle = '#ffffff';
        ctx.beginPath();
        ctx.arc(ball.x, renderY, ball.radius, 0, Math.PI * 2);
        ctx.fill();

        // Football Pattern Lines
        ctx.shadowBlur = 0;
        ctx.strokeStyle = '#000000';
        ctx.lineWidth = 1.5;
        ctx.beginPath();
        ctx.arc(ball.x, renderY, ball.radius * 0.5, 0, Math.PI * 2);
        ctx.stroke();
    }

    addFloatingText(text, x, y, color = '#00ff87') {
        this.floatingTexts.push({ text, x, y, color, opacity: 1.0, scale: 1.2 });
    }

    addImpactParticles(x, y, count = 8, color = '#00ff87') {
        for (let i = 0; i < count; i++) {
            const angle = Math.random() * Math.PI * 2;
            const speed = 1 + Math.random() * 4;
            this.particles.push({
                x, y,
                vx: Math.cos(angle) * speed,
                vy: Math.sin(angle) * speed,
                life: 1.0,
                color
            });
        }
    }

    drawParticles() {
        const ctx = this.ctx;
        for (let i = this.particles.length - 1; i >= 0; i--) {
            const p = this.particles[i];
            p.x += p.vx;
            p.y += p.vy;
            p.life -= 0.04;

            if (p.life <= 0) {
                this.particles.splice(i, 1);
                continue;
            }

            ctx.fillStyle = p.color;
            ctx.globalAlpha = p.life;
            ctx.beginPath();
            ctx.arc(p.x, p.y, 3 * p.life, 0, Math.PI * 2);
            ctx.fill();
            ctx.globalAlpha = 1.0;
        }
    }

    drawFloatingTexts() {
        const ctx = this.ctx;
        for (let i = this.floatingTexts.length - 1; i >= 0; i--) {
            const ft = this.floatingTexts[i];
            ft.y -= 1.2;
            ft.opacity -= 0.025;
            ft.scale = Math.max(1.0, ft.scale - 0.01);

            if (ft.opacity <= 0) {
                this.floatingTexts.splice(i, 1);
                continue;
            }

            ctx.save();
            ctx.globalAlpha = ft.opacity;
            ctx.fillStyle = ft.color;
            ctx.font = `bold ${Math.round(20 * ft.scale)}px Outfit, sans-serif`;
            ctx.textAlign = 'center';
            ctx.fillText(ft.text, ft.x, ft.y);
            ctx.restore();
        }
    }
}
