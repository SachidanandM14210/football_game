import 'dart:math';

class Physics {
  static double distance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return sqrt(dx * dx + dy * dy);
  }

  static double angleBetween(double x1, double y1, double x2, double y2) {
    return atan2(y2 - y1, x2 - x1);
  }

  static double lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }

  static Point<double> closestPointOnSegment(
    double px, double py,
    double ax, double ay,
    double bx, double by,
  ) {
    final abx = bx - ax;
    final aby = by - ay;
    final abLenSq = abx * abx + aby * aby;

    if (abLenSq == 0) return Point(ax, ay);

    final apx = px - ax;
    final apy = py - ay;
    final t = max(0.0, min(1.0, (apx * abx + apy * aby) / abLenSq));

    return Point(ax + abx * t, ay + aby * t);
  }

  static double distanceToSegment(
    double px, double py,
    double ax, double ay,
    double bx, double by,
  ) {
    final closest = closestPointOnSegment(px, py, ax, ay, bx, by);
    return distance(px, py, closest.x, closest.y);
  }
}
