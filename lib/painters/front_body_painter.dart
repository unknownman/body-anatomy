import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/body_metrics.dart';
import '../utils/body_calculator.dart';

class FrontBodyPainter extends CustomPainter {
  final BodyMetrics metrics;
  final Map<String, Color> highlightedMuscles;

  FrontBodyPainter({
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

  // ── Computed dimensions ──
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
  static const double yNeckT = 46;
  static const double yNeckB = 62;
  static const double yShoul = 66;
  static const double yArmpit = 84;
  static const double yChest = 94;
  static const double yWaist = 124;
  static const double yHip = 152;
  static const double yCrotch = 170;
  static const double yKnee = 258;
  static const double yAnkle = 355;
  static const double yFoot = 375;
  static const double yHand = 172;

  // ── X-widths (right half) ──
  double get _headR => 18.0;
  double get _neckW => 12.0;
  double get _shoulW => 34.0 * _sf * (_isFemale ? 0.92 : 1.0);
  double get _armW => 8.0 * _af;
  double get _chestW => 25.0 * _cf * (_isFemale ? 0.95 : 1.0);
  double get _waistW => _isFemale ? 14.0 * _wf : 18.0 * _wf;
  double get _hipW => _isFemale ? 22.0 * _hf : 18.0 * _hf;
  double get _thighW => 15.0 * _af;
  double get _calfW => 11.0 * _af;

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

    // ══ RIGHT HALF (top → bottom) ══
    double hR = _headR, nW = _neckW, sW = _shoulW, aW = _armW;
    double cW = _chestW, wW = _waistW, hW = _hipW;
    double tW = _thighW, cW2 = _calfW;

    // Head
    p.moveTo(0, yHeadT);
    p.quadraticBezierTo(hR * 0.8, yHeadT, hR, yHeadC - 6);
    p.quadraticBezierTo(hR + 2, yHeadC + 2, hR * 0.7, yHeadB);

    // Neck
    p.cubicTo(nW * 0.5, yHeadB + 2, nW, yNeckB - 4, nW, yNeckB);

    // Shoulder
    p.cubicTo(nW + 6, yNeckB + 2, sW, yShoul - 2, sW, yShoul + 4);

    // Arm outer
    double aOut = sW + aW;
    p.cubicTo(sW + 2, yShoul + 10, aOut, yShoul + 24, aOut, yHand - 20);
    p.cubicTo(aOut + 1, yHand - 8, aOut - 1, yHand - 2, aOut - 2, yHand);

    // Hand bottom
    p.lineTo(sW + 2, yHand);

    // Arm inner
    p.cubicTo(sW + 2, yHand - 2, sW, yHand - 10, sW + 1, yHand - 22);
    p.cubicTo(sW + 2, yArmpit + 10, sW + 3, yArmpit + 4, sW + 2, yArmpit + 6);

    // Torso side (armpit → chest → waist → hip → crotch)
    p.cubicTo(cW + 2, yArmpit + 12, cW + 4, yChest - 2, cW + 2, yChest + 4);
    p.cubicTo(cW, yWaist - 12, wW + 2, yWaist - 4, wW, yWaist + 2);
    p.cubicTo(wW - 1, yWaist + 8, hW + 1, yHip - 4, hW + 2, yHip + 2);
    p.cubicTo(hW + 1, yHip + 8, hW * 0.4, yCrotch - 2, 0, yCrotch);

    // Right leg inner (down)
    p.cubicTo(tW * 0.35, yCrotch + 8, tW * 0.5, yKnee - 24, tW * 0.5, yKnee - 4);
    p.cubicTo(tW * 0.4, yKnee + 4, cW2 * 0.3, yAnkle - 10, cW2 * 0.3, yAnkle);
    p.cubicTo(cW2 * 0.3, yAnkle + 4, cW2 * 0.2, yFoot - 4, cW2 * 0.2, yFoot);

    // Right foot bottom
    double fOut = tW * 0.85;
    p.lineTo(fOut + 2, yFoot);

    // Right leg outer (up)
    p.cubicTo(fOut + 3, yFoot - 4, fOut + 2, yAnkle + 4, fOut, yAnkle);
    p.cubicTo(fOut - 1, yKnee + 4, fOut + 1, yKnee - 8, fOut, yKnee - 4);
    p.cubicTo(fOut - 1, yHip + 12, hW + 1, yHip + 4, hW + 1, yHip + 2);

    // ══ LEFT HALF (bottom → top, mirrored) ══
    double m = -1.0;

    // Left outer leg (up from foot to hip)
    p.cubicTo(hW * m + 1, yHip + 4, fOut * m, yHip + 12, fOut * m, yKnee - 4);
    p.cubicTo(fOut * m + 1, yKnee - 8, fOut * m - 1, yKnee + 4, fOut * m, yAnkle);
    p.cubicTo(fOut * m + 2, yAnkle + 4, fOut * m + 3, yFoot - 4, fOut * m + 2, yFoot);

    // Left foot bottom
    p.lineTo(cW2 * 0.2 * m, yFoot);

    // Left leg inner (up to crotch)
    p.cubicTo(cW2 * 0.2 * m, yFoot - 4, cW2 * 0.3 * m, yAnkle + 4, cW2 * 0.3 * m, yAnkle);
    p.cubicTo(cW2 * 0.3 * m, yAnkle - 10, tW * 0.4 * m, yKnee + 4, tW * 0.5 * m, yKnee - 4);
    p.cubicTo(tW * 0.5 * m, yKnee - 24, tW * 0.35 * m, yCrotch + 8, 0, yCrotch);

    // Left torso (up from crotch)
    p.cubicTo(hW * 0.4 * m, yCrotch - 2, hW * m + 1, yHip + 8, hW * m + 2, yHip + 2);
    p.cubicTo(hW * m + 1, yHip - 4, wW * m - 1, yWaist + 8, wW * m, yWaist + 2);
    p.cubicTo(wW * m + 2, yWaist - 4, cW * m, yWaist - 12, cW * m + 2, yChest + 4);
    p.cubicTo(cW * m + 4, yChest - 2, cW * m + 2, yArmpit + 12, sW * m + 2, yArmpit + 6);

    // Left arm inner (up)
    p.cubicTo(sW * m + 3, yArmpit + 4, sW * m + 2, yArmpit + 10, sW * m + 1, yHand - 22);
    p.cubicTo(sW * m, yHand - 10, sW * m + 2, yHand - 2, sW * m + 2, yHand);

    // Left hand bottom
    p.lineTo((sW + 2) * m, yHand);

    // Left arm outer (up)
    p.cubicTo((sW + 2) * m, yHand - 2, aOut * m + 1, yHand - 8, aOut * m, yHand - 20);
    p.cubicTo(aOut * m, yShoul + 24, sW * m + 2, yShoul + 10, sW * m, yShoul + 4);

    // Left shoulder & neck
    p.cubicTo(sW * m, yShoul - 2, nW * m + 6, yNeckB + 2, nW * m, yNeckB);
    p.cubicTo(nW * m, yNeckB - 4, nW * 0.5 * m, yHeadB + 2, 0, yHeadB);

    // Left head
    p.quadraticBezierTo(hR * 0.7 * m, yHeadB, hR * m + 2, yHeadC + 2);
    p.quadraticBezierTo(hR * m, yHeadC - 6, hR * 0.8 * m, yHeadT);
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
    _drawMuscle(canvas, 'pectoral_left', _buildPectoral(-1));
    _drawMuscle(canvas, 'pectoral_right', _buildPectoral(1));
    _drawMuscle(canvas, 'abdominals', _buildAbdominals());
    _drawMuscle(canvas, 'obliques', _buildObliques());
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

  // ── Muscle builders ──

  Path _buildDeltoid(int side) {
    double s = side.toDouble();
    double sW = _shoulW, aW = _armW, cW = _chestW;
    final p = Path();
    p.moveTo(sW * s, yShoul + 2);
    p.quadraticBezierTo((sW + aW + 2) * s, yShoul + 16, (sW + aW - 1) * s, yShoul + 40);
    p.quadraticBezierTo((sW + 2) * s, yArmpit - 4, cW * 0.6 * s, yArmpit + 2);
    p.quadraticBezierTo(cW * 0.3 * s, yShoul + 10, sW * s, yShoul + 2);
    p.close();
    return p;
  }

  Path _buildPectoral(int side) {
    double s = side.toDouble();
    double cW = _chestW;
    final p = Path();
    p.moveTo(2, yChest - 8);
    p.quadraticBezierTo(cW * 0.7 * s, yChest - 14, cW * s, yChest - 2);
    p.quadraticBezierTo(cW * s * 0.9, yChest + 8, cW * 0.5 * s, yChest + 14);
    p.quadraticBezierTo(cW * 0.2 * s, yChest + 16, 2, yChest + 10);
    p.close();
    return p;
  }

  Path _buildAbdominals() {
    double wW = _waistW;
    final p = Path();
    p.moveTo(0, yChest + 14);
    p.quadraticBezierTo(wW * 0.5, yChest + 18, wW * 0.5, yWaist - 4);
    p.quadraticBezierTo(wW * 0.4, yWaist + 2, 0, yWaist);
    p.quadraticBezierTo(wW * -0.4, yWaist + 2, wW * -0.5, yWaist - 4);
    p.quadraticBezierTo(wW * -0.5, yChest + 18, 0, yChest + 14);
    p.close();
    return p;
  }

  Path _buildObliques() {
    double wW = _waistW, cW = _chestW;

    // Build right side, then reflect
    final p = Path();
    p.moveTo(wW * 0.5, yWaist - 4);
    p.quadraticBezierTo(wW * 0.7, yChest + 12, cW * 0.6, yChest + 14);
    p.quadraticBezierTo(cW * 0.8, yChest + 18, cW * 0.75, yChest + 10);
    p.quadraticBezierTo(cW * 0.7, yHip - 8, wW * 0.6, yWaist + 2);
    p.close();

    final pMirror = Path();
    final mat = Float64List.fromList([
      -1, 0, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1,
    ]);
    pMirror.addPath(p, Offset.zero, matrix4: mat);
    p.addPath(pMirror, Offset.zero);
    return p;
  }

  Path _buildQuadriceps(int side) {
    double s = side.toDouble();
    double tW = _thighW;
    final p = Path();
    p.moveTo(4, yCrotch + 4);
    p.quadraticBezierTo(tW * 0.7 * s, yCrotch + 18, tW * 0.7 * s, yKnee - 18);
    p.quadraticBezierTo(tW * 0.5 * s, yKnee - 2, tW * 0.3 * s, yKnee);
    p.quadraticBezierTo(2, yKnee - 2, 2, yCrotch + 6);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant FrontBodyPainter old) {
    return old.metrics != metrics || old.highlightedMuscles != highlightedMuscles;
  }
}
