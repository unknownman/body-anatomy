import 'dart:math';
import 'package:flutter/material.dart';
import '../models/body_metrics.dart';
import '../utils/body_calculator.dart';

class BackBodyPainter extends CustomPainter {
  final BodyMetrics metrics;
  final Map<String, Color> highlightedMuscles;

  BackBodyPainter({
    required this.metrics,
    this.highlightedMuscles = const {},
  });

  static const double _vw = 240;
  static const double _vh = 440;

  @override
  void paint(Canvas canvas, Size size) {
    final sc = min(size.width / _vw, size.height / _vh);
    canvas.save();
    canvas.translate(
      (size.width - _vw * sc) / 2 + _vw / 2 * sc,
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
  static const double yHeadC = 30;
  static const double yHeadB = 50;
  static const double yNeckT = 44;
  static const double yNeckB = 62;
  static const double yShoul = 66;
  static const double yArmpit = 84;
  static const double yLat = 94;
  static const double yWaist = 124;
  static const double yGlute = 152;
  static const double yCrotch = 170;
  static const double yKnee = 258;
  static const double yAnkle = 355;
  static const double yFoot = 375;
  static const double yHand = 172;

  // ── X-widths (right half) ──
  double get _headR => 19.0;
  double get _neckW => 14.0;
  double get _shoulW => 36.0 * _sf * (_isFemale ? 0.92 : 1.0);
  double get _armW => 8.0 * _af;
  double get _latW => 27.0 * _cf * 0.95;
  double get _waistW => _isFemale ? 15.0 * _wf : 19.0 * _wf;
  double get _gluteW => _isFemale ? 23.0 * _hf : 19.0 * _hf;
  double get _thighW => 15.0 * _af;
  double get _calfW => 12.0 * _af;

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

    double hR = _headR, nW = _neckW, sW = _shoulW, aW = _armW;
    double lW = _latW, wW = _waistW, gW = _gluteW;
    double tW = _thighW, cW = _calfW;

    // ══ RIGHT HALF (top → bottom) ══
    p.moveTo(0, yHeadT);

    // Back of head
    p.quadraticBezierTo(hR * 0.7, yHeadT, hR - 2, yHeadC - 4);
    p.quadraticBezierTo(hR, yHeadC + 4, hR * 0.6, yHeadB);

    // Back neck (wider trapezius)
    p.cubicTo(nW * 0.4, yHeadB + 2, nW, yNeckB - 4, nW, yNeckB);

    // Shoulder (trapezius ridge)
    p.cubicTo(nW + 4, yNeckB + 2, sW, yShoul - 2, sW, yShoul + 4);

    // Arm outer
    double aOut = sW + aW;
    p.cubicTo(sW + 2, yShoul + 10, aOut, yShoul + 24, aOut, yHand - 20);
    p.cubicTo(aOut + 1, yHand - 8, aOut - 1, yHand - 2, aOut - 2, yHand);

    // Hand bottom
    p.lineTo(sW + 2, yHand);

    // Arm inner
    p.cubicTo(sW + 2, yHand - 2, sW, yHand - 10, sW + 1, yHand - 22);
    p.cubicTo(sW + 2, yArmpit + 10, sW + 3, yArmpit + 4, sW + 2, yArmpit + 6);

    // Back torso side (latissimus → waist → glute → crotch)
    p.cubicTo(lW + 2, yArmpit + 12, lW + 4, yLat - 2, lW + 2, yLat + 4);
    p.cubicTo(lW, yWaist - 12, wW + 2, yWaist - 4, wW, yWaist + 2);
    p.cubicTo(wW - 1, yWaist + 8, gW + 1, yGlute - 4, gW + 2, yGlute + 2);
    p.cubicTo(gW + 1, yGlute + 8, gW * 0.4, yCrotch - 2, 0, yCrotch);

    // Right leg inner (down)
    p.cubicTo(tW * 0.35, yCrotch + 8, tW * 0.5, yKnee - 24, tW * 0.5, yKnee - 4);
    p.cubicTo(tW * 0.4, yKnee + 4, cW * 0.3, yAnkle - 10, cW * 0.3, yAnkle);
    p.cubicTo(cW * 0.3, yAnkle + 4, cW * 0.2, yFoot - 4, cW * 0.2, yFoot);

    // Right foot bottom
    double fOut = tW * 0.85;
    p.lineTo(fOut + 2, yFoot);

    // Right leg outer (up)
    p.cubicTo(fOut + 3, yFoot - 4, fOut + 2, yAnkle + 4, fOut, yAnkle);
    p.cubicTo(fOut - 1, yKnee + 4, fOut + 1, yKnee - 8, fOut, yKnee - 4);
    p.cubicTo(fOut - 1, yGlute + 12, gW + 1, yGlute + 4, gW + 1, yGlute + 2);

    // ══ LEFT HALF (bottom → top, mirrored) ══
    double m = -1.0;

    p.cubicTo(gW * m + 1, yGlute + 4, fOut * m, yGlute + 12, fOut * m, yKnee - 4);
    p.cubicTo(fOut * m + 1, yKnee - 8, fOut * m - 1, yKnee + 4, fOut * m, yAnkle);
    p.cubicTo(fOut * m + 2, yAnkle + 4, fOut * m + 3, yFoot - 4, fOut * m + 2, yFoot);

    p.lineTo(cW * 0.2 * m, yFoot);

    p.cubicTo(cW * 0.2 * m, yFoot - 4, cW * 0.3 * m, yAnkle + 4, cW * 0.3 * m, yAnkle);
    p.cubicTo(cW * 0.3 * m, yAnkle - 10, tW * 0.4 * m, yKnee + 4, tW * 0.5 * m, yKnee - 4);
    p.cubicTo(tW * 0.5 * m, yKnee - 24, tW * 0.35 * m, yCrotch + 8, 0, yCrotch);

    p.cubicTo(gW * 0.4 * m, yCrotch - 2, gW * m + 1, yGlute + 8, gW * m + 2, yGlute + 2);
    p.cubicTo(gW * m + 1, yGlute - 4, wW * m - 1, yWaist + 8, wW * m, yWaist + 2);
    p.cubicTo(wW * m + 2, yWaist - 4, lW * m, yWaist - 12, lW * m + 2, yLat + 4);
    p.cubicTo(lW * m + 4, yLat - 2, lW * m + 2, yArmpit + 12, sW * m + 2, yArmpit + 6);

    p.cubicTo(sW * m + 3, yArmpit + 4, sW * m + 2, yArmpit + 10, sW * m + 1, yHand - 22);
    p.cubicTo(sW * m, yHand - 10, sW * m + 2, yHand - 2, sW * m + 2, yHand);

    p.lineTo((sW + 2) * m, yHand);

    p.cubicTo((sW + 2) * m, yHand - 2, aOut * m + 1, yHand - 8, aOut * m, yHand - 20);
    p.cubicTo(aOut * m, yShoul + 24, sW * m + 2, yShoul + 10, sW * m, yShoul + 4);

    p.cubicTo(sW * m, yShoul - 2, nW * m + 4, yNeckB + 2, nW * m, yNeckB);
    p.cubicTo(nW * m, yNeckB - 4, nW * 0.4 * m, yHeadB + 2, 0, yHeadB);
    p.quadraticBezierTo(hR * 0.6 * m, yHeadB, hR * m, yHeadC + 4);
    p.quadraticBezierTo(hR * m - 2, yHeadC - 4, hR * 0.7 * m, yHeadT);
    p.lineTo(0, yHeadT);

    p.close();
    canvas.drawPath(p, paint);
  }

  // ─────────────────────────────────────────
  //  LAYER 2: Muscle Groups
  // ─────────────────────────────────────────
  void _drawMuscles(Canvas canvas) {
    _drawMuscle(canvas, 'deltoid_left', _buildDeltoid(-1));
    _drawMuscle(canvas, 'deltoid_right', _buildDeltoid(1));
    _drawMuscle(canvas, 'latissimus_dorsi_left', _buildLatissimus(-1));
    _drawMuscle(canvas, 'latissimus_dorsi_right', _buildLatissimus(1));
    _drawMuscle(canvas, 'glute_left', _buildGlute(-1));
    _drawMuscle(canvas, 'glute_right', _buildGlute(1));
    _drawMuscle(canvas, 'quadriceps_left', _buildQuadriceps(-1));
    _drawMuscle(canvas, 'quadriceps_right', _buildQuadriceps(1));
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

  Path _buildDeltoid(int side) {
    double s = side.toDouble();
    double sW = _shoulW, aW = _armW;
    final p = Path();
    p.moveTo(sW * s, yShoul + 2);
    p.quadraticBezierTo((sW + aW + 2) * s, yShoul + 16, (sW + aW - 1) * s, yShoul + 40);
    p.quadraticBezierTo((sW + 2) * s, yArmpit - 4, sW * 0.5 * s, yArmpit + 2);
    p.quadraticBezierTo(sW * 0.3 * s, yShoul + 10, sW * s, yShoul + 2);
    p.close();
    return p;
  }

  Path _buildLatissimus(int side) {
    double s = side.toDouble();
    double lW = _latW, wW = _waistW;
    final p = Path();
    p.moveTo(lW * 0.3 * s, yLat - 6);
    p.quadraticBezierTo(lW * s, yLat - 8, lW * s - 1, yLat + 4);
    p.quadraticBezierTo(lW * s - 2, yWaist - 8, wW * s - 1, yWaist);
    p.quadraticBezierTo(wW * s - 3, yWaist - 6, lW * 0.3 * s, yLat + 4);
    p.close();
    return p;
  }

  Path _buildGlute(int side) {
    double s = side.toDouble();
    double gW = _gluteW;
    final p = Path();
    p.moveTo(4, yGlute + 4);
    p.quadraticBezierTo(gW * 0.7 * s, yGlute - 2, gW * s, yGlute + 2);
    p.quadraticBezierTo(gW * s - 1, yGlute + 10, gW * 0.5 * s, yGlute + 12);
    p.quadraticBezierTo(gW * 0.2 * s, yGlute + 10, 2, yGlute + 6);
    p.close();
    return p;
  }

  Path _buildQuadriceps(int side) {
    double s = side.toDouble();
    double tW = _thighW;
    final p = Path();
    p.moveTo(4, yCrotch + 6);
    p.quadraticBezierTo(tW * 0.7 * s, yCrotch + 20, tW * 0.7 * s, yKnee - 18);
    p.quadraticBezierTo(tW * 0.5 * s, yKnee - 2, tW * 0.3 * s, yKnee);
    p.quadraticBezierTo(2, yKnee - 2, 2, yCrotch + 8);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant BackBodyPainter old) {
    return old.metrics != metrics || old.highlightedMuscles != highlightedMuscles;
  }
}
