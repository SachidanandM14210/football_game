// Physics Engine & Math Utilities

export class Physics {
    static distance(p1, p2) {
        const dx = p2.x - p1.x;
        const dy = p2.y - p1.y;
        return Math.sqrt(dx * dx + dy * dy);
    }

    static distanceSq(p1, p2) {
        const dx = p2.x - p1.x;
        const dy = p2.y - p1.y;
        return dx * dx + dy * dy;
    }

    static angleBetween(p1, p2) {
        return Math.atan2(p2.y - p1.y, p2.x - p1.x);
    }

    static normalize(v) {
        const mag = Math.sqrt(v.x * v.x + v.y * v.y);
        if (mag === 0) return { x: 0, y: 0 };
        return { x: v.x / mag, y: v.y / mag };
    }

    // Distance from point P to line segment VW
    static distanceToSegment(p, v, w) {
        const l2 = Physics.distanceSq(v, w);
        if (l2 === 0) return Physics.distance(p, v);
        
        let t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;
        t = Math.max(0, Math.min(1, t));
        
        const projection = {
            x: v.x + t * (w.x - v.x),
            y: v.y + t * (w.y - v.y)
        };
        
        return Physics.distance(p, projection);
    }

    // Closest point on line segment VW to point P
    static closestPointOnSegment(p, v, w) {
        const l2 = Physics.distanceSq(v, w);
        if (l2 === 0) return { x: v.x, y: v.y };
        
        let t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;
        t = Math.max(0, Math.min(1, t));
        
        return {
            x: v.x + t * (w.x - v.x),
            y: v.y + t * (w.y - v.y)
        };
    }

    // Check if defender can intercept a pass travelling from startP to targetP
    static canInterceptPass(startP, targetP, defenderP, defenderSpeed, ballSpeed, radius = 24) {
        const segDist = Physics.distanceToSegment(defenderP, startP, targetP);
        if (segDist > radius + defenderSpeed * 15) return false;

        const closest = Physics.closestPointOnSegment(defenderP, startP, targetP);
        const ballTravelDist = Physics.distance(startP, closest);
        const ballTime = ballTravelDist / Math.max(ballSpeed, 0.1);

        const defenderTravelDist = Physics.distance(defenderP, closest);
        const defenderTime = defenderTravelDist / Math.max(defenderSpeed, 0.1);

        // Defender can reach interception point before or at same time as ball arrives
        return defenderTime <= ballTime + 0.15;
    }

    // Clamp value between min and max
    static clamp(val, min, max) {
        return Math.max(min, Math.min(max, val));
    }

    // Linear interpolation
    static lerp(start, end, amt) {
        return (1 - amt) * start + amt * end;
    }
}
