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

  static const double _vw = 250;
  static const double _vh = 450;

  @override
  void paint(Canvas canvas, Size size) {
    final sc = min(size.width / _vw, size.height / _vh);
    canvas.save();
    canvas.translate(
      (size.width - _vw * sc) / 2 + _vw / 2 * sc,
      (size.height - _vh * sc) / 2,
    );
    canvas.scale(sc, sc);

    _drawSilhouette(canvas);
    _drawMuscles(canvas);
    _drawOutline(canvas);

    canvas.restore();
  }

  double get _cf => BodyCalculator.chestFactor(metrics);
  double get _wf => BodyCalculator.waistFactor(metrics);
  double get _hf => BodyCalculator.hipFactor(metrics);
  double get _sf => BodyCalculator.shoulderFactor(metrics);
  double get _af => BodyCalculator.armFactor(metrics);
  bool get _isF => metrics.gender == Gender.female;

  // ── Symmetrical 1:1 Torso-to-Leg Ratio Landmarks ──
  static const double yHT  = 20.0;
  static const double yHB  = 75.0;
  static const double yNB  = 95.0;
  static const double ySh  = 105.0;
  static const double yAx  = 135.0;
  static const double yCh  = 160.0;
  static const double yWa  = 205.0;
  static const double yHi  = 245.0;
  static const double yCr  = 265.0;
  static const double yKn  = 345.0;
  static const double yAn  = 415.0;
  static const double yFt  = 435.0;
  static const double yWr  = 275.0;

  // ── Symmetrical Horizontal Grid ──
  double get _hR     => 19.0;
  double get _nW     => (_isF ? 11.0 : 16.0) * _sf;
  double get _sW     => (_isF ? 34.0 : 45.0) * _sf;
  double get _aW     => (_isF ? 8.0 : 13.0) * _af;
  double get _cW     => (_isF ? 28.0 : 36.0) * _cf;
  double get _wW     => (_isF ? 17.0 : 25.0) * _wf;
  double get _hW     => (_isF ? 32.0 : 27.0) * _hf;
  double get _thighW => (_isF ? 19.0 : 23.0) * _af;
  double get _calfW  => (_isF ? 11.0 : 15.0) * _af;

  void _drawSilhouette(Canvas canvas) {
    canvas.drawPath(
      _buildSilhouettePath(),
      Paint()
        ..color = const Color(0xFFF2EDE8)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawOutline(Canvas canvas) {
    canvas.drawPath(
      _buildSilhouettePath(),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  Path _buildSilhouettePath() {
    final p = Path();
    double hR = _hR, nW = _nW, sW = _sW, aW = _aW;
    double cW = _cW, wW = _wW, hW = _hW, tW = _thighW, c2 = _calfW;

    // ── RIGHT HALF (top → bottom) ──
    p.moveTo(0, yHT);
    p.cubicTo(hR * 0.7, yHT, hR, yHT + 15, hR, yHT + 28);
    p.cubicTo(hR, yHT + 38, hR * 0.7, yHB, 0, yHB);

    // Neck & Trapezius slope
    p.cubicTo(0, yHB + 2, nW, yNB - 4, nW, yNB);
    p.cubicTo(nW + 4, yNB + 2, sW * 0.75, ySh - 4, sW, ySh);

    // Arm outer
    double aOut = sW + aW;
    p.cubicTo(sW + 4, ySh + 15, aOut + 4, ySh + 35, aOut, yWr - 85);
    p.cubicTo(aOut + 2, yWr - 40, aOut + 1, yWr - 15, aOut - 3, yWr);

    // Splayed Fingers Hand
    _buildRightHand(p, aOut);

    // Arm inner
    p.lineTo(sW + 1, yWr);
    p.cubicTo(sW + 1, yWr - 20, sW, yWr - 60, sW + 1, yWr - 85);
    p.cubicTo(sW + 2, yWr - 110, sW + 2, yAx + 10, sW - 2, yAx);

    // Torso side
    p.cubicTo(sW - 4, yAx + 8, cW, yCh - 10, cW, yCh);
    p.cubicTo(cW, yCh + 15, wW + 2, yWa - 15, wW, yWa);
    p.cubicTo(wW - 2, yWa + 15, hW + 1, yHi - 15, hW, yHi);
    p.cubicTo(hW, yHi + 10, hW * 0.4, yCr - 2, 0, yCr);

    // Leg inner (down)
    p.cubicTo(4.0, yCr + 15, 6.0, yKn - 30, 4.0, yKn);
    p.cubicTo(4.0, yKn + 25, 3.0, yAn - 25, 3.0, yAn);
    p.lineTo(1.0, yFt);

    // Foot base
    p.lineTo(c2 + 5.0, yFt);

    // Leg outer (up)
    p.cubicTo(c2 + 4.0, yFt - 5, c2 + 1.0, yAn + 5, c2, yAn);
    p.cubicTo(c2 + 2.0, yAn - 25, tW * 0.55, yKn + 25, tW * 0.45, yKn);
    p.cubicTo(tW * 0.9, yKn - 35, hW, yHi + 15, hW, yHi);
    p.cubicTo(hW + 1, yHi - 4, hW + 2, yHi - 10, hW, yHi - 15);

    // ── LEFT HALF (bottom → top, mirrored) ──
    double m = -1.0;

    p.cubicTo(hW * m - 1, yHi - 10, hW * m - 2, yHi - 4, hW * m, yHi);
    p.cubicTo(tW * 0.9 * m, yKn - 35, hW * m - 2 * m, yKn + 25, c2 * m, yAn);
    p.cubicTo(c2 * m - 1 * m, yAn + 5, c2 * m - 4 * m, yFt - 5, (c2 + 5.0) * m, yFt);
    p.lineTo(1.0 * m, yFt);

    p.cubicTo(3.0 * m, yAn, 4.0 * m, yKn + 25, 4.0 * m, yKn);
    p.cubicTo(4.0 * m, yKn - 25, 5.0 * m, yCr + 15, 0, yCr);

    p.cubicTo(hW * 0.4 * m, yCr - 2, hW * m, yHi + 10, hW * m, yHi);
    p.cubicTo(hW * m, yHi - 15, wW * m - 2, yWa + 15, wW * m, yWa);
    p.cubicTo(wW * m + 2, yWa - 15, cW * m, yCh + 15, cW * m, yCh);
    p.cubicTo(cW * m, yCh - 10, sW * m - 4 * m, yAx + 8, sW * m - 2 * m, yAx);

    p.cubicTo(sW * m + 2 * m, yWr - 110, sW * m + 2 * m, yWr - 60, sW * m + 1 * m, yWr - 85);
    p.lineTo(sW * m + 1 * m, yWr);

    _buildLeftHand(p, aOut);

    p.cubicTo(aOut * m + 1 * m, yWr - 15, aOut * m + 2 * m, yWr - 40, aOut * m, yWr - 85);
    p.cubicTo(aOut * m, ySh + 35, sW * m - 4 * m, ySh + 15, sW * m, ySh);

    p.cubicTo(sW * m, ySh, nW * m - 3 * m, yNB + 2, nW * m, yNB);
    p.cubicTo(nW * m, yNB - 4, nW * 0.4 * m, yHB + 2, 0, yHB);

    p.cubicTo(hR * 0.7 * m, yHB, hR * m, yHT + 38, hR * m, yHT + 28);
    p.cubicTo(hR * m, yHT + 15, hR * 0.7 * m, yHT, 0, yHT);

    p.close();
    return p;
  }

  void _buildRightHand(Path p, double aOut) {
    double hx = aOut - 3, hy = yWr;
    p.lineTo(hx + 1, hy + 8);
    // Pinky
    p.quadraticBezierTo(hx + 5, hy + 20, hx + 3, hy + 22);
    p.quadraticBezierTo(hx + 1, hy + 22, hx, hy + 12);
    // Ring
    p.quadraticBezierTo(hx - 2, hy + 25, hx - 4, hy + 25);
    p.quadraticBezierTo(hx - 6, hy + 25, hx - 5, hy + 12);
    // Middle
    p.quadraticBezierTo(hx - 8, hy + 28, hx - 10, hy + 28);
    p.quadraticBezierTo(hx - 12, hy + 28, hx - 10, hy + 12);
    // Index
    p.quadraticBezierTo(hx - 14, hy + 25, hx - 16, hy + 25);
    p.quadraticBezierTo(hx - 17, hy + 23, hx - 14, hy + 10);
    // Thumb
    p.quadraticBezierTo(hx - 19, hy + 16, hx - 21, hy + 12);
    p.quadraticBezierTo(hx - 19, hy + 6, hx - 11, hy + 4);
  }

  void _buildLeftHand(Path p, double aOut) {
    double m = -1.0;
    double hx = (aOut - 3) * m, hy = yWr;
    p.lineTo(hx + 1 * m, hy + 8);
    // Pinky
    p.quadraticBezierTo(hx + 5 * m, hy + 20, hx + 3 * m, hy + 22);
    p.quadraticBezierTo(hx + 1 * m, hy + 22, hx, hy + 12);
    // Ring
    p.quadraticBezierTo(hx - 2 * m, hy + 25, hx - 4 * m, hy + 25);
    p.quadraticBezierTo(hx - 6 * m, hy + 25, hx - 5 * m, hy + 12);
    // Middle
    p.quadraticBezierTo(hx - 8 * m, hy + 28, hx - 10 * m, hy + 28);
    p.quadraticBezierTo(hx - 12 * m, hy + 28, hx - 10 * m, hy + 12);
    // Index
    p.quadraticBezierTo(hx - 14 * m, hy + 25, hx - 16 * m, hy + 25);
    p.quadraticBezierTo(hx - 17 * m, hy + 23, hx - 14 * m, hy + 10);
    // Thumb
    p.quadraticBezierTo(hx - 19 * m, hy + 16, hx - 21 * m, hy + 12);
    p.quadraticBezierTo(hx - 19 * m, hy + 6, hx - 11 * m, hy + 4);
  }

  void _drawMuscles(Canvas canvas) {
    _drawMuscle(canvas, 'sternocleidomastoid_left', _buildSCM(-1));
    _drawMuscle(canvas, 'sternocleidomastoid_right', _buildSCM(1));
    _drawMuscle(canvas, 'pectoral_left', _buildPectoral(-1));
    _drawMuscle(canvas, 'pectoral_right', _buildPectoral(1));
    _drawMuscle(canvas, 'deltoid_left', _buildDeltoid(-1));
    _drawMuscle(canvas, 'deltoid_right', _buildDeltoid(1));
    _drawMuscle(canvas, 'biceps_left', _buildBiceps(-1));
    _drawMuscle(canvas, 'biceps_right', _buildBiceps(1));
    _drawMuscle(canvas, 'brachioradialis_left', _buildBrachioradialis(-1));
    _drawMuscle(canvas, 'brachioradialis_right', _buildBrachioradialis(1));
    _drawMuscle(canvas, 'forearm_flexor_left', _buildForearm(-1));
    _drawMuscle(canvas, 'forearm_flexor_right', _buildForearm(1));
    _drawMuscle(canvas, 'rectus_abdominis_upper_left', _buildAbs(-1, -1));
    _drawMuscle(canvas, 'rectus_abdominis_upper_right', _buildAbs(1, -1));
    _drawMuscle(canvas, 'rectus_abdominis_mid_left', _buildAbs(-1, 0));
    _drawMuscle(canvas, 'rectus_abdominis_mid_right', _buildAbs(1, 0));
    _drawMuscle(canvas, 'rectus_abdominis_lower_left', _buildAbs(-1, 1));
    _drawMuscle(canvas, 'rectus_abdominis_lower_right', _buildAbs(1, 1));
    _drawMuscle(canvas, 'serratus_anterior_left', _buildSerratus(-1));
    _drawMuscle(canvas, 'serratus_anterior_right', _buildSerratus(1));
    _drawMuscle(canvas, 'obliques', _buildObliques());
    _drawMuscle(canvas, 'quadriceps_rectus_femoris_left', _buildRF(-1));
    _drawMuscle(canvas, 'quadriceps_rectus_femoris_right', _buildRF(1));
    _drawMuscle(canvas, 'quadriceps_vastus_lateralis_left', _buildVL(-1));
    _drawMuscle(canvas, 'quadriceps_vastus_lateralis_right', _buildVL(1));
    _drawMuscle(canvas, 'quadriceps_vastus_medialis_left', _buildVM(-1));
    _drawMuscle(canvas, 'quadriceps_vastus_medialis_right', _buildVM(1));
    _drawMuscle(canvas, 'sartorius_left', _buildSartorius(-1));
    _drawMuscle(canvas, 'sartorius_right', _buildSartorius(1));
    _drawMuscle(canvas, 'tibialis_anterior_left', _buildTibialis(-1));
    _drawMuscle(canvas, 'tibialis_anterior_right', _buildTibialis(1));
    _drawMuscle(canvas, 'gastrocnemius_left', _buildGastrocnemius(-1));
    _drawMuscle(canvas, 'gastrocnemius_right', _buildGastrocnemius(1));

    // Aliases
    _drawMuscle(canvas, 'abdominals', _buildCombinedAbs());
  }

  void _drawMuscle(Canvas canvas, String key, Path path) {
    final color = highlightedMuscles[key];
    final fill = color ?? Colors.grey.withValues(alpha: 0.12);
    canvas.drawPath(path, Paint()..color = fill..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);
  }

  Path _buildSCM(int side) {
    double s = side.toDouble(), nW = _nW;
    final p = Path();
    p.moveTo(4 * s, yHB + 4);
    p.quadraticBezierTo(nW * 0.75 * s, yHB + 10, nW * s * 0.8, yNB - 4);
    p.quadraticBezierTo(nW * s * 0.4, yNB - 2, 3 * s, yNB - 4);
    p.close();
    return p;
  }

  Path _buildPectoral(int side) {
    double s = side.toDouble(), cW = _cW;
    final p = Path();
    p.moveTo(2, yCh - 12);
    p.quadraticBezierTo(cW * 0.65 * s, yCh - 18, cW * s, yCh - 4);
    p.quadraticBezierTo(cW * s * 0.85, yCh + 6, cW * 0.5 * s, yCh + 12);
    p.quadraticBezierTo(2, yCh + 16, 2, yCh + 6);
    p.close();
    return p;
  }

  Path _buildDeltoid(int side) {
    double s = side.toDouble(), sW = _sW, aW = _aW;
    final p = Path();
    p.moveTo(sW * s, ySh + 2);
    p.quadraticBezierTo((sW + aW + 2) * s, ySh + 14, (sW + aW) * s, ySh + 40);
    p.quadraticBezierTo((sW + 2) * s, ySh + 52, sW * s * 0.5, yAx - 2);
    p.quadraticBezierTo(sW * 0.3 * s, ySh + 10, sW * s, ySh + 2);
    p.close();
    return p;
  }

  Path _buildBiceps(int side) {
    double s = side.toDouble(), sW = _sW, aW = _aW;
    final p = Path();
    p.moveTo((sW + aW - 2) * s, ySh + 38);
    p.quadraticBezierTo((sW + aW - 1) * s, ySh + 50, (sW + aW * 0.4) * s, yWr - 86);
    p.quadraticBezierTo((sW + 2) * s, yWr - 78, (sW + 1) * s, ySh + 50);
    p.quadraticBezierTo((sW + 2) * s, ySh + 40, (sW + aW - 2) * s, ySh + 38);
    p.close();
    return p;
  }

  Path _buildBrachioradialis(int side) {
    double s = side.toDouble(), sW = _sW, aW = _aW;
    final p = Path();
    p.moveTo((sW + aW - 1) * s, yWr - 86);
    p.quadraticBezierTo((sW + aW) * s, yWr - 40, (sW + aW - 1) * s, yWr - 6);
    p.quadraticBezierTo((sW + aW * 0.5) * s, yWr - 2, (sW + aW * 0.4) * s, yWr - 80);
    p.close();
    return p;
  }

  Path _buildForearm(int side) {
    double s = side.toDouble(), sW = _sW, aW = _aW;
    final p = Path();
    p.moveTo((sW + aW * 0.4) * s, yWr - 80);
    p.quadraticBezierTo((sW + aW * 0.5) * s, yWr - 2, (sW + 2) * s, yWr - 4);
    p.quadraticBezierTo((sW + 2) * s, yWr - 76, (sW + aW * 0.4) * s, yWr - 80);
    p.close();
    return p;
  }

  Path _buildAbs(int side, int row) {
    double s = side.toDouble(), wW = _wW;
    double y0, y1;
    switch (row) {
      case -1: y0 = yCh + 14; y1 = yWa - 18; break;
      case 0:  y0 = yWa - 18; y1 = yWa + 14; break;
      default: y0 = yWa + 14; y1 = yHi - 8; break;
    }
    double hw = wW * 0.4 * s;
    final p = Path();
    p.moveTo(2, y0);
    p.quadraticBezierTo(hw, y0 + 2, hw, y0 + 6);
    p.quadraticBezierTo(hw, y1 - 4, hw * 0.8, y1);
    p.quadraticBezierTo(hw * 0.4, y1 + 2, 2, y1);
    p.close();
    return p;
  }

  Path _buildSerratus(int side) {
    double s = side.toDouble(), cW = _cW;
    final p = Path();
    p.moveTo(cW * 0.5 * s, yCh + 4);
    p.quadraticBezierTo(cW * s * 0.8, yCh + 6, cW * s * 0.75, yCh + 14);
    p.quadraticBezierTo(cW * s * 0.7, yWa - 14, cW * 0.4 * s, yWa - 8);
    p.quadraticBezierTo(cW * 0.3 * s, yCh + 14, cW * 0.5 * s, yCh + 4);
    p.close();
    return p;
  }

  Path _buildObliques() {
    double wW = _wW, cW = _cW;
    final p = Path();
    p.moveTo(wW * 0.5, yWa - 4);
    p.quadraticBezierTo(cW * 0.75, yCh + 12, cW * 0.7, yCh + 16);
    p.quadraticBezierTo(cW * 0.85, yCh + 20, cW * 0.8, yCh + 10);
    p.quadraticBezierTo(cW * 0.7, yHi - 10, wW * 0.6, yWa + 4);
    p.close();

    final pm = Path();
    final mat = Float64List.fromList([-1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1]);
    pm.addPath(p, Offset.zero, matrix4: mat);
    p.addPath(pm, Offset.zero);
    return p;
  }

  Path _buildRF(int side) {
    double s = side.toDouble(), tW = _thighW;
    final p = Path();
    p.moveTo(4, yCr + 6);
    p.quadraticBezierTo(tW * 0.45 * s, yCr + 14, tW * 0.45 * s, yKn - 24);
    p.quadraticBezierTo(tW * 0.35 * s, yKn - 4, tW * 0.2 * s, yKn + 2);
    p.quadraticBezierTo(2, yKn - 2, 2, yCr + 10);
    p.close();
    return p;
  }

  Path _buildVL(int side) {
    double s = side.toDouble(), tW = _thighW;
    final p = Path();
    p.moveTo(tW * 0.45 * s, yCr + 14);
    p.quadraticBezierTo(tW * 0.7 * s, yCr + 20, tW * 0.7 * s, yKn - 20);
    p.quadraticBezierTo(tW * 0.65 * s, yKn - 4, tW * 0.45 * s, yKn - 4);
    p.quadraticBezierTo(tW * 0.45 * s, yKn - 24, tW * 0.45 * s, yCr + 14);
    p.close();
    return p;
  }

  Path _buildVM(int side) {
    double s = side.toDouble(), tW = _thighW;
    final p = Path();
    p.moveTo(tW * 0.2 * s, yKn - 6);
    p.quadraticBezierTo(tW * 0.4 * s, yKn - 14, tW * 0.45 * s, yKn - 20);
    p.quadraticBezierTo(tW * 0.4 * s, yKn - 2, tW * 0.2 * s, yKn + 2);
    p.close();
    return p;
  }

  Path _buildSartorius(int side) {
    double s = side.toDouble(), hW = _hW, tW = _thighW;
    final p = Path();
    p.moveTo(hW * 0.6 * s, yHi - 6);
    p.quadraticBezierTo(hW * 0.3 * s, yCr + 6, tW * 0.3 * s, yCr + 12);
    p.quadraticBezierTo(tW * 0.1 * s, yCr + 16, tW * 0.1 * s, yKn - 20);
    p.quadraticBezierTo(tW * 0.2 * s, yKn - 6, tW * 0.3 * s, yCr + 12);
    p.close();
    return p;
  }

  Path _buildTibialis(int side) {
    double s = side.toDouble(), c2 = _calfW;
    final p = Path();
    p.moveTo(c2 * 0.3 * s, yKn + 6);
    p.quadraticBezierTo(c2 * 0.5 * s, yKn + 18, c2 * 0.5 * s, yAn - 18);
    p.quadraticBezierTo(c2 * 0.4 * s, yAn - 4, c2 * 0.25 * s, yAn - 2);
    p.quadraticBezierTo(c2 * 0.15 * s, yKn + 12, c2 * 0.3 * s, yKn + 6);
    p.close();
    return p;
  }

  Path _buildGastrocnemius(int side) {
    double s = side.toDouble(), c2 = _calfW;
    final p = Path();
    p.moveTo(c2 * 0.3 * s, yKn + 6);
    p.quadraticBezierTo(c2 * 0.5 * s, yKn + 14, c2 * 0.45 * s, yAn - 60);
    p.quadraticBezierTo(c2 * 0.35 * s, yAn - 20, c2 * 0.25 * s, yAn - 2);
    p.quadraticBezierTo(c2 * 0.2 * s, yKn + 14, c2 * 0.3 * s, yKn + 6);
    p.close();
    return p;
  }

  Path _buildCombinedAbs() {
    double wW = _wW;
    final p = Path();
    p.moveTo(0, yCh + 14);
    p.quadraticBezierTo(wW * 0.4, yCh + 16, wW * 0.4, yWa - 4);
    p.quadraticBezierTo(wW * 0.35, yHi - 6, 0, yHi - 8);
    p.quadraticBezierTo(wW * -0.35, yHi - 6, wW * -0.4, yWa - 4);
    p.quadraticBezierTo(wW * -0.4, yCh + 16, 0, yCh + 14);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant FrontBodyPainter old) {
    return old.metrics != metrics || old.highlightedMuscles != highlightedMuscles;
  }
}
