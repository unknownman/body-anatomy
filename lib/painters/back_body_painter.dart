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

  // ── Symmetrical 1:1 Torso-to-Leg Ratio Landmarks (Same as Front) ──
  static const double yHT  = 20.0;
  static const double yHB  = 75.0;
  static const double yNB  = 95.0;
  static const double ySh  = 105.0;
  static const double yAx  = 135.0;
  static const double yLat = 155.0;
  static const double yCh  = 160.0;
  static const double yWa  = 205.0;
  static const double yHi  = 245.0;
  static const double yCr  = 265.0;
  static const double yKn  = 345.0;
  static const double yAn  = 415.0;
  static const double yFt  = 435.0;
  static const double yWr  = 275.0;

  // ── Widths (Same as Front to ensure zero-jitter switches) ──
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

    // Torso side (back)
    p.cubicTo(sW - 4, yAx + 8, cW, yLat - 10, cW, yLat);
    p.cubicTo(cW, yLat + 15, wW + 2, yWa - 15, wW, yWa);
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
    p.cubicTo(wW * m + 2, yWa - 15, cW * m, yLat + 15, cW * m, yLat);
    p.cubicTo(cW * m, yLat - 10, sW * m - 4 * m, yAx + 8, sW * m - 2 * m, yAx);

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
    _drawMuscle(canvas, 'trapezius', _buildTrapezius());
    _drawMuscle(canvas, 'deltoid_left', _buildDeltoid(-1));
    _drawMuscle(canvas, 'deltoid_right', _buildDeltoid(1));
    _drawMuscle(canvas, 'infraspinatus_left', _buildInfraspinatus(-1));
    _drawMuscle(canvas, 'infraspinatus_right', _buildInfraspinatus(1));
    _drawMuscle(canvas, 'teres_major_left', _buildTeresMajor(-1));
    _drawMuscle(canvas, 'teres_major_right', _buildTeresMajor(1));
    _drawMuscle(canvas, 'latissimus_dorsi_left', _buildLatissimus(-1));
    _drawMuscle(canvas, 'latissimus_dorsi_right', _buildLatissimus(1));
    _drawMuscle(canvas, 'erector_spinae_left', _buildErector(-1));
    _drawMuscle(canvas, 'erector_spinae_right', _buildErector(1));
    _drawMuscle(canvas, 'gluteus_maximus_left', _buildGlute(-1));
    _drawMuscle(canvas, 'gluteus_maximus_right', _buildGlute(1));
    _drawMuscle(canvas, 'biceps_femoris_left', _buildBicepsFemoris(-1));
    _drawMuscle(canvas, 'biceps_femoris_right', _buildBicepsFemoris(1));
    _drawMuscle(canvas, 'semitendinosus_left', _buildSemitendinosus(-1));
    _drawMuscle(canvas, 'semitendinosus_right', _buildSemitendinosus(1));
    _drawMuscle(canvas, 'gastrocnemius_lateral_left', _buildGastrocnemiusLat(-1));
    _drawMuscle(canvas, 'gastrocnemius_lateral_right', _buildGastrocnemiusLat(1));
    _drawMuscle(canvas, 'gastrocnemius_medial_left', _buildGastrocnemiusMed(-1));
    _drawMuscle(canvas, 'gastrocnemius_medial_right', _buildGastrocnemiusMed(1));
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

  Path _buildTrapezius() {
    double nW = _nW, sW = _sW;
    final p = Path();
    p.moveTo(0, yNB - 6);
    p.quadraticBezierTo(nW * 0.6, yNB - 4, sW * 0.7, ySh + 4);
    p.quadraticBezierTo(sW * 0.5, ySh + 10, 0, ySh + 6);
    p.quadraticBezierTo(sW * -0.5, ySh + 10, sW * -0.7, ySh + 4);
    p.quadraticBezierTo(nW * -0.6, yNB - 4, 0, yNB - 6);
    p.close();
    return p;
  }

  Path _buildDeltoid(int side) {
    double s = side.toDouble(), sW = _sW, aW = _aW;
    final p = Path();
    p.moveTo(sW * s, ySh + 2);
    p.quadraticBezierTo((sW + aW + 2) * s, ySh + 14, (sW + aW) * s, ySh + 40);
    p.quadraticBezierTo((sW + 2) * s, ySh + 52, sW * 0.5 * s, yAx - 2);
    p.quadraticBezierTo(sW * 0.3 * s, ySh + 10, sW * s, ySh + 2);
    p.close();
    return p;
  }

  Path _buildInfraspinatus(int side) {
    double s = side.toDouble(), sW = _sW;
    final p = Path();
    p.moveTo(sW * 0.45 * s, ySh + 8);
    p.quadraticBezierTo(sW * 0.7 * s, ySh + 12, sW * 0.6 * s, ySh + 26);
    p.quadraticBezierTo(sW * 0.4 * s, ySh + 32, sW * 0.35 * s, ySh + 20);
    p.close();
    return p;
  }

  Path _buildTeresMajor(int side) {
    double s = side.toDouble(), sW = _sW;
    final p = Path();
    p.moveTo(sW * 0.35 * s, ySh + 22);
    p.quadraticBezierTo(sW * 0.55 * s, ySh + 28, sW * 0.45 * s, yAx - 4);
    p.quadraticBezierTo(sW * 0.3 * s, yAx - 8, sW * 0.25 * s, ySh + 30);
    p.close();
    return p;
  }

  Path _buildLatissimus(int side) {
    double s = side.toDouble(), lW = _cW, wW = _wW;
    final p = Path();
    p.moveTo(lW * 0.3 * s, yLat - 6);
    p.quadraticBezierTo(lW * s, yLat - 10, lW * s - 1, yLat + 6);
    p.quadraticBezierTo(lW * s - 2, yWa - 10, wW * s - 1, yWa);
    p.quadraticBezierTo(wW * s - 3, yWa - 8, lW * 0.25 * s, yLat + 4);
    p.close();
    return p;
  }

  Path _buildErector(int side) {
    double s = side.toDouble(), wW = _wW;
    final p = Path();
    p.moveTo(4, yLat + 2);
    p.quadraticBezierTo(wW * 0.3 * s, yLat + 6, wW * 0.3 * s, yWa - 6);
    p.quadraticBezierTo(wW * 0.2 * s, yWa + 6, 4, yWa + 4);
    p.close();
    return p;
  }

  Path _buildGlute(int side) {
    double s = side.toDouble(), gW = _hW;
    final p = Path();
    p.moveTo(4 * s, yHi + 2);
    p.quadraticBezierTo(gW * 0.75 * s, yHi - 2, gW * s, yHi + 4);
    p.quadraticBezierTo(gW * s - 1, yHi + 12, gW * 0.5 * s, yHi + 14);
    p.quadraticBezierTo(2 * s, yHi + 12, 2 * s, yHi + 4);
    p.close();
    return p;
  }

  Path _buildBicepsFemoris(int side) {
    double s = side.toDouble(), tW = _thighW;
    final p = Path();
    p.moveTo(tW * 0.35 * s, yCr + 8);
    p.quadraticBezierTo(tW * 0.6 * s, yCr + 14, tW * 0.6 * s, yKn - 20);
    p.quadraticBezierTo(tW * 0.5 * s, yKn - 2, tW * 0.35 * s, yKn + 2);
    p.close();
    return p;
  }

  Path _buildSemitendinosus(int side) {
    double s = side.toDouble(), tW = _thighW;
    final p = Path();
    p.moveTo(tW * 0.35 * s, yCr + 8);
    p.quadraticBezierTo(tW * 0.35 * s, yCr + 16, tW * 0.35 * s, yKn - 20);
    p.quadraticBezierTo(tW * 0.2 * s, yKn - 2, tW * 0.15 * s, yKn + 2);
    p.quadraticBezierTo(tW * 0.15 * s, yCr + 14, tW * 0.35 * s, yCr + 8);
    p.close();
    return p;
  }

  Path _buildGastrocnemiusLat(int side) {
    double s = side.toDouble(), cW = _calfW;
    final p = Path();
    p.moveTo(cW * 0.3 * s, yKn + 6);
    p.quadraticBezierTo(cW * 0.5 * s, yKn + 16, cW * 0.45 * s, yAn - 60);
    p.quadraticBezierTo(cW * 0.35 * s, yAn - 30, cW * 0.3 * s, yAn - 10);
    p.quadraticBezierTo(cW * 0.2 * s, yKn + 14, cW * 0.3 * s, yKn + 6);
    p.close();
    return p;
  }

  Path _buildGastrocnemiusMed(int side) {
    double s = side.toDouble(), cW = _calfW;
    final p = Path();
    p.moveTo(cW * 0.15 * s, yKn + 8);
    p.quadraticBezierTo(cW * 0.35 * s, yKn + 16, cW * 0.3 * s, yAn - 55);
    p.quadraticBezierTo(cW * 0.2 * s, yAn - 30, cW * 0.15 * s, yAn - 10);
    p.quadraticBezierTo(cW * 0.1 * s, yKn + 14, cW * 0.15 * s, yKn + 8);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant BackBodyPainter old) {
    return old.metrics != metrics || old.highlightedMuscles != highlightedMuscles;
  }
}
