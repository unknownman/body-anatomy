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

  // ── Y grid ──
  static const double yHT = 15, yHC = 40, yHB = 63;
  static const double yNB = 85;
  static const double ySh = 92, yAx = 112, yLat = 132;
  static const double yWa = 172, yHi = 218, yCr = 243;
  static const double yEl = 188, yWr = 278, yHd = 308;
  static const double yKn = 322, yAn = 408, yFt = 432;

  // ── Widths ──
  double get _hR => 20.0;
  double get _nW => 16.0;
  double get _sW => (_isF ? 38.0 : 42.0) * _sf;
  double get _aW => 11.0 * _af;
  double get _lW => (_isF ? 27.0 : 30.0) * _cf * 0.95;
  double get _wW => (_isF ? 16.0 : 22.0) * _wf;
  double get _gW => (_isF ? 27.0 : 23.0) * _hf;
  double get _tW => 17.0 * _af;
  double get _cW => 14.0 * _af;

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
    double lW = _lW, wW = _wW, gW = _gW, tW = _tW, cW = _cW;

    p.moveTo(0, yHT);

    // Head back
    p.cubicTo(hR * 0.65, yHT, hR - 2, yHC - 6, hR - 2, yHC);
    p.cubicTo(hR - 2, yHC + 6, hR * 0.6, yHB, 0, yHB);

    // Neck
    p.cubicTo(nW * 0.4, yHB + 2, nW, yNB - 4, nW, yNB);

    // Shoulder
    double aOut = sW + aW;
    p.cubicTo(nW + 4, yNB + 2, sW, ySh - 2, sW, ySh + 4);
    p.cubicTo(sW + 2, ySh + 12, aOut, ySh + 22, aOut, yEl - 10);
    p.cubicTo(aOut + 2, yEl - 2, aOut + 2, yEl + 6, aOut, yWr - 8);
    p.cubicTo(aOut - 1, yWr - 2, aOut - 1, yWr + 2, aOut - 2, yWr + 6);

    _buildRightHand(p, aOut);
    p.lineTo(sW + 2, yWr + 6);
    p.cubicTo(sW + 2, yWr - 2, sW + 1, yWr - 10, sW + 1, yEl + 4);
    p.cubicTo(sW + 1, yEl - 8, sW + 3, yAx + 6, sW + 2, yAx + 8);

    // Torso back
    p.cubicTo(lW + 2, yAx + 14, lW + 4, yLat - 2, lW + 2, yLat + 4);
    p.cubicTo(lW, yWa - 14, wW + 2, yWa - 4, wW, yWa + 2);
    p.cubicTo(wW - 1, yWa + 8, gW + 1, yHi - 6, gW + 2, yHi + 2);
    p.cubicTo(gW + 1, yHi + 10, gW * 0.4, yCr - 2, 0, yCr);

    p.cubicTo(tW * 0.35, yCr + 8, tW * 0.5, yKn - 28, tW * 0.5, yKn - 4);
    p.cubicTo(tW * 0.4, yKn + 4, cW * 0.3, yAn - 12, cW * 0.3, yAn);
    p.cubicTo(cW * 0.3, yAn + 4, cW * 0.2, yFt - 4, cW * 0.2, yFt);

    double fO = tW * 0.85;
    p.lineTo(fO + 2, yFt);
    p.cubicTo(fO + 3, yFt - 4, fO + 2, yAn + 4, fO, yAn);
    p.cubicTo(fO - 1, yKn + 4, fO + 1, yKn - 8, fO, yKn - 4);
    p.cubicTo(fO - 1, yHi + 14, gW + 1, yHi + 4, gW + 1, yHi + 2);

    // Left half
    double m = -1.0;
    p.cubicTo(gW * m + 1, yHi + 4, fO * m, yHi + 14, fO * m, yKn - 4);
    p.cubicTo(fO * m + 1, yKn - 8, fO * m - 1, yKn + 4, fO * m, yAn);
    p.cubicTo(fO * m + 2, yAn + 4, fO * m + 3, yFt - 4, fO * m + 2, yFt);
    p.lineTo(cW * 0.2 * m, yFt);
    p.cubicTo(cW * 0.2 * m, yFt - 4, cW * 0.3 * m, yAn + 4, cW * 0.3 * m, yAn);
    p.cubicTo(cW * 0.3 * m, yAn - 12, tW * 0.4 * m, yKn + 4, tW * 0.5 * m, yKn - 4);
    p.cubicTo(tW * 0.5 * m, yKn - 28, tW * 0.35 * m, yCr + 8, 0, yCr);

    p.cubicTo(gW * 0.4 * m, yCr - 2, gW * m + 1, yHi + 10, gW * m + 2, yHi + 2);
    p.cubicTo(gW * m + 1, yHi - 6, wW * m - 1, yWa + 8, wW * m, yWa + 2);
    p.cubicTo(wW * m + 2, yWa - 4, lW * m, yWa - 14, lW * m + 2, yLat + 4);
    p.cubicTo(lW * m + 4, yLat - 2, lW * m + 2, yAx + 14, sW * m + 2, yAx + 8);

    p.cubicTo(sW * m + 3, yAx + 6, sW * m + 1, yEl - 8, sW * m + 1, yEl + 4);
    p.cubicTo(sW * m + 1, yWr - 10, sW * m + 2, yWr - 2, sW * m + 2, yWr + 6);
    p.lineTo((aOut - aW + 2) * m, yWr + 6);
    _buildLeftHand(p, aOut);

    p.cubicTo(aOut * m + 2, yWr + 6, aOut * m + 1, yWr + 2, aOut * m, yWr - 8);
    p.cubicTo(aOut * m + 2, yEl + 6, aOut * m + 2, yEl - 2, aOut * m, yEl - 10);
    p.cubicTo(aOut * m, ySh + 22, sW * m + 2, ySh + 12, sW * m, ySh + 4);
    p.cubicTo(sW * m, ySh - 2, nW * m + 4, yNB + 2, nW * m, yNB);
    p.cubicTo(nW * m, yNB - 4, nW * 0.4 * m, yHB + 2, 0, yHB);

    p.cubicTo(hR * 0.6 * m, yHB, hR * m - 2, yHC + 6, hR * m - 2, yHC);
    p.cubicTo(hR * m - 2, yHC - 6, hR * 0.65 * m, yHT, 0, yHT);
    p.close();
    return p;
  }

  void _buildRightHand(Path p, double aOut) {
    double hx = aOut - 2, hy = yWr + 6;
    p.lineTo(hx - 1, hy + 2);
    p.quadraticBezierTo(hx + 2, hy + 8, hx + 1, hy + 14);
    p.quadraticBezierTo(hx, hy + 24, hx - 1, hy + 20);
    p.quadraticBezierTo(hx - 2, hy + 14, hx - 3, hy + 16);
    p.quadraticBezierTo(hx - 4, hy + 28, hx - 5, hy + 24);
    p.quadraticBezierTo(hx - 6, hy + 16, hx - 7, hy + 18);
    p.quadraticBezierTo(hx - 8, hy + 30, hx - 9, hy + 26);
    p.quadraticBezierTo(hx - 10, hy + 18, hx - 11, hy + 20);
    p.quadraticBezierTo(hx - 12, hy + 28, hx - 14, hy + 24);
    p.quadraticBezierTo(hx - 16, hy + 18, hx - 17, hy + 16);
    p.quadraticBezierTo(hx - 18, hy + 14, hx - 18, hy + 8);
  }

  void _buildLeftHand(Path p, double aOut) {
    double hx = (aOut - 2) * -1, hy = yWr + 6;
    p.lineTo(hx + 1, hy + 2);
    p.quadraticBezierTo(hx - 2, hy + 8, hx - 1, hy + 14);
    p.quadraticBezierTo(hx, hy + 24, hx + 1, hy + 20);
    p.quadraticBezierTo(hx + 2, hy + 14, hx + 3, hy + 16);
    p.quadraticBezierTo(hx + 4, hy + 28, hx + 5, hy + 24);
    p.quadraticBezierTo(hx + 6, hy + 16, hx + 7, hy + 18);
    p.quadraticBezierTo(hx + 8, hy + 30, hx + 9, hy + 26);
    p.quadraticBezierTo(hx + 10, hy + 18, hx + 11, hy + 20);
    p.quadraticBezierTo(hx + 12, hy + 28, hx + 14, hy + 24);
    p.quadraticBezierTo(hx + 16, hy + 18, hx + 17, hy + 16);
    p.quadraticBezierTo(hx + 18, hy + 14, hx + 18, hy + 8);
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
    double s = side.toDouble(), lW = _lW, wW = _wW;
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
    double s = side.toDouble(), gW = _gW;
    final p = Path();
    p.moveTo(4, yHi + 2);
    p.quadraticBezierTo(gW * 0.7 * s, yHi - 2, gW * s, yHi + 4);
    p.quadraticBezierTo(gW * s - 1, yHi + 12, gW * 0.5 * s, yHi + 14);
    p.quadraticBezierTo(2, yHi + 12, 2, yHi + 4);
    p.close();
    return p;
  }

  Path _buildBicepsFemoris(int side) {
    double s = side.toDouble(), tW = _tW;
    final p = Path();
    p.moveTo(tW * 0.35 * s, yCr + 8);
    p.quadraticBezierTo(tW * 0.6 * s, yCr + 14, tW * 0.6 * s, yKn - 20);
    p.quadraticBezierTo(tW * 0.5 * s, yKn - 2, tW * 0.35 * s, yKn + 2);
    p.close();
    return p;
  }

  Path _buildSemitendinosus(int side) {
    double s = side.toDouble(), tW = _tW;
    final p = Path();
    p.moveTo(tW * 0.35 * s, yCr + 8);
    p.quadraticBezierTo(tW * 0.35 * s, yCr + 16, tW * 0.35 * s, yKn - 20);
    p.quadraticBezierTo(tW * 0.2 * s, yKn - 2, tW * 0.15 * s, yKn + 2);
    p.quadraticBezierTo(tW * 0.15 * s, yCr + 14, tW * 0.35 * s, yCr + 8);
    p.close();
    return p;
  }

  Path _buildGastrocnemiusLat(int side) {
    double s = side.toDouble(), cW = _cW;
    final p = Path();
    p.moveTo(cW * 0.3 * s, yKn + 6);
    p.quadraticBezierTo(cW * 0.5 * s, yKn + 16, cW * 0.45 * s, yAn - 60);
    p.quadraticBezierTo(cW * 0.35 * s, yAn - 30, cW * 0.3 * s, yAn - 10);
    p.quadraticBezierTo(cW * 0.2 * s, yKn + 14, cW * 0.3 * s, yKn + 6);
    p.close();
    return p;
  }

  Path _buildGastrocnemiusMed(int side) {
    double s = side.toDouble(), cW = _cW;
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
