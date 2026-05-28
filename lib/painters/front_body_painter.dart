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

  // ── Layout constants (virtual 240×440 space) ──
  static const double _vw = 240;
  static const double _vh = 440;

  // Head
  static const double _hCy = 32;
  static const double _hRx = 19;
  static const double _hRy = 22;

  // Neck
  static const double _nY0 = 48;
  static const double _nY1 = 62;
  static const double _nX = 14;

  // Shoulder
  static const double _sY = 64;

  // Arm
  static const double _armW = 9;
  static const double _elbowY = 118;
  static const double _wristY = 158;
  static const double _handY = 172;

  // Torso
  static const double _axY = 82;
  static const double _chestY = 95;
  static const double _waistY = 125;
  static const double _hipY = 155;
  static const double _crotchY = 170;

  static const double _chestX = 28;
  static const double _waistX = 18;
  static const double _hipX = 26;

  // Leg
  static const double _kneeY = 258;
  static const double _ankleY = 358;
  static const double _footY = 375;
  static const double _thighX = 18;
  static const double _calfX = 14;

  // ── Computed proportions ──
  double get _cf => BodyCalculator.chestFactor(metrics);
  double get _wf => BodyCalculator.waistFactor(metrics);
  double get _hf => BodyCalculator.hipFactor(metrics);
  double get _sf => BodyCalculator.shoulderFactor(metrics);
  double get _af => BodyCalculator.armFactor(metrics);

  @override
  void paint(Canvas canvas, Size size) {
    final sc = min(size.width / _vw, size.height / _vh);
    canvas.save();
    canvas.translate(
      (size.width - _vw * sc) / 2 + _vw / 2 * sc,
      (size.height - _vh * sc) / 2,
    );
    canvas.scale(sc, sc);

    // ════════════════════════════════════════
    // LAYER 1 – Body Outline
    // ════════════════════════════════════════
    _drawOutline(canvas);

    // ════════════════════════════════════════
    // LAYER 2 – Muscle Groups
    // ════════════════════════════════════════
    _drawMuscles(canvas);

    canvas.restore();
  }

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

    // ---------- RIGHT HALF (top → down) ----------
    p.moveTo(0, _hCy - _hRy);

    // Head right
    p.cubicTo(_hRx * 0.7, _hCy - _hRy, _hRx, _hCy - _hRy * 0.5, _hRx, _hCy);
    p.cubicTo(_hRx, _hCy + _hRy * 0.5, _hRx * 0.7, _hCy + _hRy, 0, _hCy + _hRy);

    // Neck right
    final neckOut = _nX * _sf.clamp(0.85, 1.15);
    p.cubicTo(neckOut * 0.5, _nY0 + 4, neckOut, _nY1 - 4, neckOut, _nY1);

    // Shoulder
    final shX = 38.0 * _sf;
    p.cubicTo(shX + 4, _sY + 2, shX + 6, _sY + 4, shX + 6, _sY + 10);

    // Right arm outer
    final aW = _armW * _af;
    final aOut = shX + aW + 2;
    p.cubicTo(aOut, _sY + 16, aOut + 2, _elbowY - 8, aOut, _elbowY);
    p.cubicTo(aOut - 1, _wristY - 4, aOut - 2, _wristY + 4, aOut - 3, _handY);

    // Hand bottom
    p.lineTo(shX + 4, _handY);

    // Right arm inner
    p.cubicTo(shX + 3, _wristY + 4, shX + 2, _wristY - 4, shX + 2, _elbowY);
    p.cubicTo(shX + 2, _elbowY - 8, shX + 4, _axY + 4, shX + 4, _axY + 4);

    // Right torso side
    final cX = _chestX * _cf, wX = _waistX * _wf, hX = _hipX * _hf;
    p.cubicTo(cX + 4, _axY + 10, cX + 6, _chestY, cX + 4, _chestY + 6);
    p.cubicTo(cX + 2, _waistY - 10, wX + 4, _waistY - 4, wX + 2, _waistY);
    p.cubicTo(wX, _waistY + 6, hX + 2, _hipY - 6, hX + 4, _hipY);
    p.cubicTo(hX + 3, _hipY + 8, hX, _crotchY - 4, 0, _crotchY);

    // Right leg inner (down)
    final tX = _thighX * _af.clamp(0.9, 1.3);
    final cXleg = _calfX * _af.clamp(0.9, 1.3);
    p.cubicTo(6, _crotchY + 10, tX * 0.6, _kneeY - 20, tX * 0.7, _kneeY - 6);
    p.cubicTo(tX * 0.6, _kneeY + 6, cXleg * 0.5, _ankleY - 10, cXleg * 0.5, _ankleY);
    p.cubicTo(cXleg * 0.5, _ankleY + 4, cXleg * 0.3, _footY - 4, cXleg * 0.3, _footY);

    // Right foot bottom
    final fOut = tX * 1.2;
    p.lineTo(fOut + 2, _footY);

    // Right leg outer (up)
    p.cubicTo(fOut + 3, _footY - 4, fOut + 2, _ankleY + 6, fOut, _ankleY);
    p.cubicTo(fOut - 1, _kneeY + 6, fOut + 1, _kneeY - 8, fOut, _kneeY - 6);
    p.cubicTo(fOut - 1, _hipY + 10, hX + 2, _hipY + 4, hX + 2, _hipY + 4);
    p.cubicTo(hX + 2, _hipY + 2, hX + 4, _hipY + 6, hX + 4, _hipY);

    // ---------- LEFT HALF (bottom → up, mirrored) ----------
    final mirror = -1.0;

    p.cubicTo(hX * mirror + 4, _hipY + 6, hX * mirror + 2, _hipY + 2, hX * mirror + 2, _hipY + 4);
    p.cubicTo(hX * mirror + 2, _hipY + 4, fOut * mirror, _hipY + 10, fOut * mirror, _kneeY - 6);
    p.cubicTo(fOut * mirror + 1, _kneeY - 8, fOut * mirror - 1, _kneeY + 6, fOut * mirror, _ankleY);
    p.cubicTo(fOut * mirror + 2, _ankleY + 6, fOut * mirror + 3, _footY - 4, fOut * mirror + 2, _footY);

    // Left foot bottom
    p.lineTo(cXleg * 0.3 * mirror, _footY);

    // Left leg inner (up to crotch)
    p.cubicTo(cXleg * 0.3 * mirror, _footY - 4, cXleg * 0.5 * mirror, _ankleY + 4, cXleg * 0.5 * mirror, _ankleY);
    p.cubicTo(cXleg * 0.5 * mirror, _ankleY - 10, tX * 0.6 * mirror, _kneeY + 6, tX * 0.7 * mirror, _kneeY - 6);
    p.cubicTo(tX * 0.6 * mirror, _kneeY - 20, 6 * mirror, _crotchY + 10, 0, _crotchY);

    // On left side, torso goes UP from crotch
    p.cubicTo(hX * mirror, _crotchY - 4, hX * mirror + 3, _hipY + 8, hX * mirror + 4, _hipY);
    p.cubicTo(hX * mirror + 2, _hipY - 6, wX * mirror, _waistY + 6, wX * mirror + 2, _waistY);
    p.cubicTo(wX * mirror + 4, _waistY - 4, cX * mirror + 2, _waistY - 10, cX * mirror + 4, _chestY + 6);
    p.cubicTo(cX * mirror + 6, _chestY, cX * mirror + 4, _axY + 10, shX * mirror + 4, _axY + 4);

    // Left arm inner (up)
    p.cubicTo(shX * mirror + 4, _axY + 4, shX * mirror + 2, _elbowY - 8, shX * mirror + 2, _elbowY);
    p.cubicTo(shX * mirror + 2, _wristY - 4, shX * mirror + 3, _wristY + 4, shX * mirror + 4, _handY);

    // Left hand bottom
    p.lineTo((shX + 4 - aW) * mirror, _handY);

    // Left arm outer (up)
    p.cubicTo(aOut * mirror + 3, _handY, aOut * mirror + 1, _wristY + 4, aOut * mirror, _elbowY);
    p.cubicTo(aOut * mirror + 2, _elbowY - 8, aOut * mirror, _sY + 16, shX * mirror + 6, _sY + 10);

    // Left shoulder
    p.cubicTo(shX * mirror + 6, _sY + 4, shX * mirror + 4, _sY + 2, neckOut * mirror, _nY1);

    // Left neck
    p.cubicTo(neckOut * mirror, _nY1 - 4, neckOut * 0.5 * mirror, _nY0 + 4, 0, _hCy + _hRy);

    // Left head
    p.cubicTo(_hRx * 0.7 * mirror, _hCy + _hRy, _hRx * mirror, _hCy + _hRy * 0.5, _hRx * mirror, _hCy);
    p.cubicTo(_hRx * mirror, _hCy - _hRy * 0.5, _hRx * 0.7 * mirror, _hCy - _hRy, 0, _hCy - _hRy);

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
      final defaultPaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, defaultPaint);
      return;
    }

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);
  }

  // ── Muscle geometry builders ──

  Path _buildDeltoid(int side) {
    final shX = 38.0 * _sf;
    final aW = _armW * _af;
    final cX = _chestX * _cf;
    final s = side.toDouble();
    final p = Path();
    p.moveTo(shX * s, _sY + 10);
    p.cubicTo((shX + aW + 2) * s, _sY + 14, (shX + aW + 2) * s, _elbowY - 20, (shX + aW - 2) * s, _elbowY - 12);
    p.cubicTo((shX + 2) * s, _elbowY - 8, (shX + 2) * s, _axY + 8, cX * s * 0.7, _axY + 10);
    p.cubicTo(cX * s * 0.5, _axY + 6, cX * s * 0.3, _sY + 12, shX * s, _sY + 10);
    p.close();
    return p;
  }

  Path _buildPectoral(int side) {
    final cX = _chestX * _cf;
    final s = side.toDouble();
    final p = Path();
    p.moveTo(4, _chestY - 10);
    p.cubicTo(cX * 0.6 * s, _chestY - 12, cX * s, _chestY - 4, cX * s, _chestY + 4);
    p.cubicTo(cX * s * 0.9, _chestY + 14, cX * 0.4 * s, _chestY + 20, 4, _chestY + 16);
    p.cubicTo(2, _chestY + 12, 2, _chestY - 6, 4, _chestY - 10);
    p.close();
    return p;
  }

  Path _buildAbdominals() {
    final wX = _waistX * _wf;
    final p = Path();
    p.moveTo(0, _chestY + 18);
    p.cubicTo(wX * 0.5, _chestY + 20, wX * 0.6, _waistY - 4, wX * 0.5, _waistY);
    p.cubicTo(wX * 0.3, _waistY + 6, 0, _waistY + 4, 0, _waistY + 4);
    p.cubicTo(0, _waistY + 4, wX * -0.3, _waistY + 6, wX * -0.5, _waistY);
    p.cubicTo(wX * -0.6, _waistY - 4, wX * -0.5, _chestY + 20, 0, _chestY + 18);
    p.close();
    return p;
  }

  Path _buildObliques() {
    final cX = _chestX * _cf;
    final wX = _waistX * _wf;
    final p = Path();
    p.moveTo(wX * 0.5, _waistY);
    p.cubicTo(wX * 0.6, _waistY - 4, cX * 0.7, _chestY + 12, cX * 0.5, _chestY + 18);
    p.cubicTo(cX * 0.6, _chestY + 22, cX * 0.9, _chestY + 10, cX * 0.8, _chestY + 6);
    p.cubicTo(cX * 0.7, _hipY - 10, wX * 0.7, _waistY + 6, wX * 0.5, _waistY);
    p.close();
    // Mirror for left side using matrix reflection across y-axis
    final pMirror = Path();
    final mirrorMatrix = Float64List.fromList([
      -1, 0, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1,
    ]);
    pMirror.addPath(p, Offset.zero, matrix4: mirrorMatrix);
    p.addPath(pMirror, Offset.zero);
    return p;
  }

  Path _buildQuadriceps(int side) {
    final tX = _thighX * _af.clamp(0.9, 1.3);
    final s = side.toDouble();
    final p = Path();
    p.moveTo(4, _crotchY + 4);
    p.cubicTo(tX * s * 0.8, _crotchY + 6, tX * s, _crotchY + 20, tX * s, _kneeY - 10);
    p.cubicTo(tX * s * 0.7, _kneeY - 4, tX * 0.4 * s, _kneeY, 4, _kneeY - 2);
    p.cubicTo(2, _kneeY - 4, 2, _crotchY + 6, 4, _crotchY + 4);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant FrontBodyPainter old) {
    return old.metrics != metrics || old.highlightedMuscles != highlightedMuscles;
  }
}
