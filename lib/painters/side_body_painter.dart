import 'dart:math';
import 'package:flutter/material.dart';
import '../models/body_metrics.dart';
import '../utils/body_calculator.dart';

class SideBodyPainter extends CustomPainter {
  final BodyMetrics metrics;
  final Map<String, Color> highlightedMuscles;

  SideBodyPainter({
    required this.metrics,
    this.highlightedMuscles = const {},
  });

  static const double _vw = 200;
  static const double _vh = 440;

  @override
  void paint(Canvas canvas, Size size) {
    final sc = min(size.width / _vw, size.height / _vh);
    canvas.save();
    canvas.translate(
      (size.width - _vw * sc) / 2,
      (size.height - _vh * sc) / 2,
    );
    canvas.scale(sc, sc);

    _drawOutline(canvas);
    _drawMuscles(canvas);

    canvas.restore();
  }

  double get _cf => BodyCalculator.chestFactor(metrics);
  double get _wf => BodyCalculator.waistFactor(metrics);
  double get _hf => BodyCalculator.hipFactor(metrics);
  double get _sf => BodyCalculator.shoulderFactor(metrics);
  double get _af => BodyCalculator.armFactor(metrics);
  bool get _isFemale => metrics.gender == Gender.female;

  // ── Y-coordinates ──
  static const double yHeadT = 8;
  static const double yHeadC = 28;
  static const double yHeadB = 48;
  static const double yNeckB = 62;
  static const double yShoul = 66;
  static const double yBust = 86;
  static const double yUnder = 96;
  static const double yWaist = 124;
  static const double yHip = 152;
  static const double yCrotch = 170;
  static const double yKnee = 258;
  static const double yAnkle = 355;
  static const double yFoot = 375;
  static const double yToe = 372;

  double get _shoulW => 30.0 * _sf;
  double get _armW => 7.0 * _af;

  // ─────────────────────────────────────────
  //  LAYER 1: Outline
  // ─────────────────────────────────────────
  void _drawOutline(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final p = Path();

    // ══ FRONT CONTOUR (top → bottom) ══
    p.moveTo(0, yHeadT);

    // Forehead & nose
    p.quadraticBezierTo(16, yHeadT + 4, 22, 18);
    p.quadraticBezierTo(26, 22, 26, 28);
    p.quadraticBezierTo(32, 30, 34, 32); // nose tip

    // Lips & chin
    p.quadraticBezierTo(28, 34, 30, 38); // to upper lip
    p.quadraticBezierTo(28, 40, 30, 42); // lower lip
    p.quadraticBezierTo(28, 44, 26, 48); // chin

    // Throat & neck
    p.quadraticBezierTo(22, 52, 20, 58);
    p.lineTo(20, yNeckB);

    // Chest / bust (gender-aware)
    if (_isFemale) {
      double bustP = 34 + _cf * 3;
      p.cubicTo(22, yShoul + 6, bustP, yBust - 8, bustP, yBust);
      p.quadraticBezierTo(bustP - 2, yBust + 6, 28 - _cf, yUnder);
    } else {
      double chestP = 28 + _cf * 2;
      p.cubicTo(22, yShoul + 4, chestP, yBust - 4, chestP - 2, yBust + 2);
      p.quadraticBezierTo(chestP - 4, yUnder - 4, 24, yUnder);
    }

    // Abdomen
    double bellyP = 22 + _wf * 4;
    p.cubicTo(24, yUnder + 8, bellyP, yWaist - 6, bellyP - 2, yWaist + 4);

    // Pelvis
    double pelvisP = 22 + _hf * 3;
    p.cubicTo(bellyP - 4, yWaist + 12, pelvisP, yHip - 4, pelvisP - 2, yHip + 4);

    // Crotch
    p.cubicTo(pelvisP - 4, yHip + 12, 12, yCrotch - 2, 8, yCrotch);

    // Front thigh
    p.cubicTo(12, yCrotch + 6, 18, yCrotch + 30, 18, yKnee - 30);
    p.quadraticBezierTo(18, yKnee - 6, 16, yKnee);

    // Shin
    p.cubicTo(16, yKnee + 8, 14, yCrotch + 150, 12, yAnkle - 10);
    p.quadraticBezierTo(12, yAnkle + 2, 10, yAnkle);

    // Foot top
    p.cubicTo(10, yAnkle + 4, 22, yToe - 6, 26, yToe);

    // Foot tip
    p.quadraticBezierTo(28, yFoot - 2, 24, yFoot + 2);

    // ══ BOTTOM (foot) ══
    p.cubicTo(20, yFoot + 6, 4, yFoot + 6, -6, yFoot + 2);
    p.quadraticBezierTo(-10, yFoot, -8, yFoot - 2);

    // ══ BACK CONTOUR (bottom → top) ══
    // Heel & Achilles
    p.quadraticBezierTo(-6, yFoot - 6, -4, yAnkle + 2);

    // Calf
    double calfP = -4 - _af * 10;
    p.cubicTo(-4, yAnkle - 8, calfP, yCrotch + 130, calfP + 2, yKnee + 20);
    p.quadraticBezierTo(calfP + 4, yKnee - 4, -6, yKnee);

    // Back thigh
    p.cubicTo(-6, yKnee - 8, -12, yCrotch + 30, -12, yCrotch + 4);
    p.cubicTo(-12, yCrotch - 2, -10, yHip + 8, -10, yHip + 4);

    // Glutes (gender-aware)
    double gluteP = _isFemale ? -30 - _hf * 6 : -24 - _hf * 4;
    p.cubicTo(-10, yHip - 4, gluteP, yWaist + 24, gluteP + 2, yWaist + 6);
    p.quadraticBezierTo(gluteP + 4, yWaist - 2, -12, yWaist);

    // Lower back
    p.cubicTo(-12, yWaist - 8, -14, yUnder + 4, -14, yUnder);

    // Upper back (gender-aware: broader for males)
    double backP = _isFemale ? -16 : -18 - _sf * 2;
    p.cubicTo(-14, yUnder - 8, backP, yBust - 6, backP + 2, yShoul + 8);
    p.quadraticBezierTo(backP - 2, yNeckB + 2, -12, yNeckB);

    // Back of neck & head
    p.quadraticBezierTo(-10, yNeckB - 6, -14, yHeadC + 6);
    p.quadraticBezierTo(-16, yHeadC - 6, -10, yHeadT + 6);
    p.quadraticBezierTo(-4, yHeadT, 0, yHeadT);

    p.close();
    canvas.drawPath(p, paint);

    // Draw arm separately
    _drawArm(canvas);
  }

  void _drawArm(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    double sW = _shoulW, aW = _armW;
    double shX = sW * 0.55;
    double aEnd = yKnee - 50;

    final p = Path();
    p.moveTo(shX, yShoul + 2);

    // Outer arm down
    p.quadraticBezierTo(shX + aW, yShoul + 16, shX + aW, yWaist - 20);
    p.quadraticBezierTo(shX + aW - 1, yWaist + 10, shX - 2, aEnd);

    // Hand
    p.lineTo(shX - 6, aEnd);

    // Inner arm up
    p.quadraticBezierTo(shX - 2, yWaist + 4, shX - 1, yWaist - 20);
    p.quadraticBezierTo(shX - 1, yShoul + 14, shX - 2, yShoul + 2);

    p.close();
    canvas.drawPath(p, paint);
  }

  // ─────────────────────────────────────────
  //  LAYER 2: Muscle Groups
  // ─────────────────────────────────────────
  void _drawMuscles(Canvas canvas) {
    _drawMuscle(canvas, 'deltoid_right', _buildDeltoid());
    _drawMuscle(canvas, 'pectoral_right', _buildPectoral());
    _drawMuscle(canvas, 'abdominals', _buildAbdominals());
    _drawMuscle(canvas, 'glute_right', _buildGlute());
    _drawMuscle(canvas, 'quadriceps_right', _buildQuadriceps());
  }

  void _drawMuscle(Canvas canvas, String key, Path path) {
    final color = highlightedMuscles[key];
    if (color == null) {
      canvas.drawPath(path, Paint()
        ..color = Colors.grey.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill);
      return;
    }
    canvas.drawPath(path, Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);
  }

  Path _buildDeltoid() {
    double sW = _shoulW;
    double aW = _armW;
    final p = Path();
    p.moveTo(20, yShoul + 2);
    p.quadraticBezierTo(sW * 0.6 + aW, yShoul + 8, sW * 0.6 + aW - 2, yShoul + 36);
    p.quadraticBezierTo(sW * 0.5, yShoul + 42, 20, yShoul + 20);
    p.close();
    return p;
  }

  Path _buildPectoral() {
    double c = _cf;
    final p = Path();
    p.moveTo(18, yShoul + 10);
    p.quadraticBezierTo(30 + c * 2, yBust - 12, 32 + c * 2, yBust - 2);
    p.quadraticBezierTo(30 + c * 2, yBust + 6, 24, yUnder - 4);
    p.quadraticBezierTo(20, yUnder - 12, 18, yShoul + 20);
    p.close();
    return p;
  }

  Path _buildAbdominals() {
    double w = _wf;
    final p = Path();
    p.moveTo(18, yUnder + 6);
    p.quadraticBezierTo(24 + w * 2, yWaist - 8, 22 + w * 2, yWaist + 2);
    p.quadraticBezierTo(20 + w * 2, yWaist + 12, 14, yWaist + 4);
    p.quadraticBezierTo(16, yUnder + 10, 18, yUnder + 6);
    p.close();
    return p;
  }

  Path _buildGlute() {
    double h = _hf;
    bool f = _isFemale;
    final p = Path();
    double gX = f ? -28 - h * 6 : -22 - h * 4;
    p.moveTo(-10, yHip + 4);
    p.quadraticBezierTo(gX, yWaist + 20, gX + 2, yWaist + 6);
    p.quadraticBezierTo(gX + 4, yWaist - 2, -12, yWaist);
    p.quadraticBezierTo(-10, yWaist + 8, -10, yHip + 4);
    p.close();
    return p;
  }

  Path _buildQuadriceps() {
    final p = Path();
    p.moveTo(8, yCrotch + 4);
    p.quadraticBezierTo(16, yCrotch + 18, 17, yKnee - 30);
    p.quadraticBezierTo(16, yKnee - 4, 14, yKnee);
    p.quadraticBezierTo(10, yKnee - 4, 6, yCrotch + 8);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant SideBodyPainter old) {
    return old.metrics != metrics || old.highlightedMuscles != highlightedMuscles;
  }
}
