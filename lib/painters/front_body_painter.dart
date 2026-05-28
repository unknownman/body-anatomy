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

  // ── Factors ──
  double get _cf => BodyCalculator.chestFactor(metrics);
  double get _wf => BodyCalculator.waistFactor(metrics);
  double get _hf => BodyCalculator.hipFactor(metrics);
  double get _sf => BodyCalculator.shoulderFactor(metrics);
  double get _af => BodyCalculator.armFactor(metrics);
  bool get _isF => metrics.gender == Gender.female;

  // ── Y grid ──
  static const double yHT = 15, yHC = 40, yHB = 63;
  static const double yNB = 85;
  static const double ySh = 92, yAx = 112, yCh = 130;
  static const double yWa = 172, yHi = 218, yCr = 243;
  static const double yEl = 188, yWr = 278, yHd = 308;
  static const double yKn = 322, yAn = 408, yFt = 432;
  static const double yBottom = 445;

  // ── Widths (right half) ──
  double get _hR => 20.0;
  double get _nW => 15.0;
  double get _sW => (_isF ? 38.0 : 42.0) * _sf;
  double get _aW => 11.0 * _af;
  double get _cW => (_isF ? 27.0 : 30.0) * _cf;
  double get _wW => (_isF ? 16.0 : 22.0) * _wf;
  double get _hW => (_isF ? 26.0 : 22.0) * _hf;
  double get _tW => 17.0 * _af;
  double get _cW2 => 13.0 * _af;

  // ─────────────────────────────────────────
  //  LAYER 1: Silhouette fill
  // ─────────────────────────────────────────
  void _drawSilhouette(Canvas canvas) {
    canvas.drawPath(
      _buildSilhouettePath(),
      Paint()
        ..color = const Color(0xFFF2EDE8)
        ..style = PaintingStyle.fill,
    );
  }

  // ─────────────────────────────────────────
  //  LAYER 2: Outer dark outline
  // ─────────────────────────────────────────
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

  // ── Build the full body silhouette ──
  Path _buildSilhouettePath() {
    final p = Path();
    double hR = _hR, nW = _nW, sW = _sW, aW = _aW;
    double cW = _cW, wW = _wW, hW = _hW, tW = _tW, c2 = _cW2;

    // ── RIGHT HALF (top → bottom) ──
    p.moveTo(0, yHT);

    // Head
    p.cubicTo(hR * 0.7, yHT, hR, yHC - 8, hR, yHC);
    p.cubicTo(hR, yHC + 8, hR * 0.7, yHB, 0, yHB);

    // Neck
    p.cubicTo(nW * 0.4, yHB + 2, nW, yNB - 4, nW, yNB);

    // Shoulder → arm outer
    double aOut = sW + aW;
    p.cubicTo(nW + 6, yNB + 2, sW, ySh - 2, sW, ySh + 4);
    p.cubicTo(sW + 2, ySh + 12, aOut, ySh + 22, aOut, yEl - 10);
    p.cubicTo(aOut + 2, yEl - 2, aOut + 2, yEl + 6, aOut, yWr - 8);
    p.cubicTo(aOut - 1, yWr - 2, aOut - 1, yWr + 2, aOut - 2, yWr + 6);

    // Hand with fingers
    _buildRightHand(p, aOut);

    // Hand → arm inner
    p.lineTo(sW + 2, yWr + 6);
    p.cubicTo(sW + 2, yWr - 2, sW + 1, yWr - 10, sW + 1, yEl + 4);
    p.cubicTo(sW + 1, yEl - 8, sW + 3, yAx + 6, sW + 2, yAx + 8);

    // Torso side
    p.cubicTo(cW + 2, yAx + 14, cW + 4, yCh - 2, cW + 2, yCh + 4);
    p.cubicTo(cW, yWa - 14, wW + 2, yWa - 4, wW, yWa + 2);
    p.cubicTo(wW - 1, yWa + 8, hW + 1, yHi - 6, hW + 2, yHi + 2);
    p.cubicTo(hW + 1, yHi + 10, hW * 0.4, yCr - 2, 0, yCr);

    // Leg inner down
    p.cubicTo(tW * 0.35, yCr + 8, tW * 0.5, yKn - 28, tW * 0.5, yKn - 4);
    p.cubicTo(tW * 0.4, yKn + 4, c2 * 0.3, yAn - 12, c2 * 0.3, yAn);
    p.cubicTo(c2 * 0.3, yAn + 4, c2 * 0.2, yFt - 4, c2 * 0.2, yFt);

    // Foot bottom
    double fO = tW * 0.85;
    p.lineTo(fO + 2, yFt);

    // Leg outer up
    p.cubicTo(fO + 3, yFt - 4, fO + 2, yAn + 4, fO, yAn);
    p.cubicTo(fO - 1, yKn + 4, fO + 1, yKn - 8, fO, yKn - 4);
    p.cubicTo(fO - 1, yHi + 14, hW + 1, yHi + 4, hW + 1, yHi + 2);

    // ── LEFT HALF (bottom → top) ──
    double m = -1.0;

    p.cubicTo(hW * m + 1, yHi + 4, fO * m, yHi + 14, fO * m, yKn - 4);
    p.cubicTo(fO * m + 1, yKn - 8, fO * m - 1, yKn + 4, fO * m, yAn);
    p.cubicTo(fO * m + 2, yAn + 4, fO * m + 3, yFt - 4, fO * m + 2, yFt);
    p.lineTo(c2 * 0.2 * m, yFt);

    p.cubicTo(c2 * 0.2 * m, yFt - 4, c2 * 0.3 * m, yAn + 4, c2 * 0.3 * m, yAn);
    p.cubicTo(c2 * 0.3 * m, yAn - 12, tW * 0.4 * m, yKn + 4, tW * 0.5 * m, yKn - 4);
    p.cubicTo(tW * 0.5 * m, yKn - 28, tW * 0.35 * m, yCr + 8, 0, yCr);

    p.cubicTo(hW * 0.4 * m, yCr - 2, hW * m + 1, yHi + 10, hW * m + 2, yHi + 2);
    p.cubicTo(hW * m + 1, yHi - 6, wW * m - 1, yWa + 8, wW * m, yWa + 2);
    p.cubicTo(wW * m + 2, yWa - 4, cW * m, yWa - 14, cW * m + 2, yCh + 4);
    p.cubicTo(cW * m + 4, yCh - 2, cW * m + 2, yAx + 14, sW * m + 2, yAx + 8);

    // Left arm inner up
    p.cubicTo(sW * m + 3, yAx + 6, sW * m + 1, yEl - 8, sW * m + 1, yEl + 4);
    p.cubicTo(sW * m + 1, yWr - 10, sW * m + 2, yWr - 2, sW * m + 2, yWr + 6);
    p.lineTo((aOut - aW + 2) * m, yWr + 6);

    // Left hand
    _buildLeftHand(p, aOut);

    p.cubicTo(aOut * m + 2, yWr + 6, aOut * m + 1, yWr + 2, aOut * m, yWr - 8);
    p.cubicTo(aOut * m + 2, yEl + 6, aOut * m + 2, yEl - 2, aOut * m, yEl - 10);
    p.cubicTo(aOut * m, ySh + 22, sW * m + 2, ySh + 12, sW * m, ySh + 4);
    p.cubicTo(sW * m, ySh - 2, nW * m + 6, yNB + 2, nW * m, yNB);
    p.cubicTo(nW * m, yNB - 4, nW * 0.4 * m, yHB + 2, 0, yHB);

    // Left head
    p.cubicTo(hR * 0.7 * m, yHB, hR * m, yHC + 8, hR * m, yHC);
    p.cubicTo(hR * m, yHC - 8, hR * 0.7 * m, yHT, 0, yHT);

    p.close();
    return p;
  }

  void _buildRightHand(Path p, double aOut) {
    double hx = aOut - 2;
    double hy = yWr + 6;

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
    double hx = (aOut - 2) * -1;
    double hy = yWr + 6;

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

  // ─────────────────────────────────────────
  //  LAYER 3: Muscle Groups (puzzle style)
  // ─────────────────────────────────────────
  void _drawMuscles(Canvas canvas) {
    // Neck
    _drawMuscle(canvas, 'sternocleidomastoid_left', _buildSCM(-1));
    _drawMuscle(canvas, 'sternocleidomastoid_right', _buildSCM(1));
    // Chest
    _drawMuscle(canvas, 'pectoral_left', _buildPectoral(-1));
    _drawMuscle(canvas, 'pectoral_right', _buildPectoral(1));
    // Shoulders
    _drawMuscle(canvas, 'deltoid_left', _buildDeltoid(-1));
    _drawMuscle(canvas, 'deltoid_right', _buildDeltoid(1));
    // Arms
    _drawMuscle(canvas, 'biceps_left', _buildBiceps(-1));
    _drawMuscle(canvas, 'biceps_right', _buildBiceps(1));
    _drawMuscle(canvas, 'brachioradialis_left', _buildBrachioradialis(-1));
    _drawMuscle(canvas, 'brachioradialis_right', _buildBrachioradialis(1));
    // Forearms
    _drawMuscle(canvas, 'forearm_flexor_left', _buildForearm(-1));
    _drawMuscle(canvas, 'forearm_flexor_right', _buildForearm(1));
    // Abs
    _drawMuscle(canvas, 'rectus_abdominis_upper_left', _buildAbs(-1, -1));
    _drawMuscle(canvas, 'rectus_abdominis_upper_right', _buildAbs(1, -1));
    _drawMuscle(canvas, 'rectus_abdominis_mid_left', _buildAbs(-1, 0));
    _drawMuscle(canvas, 'rectus_abdominis_mid_right', _buildAbs(1, 0));
    _drawMuscle(canvas, 'rectus_abdominis_lower_left', _buildAbs(-1, 1));
    _drawMuscle(canvas, 'rectus_abdominis_lower_right', _buildAbs(1, 1));
    // Serratus
    _drawMuscle(canvas, 'serratus_anterior_left', _buildSerratus(-1));
    _drawMuscle(canvas, 'serratus_anterior_right', _buildSerratus(1));
    // Obliques
    _drawMuscle(canvas, 'obliques', _buildObliques());
    // Quads
    _drawMuscle(canvas, 'quadriceps_rectus_femoris_left', _buildRF(-1));
    _drawMuscle(canvas, 'quadriceps_rectus_femoris_right', _buildRF(1));
    _drawMuscle(canvas, 'quadriceps_vastus_lateralis_left', _buildVL(-1));
    _drawMuscle(canvas, 'quadriceps_vastus_lateralis_right', _buildVL(1));
    _drawMuscle(canvas, 'quadriceps_vastus_medialis_left', _buildVM(-1));
    _drawMuscle(canvas, 'quadriceps_vastus_medialis_right', _buildVM(1));
    // Sartorius
    _drawMuscle(canvas, 'sartorius_left', _buildSartorius(-1));
    _drawMuscle(canvas, 'sartorius_right', _buildSartorius(1));
    // Lower leg
    _drawMuscle(canvas, 'tibialis_anterior_left', _buildTibialis(-1));
    _drawMuscle(canvas, 'tibialis_anterior_right', _buildTibialis(1));
    _drawMuscle(canvas, 'gastrocnemius_left', _buildGastrocnemius(-1));
    _drawMuscle(canvas, 'gastrocnemius_right', _buildGastrocnemius(1));
    // ── Backward-compat aliases ──
    _drawMuscle(canvas, 'abdominals', _buildCombinedAbs());
    _drawMuscle(canvas, 'quadriceps_left', _buildCombinedQuad(-1));
    _drawMuscle(canvas, 'quadriceps_right', _buildCombinedQuad(1));
  }

  void _drawMuscle(Canvas canvas, String key, Path path) {
    final color = highlightedMuscles[key];
    final fillColor = color ?? Colors.grey.withValues(alpha: 0.12);
    final strokeColor = Colors.white;

    canvas.drawPath(path, Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill);

    canvas.drawPath(path, Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);
  }

  // ═══════════════════════════════════════
  //  MUSCLE BUILDERS
  // ═══════════════════════════════════════

  Path _buildSCM(int side) {
    double s = side.toDouble();
    double nW = _nW;
    final p = Path();
    p.moveTo(4, yHB + 4);
    p.quadraticBezierTo(nW * 0.7 * s, yHB + 10, nW * s * 0.8, yNB - 6);
    p.quadraticBezierTo(nW * s * 0.5, yNB - 2, 3, yNB - 4);
    p.close();
    return p;
  }

  Path _buildPectoral(int side) {
    double s = side.toDouble();
    double cW = _cW;
    final p = Path();
    p.moveTo(2, yCh - 10);
    p.quadraticBezierTo(cW * 0.6 * s, yCh - 16, cW * s, yCh - 4);
    p.quadraticBezierTo(cW * s * 0.85, yCh + 8, cW * 0.5 * s, yCh + 14);
    p.quadraticBezierTo(2, yCh + 18, 2, yCh + 8);
    p.close();
    return p;
  }

  Path _buildDeltoid(int side) {
    double s = side.toDouble();
    double sW = _sW, aW = _aW;
    final p = Path();
    p.moveTo(sW * s, ySh + 2);
    p.quadraticBezierTo((sW + aW + 2) * s, ySh + 14, (sW + aW) * s, ySh + 40);
    p.quadraticBezierTo((sW + 2) * s, ySh + 52, sW * s * 0.5, yAx - 2);
    p.quadraticBezierTo(sW * 0.3 * s, ySh + 10, sW * s, ySh + 2);
    p.close();
    return p;
  }

  Path _buildBiceps(int side) {
    double s = side.toDouble();
    double sW = _sW, aW = _aW;
    final p = Path();
    p.moveTo((sW + aW - 2) * s, ySh + 38);
    p.quadraticBezierTo((sW + aW - 1) * s, ySh + 50, (sW + aW * 0.4) * s, yEl - 14);
    p.quadraticBezierTo((sW + 2) * s, yEl - 6, (sW + 1) * s, ySh + 50);
    p.quadraticBezierTo((sW + 2) * s, ySh + 40, (sW + aW - 2) * s, ySh + 38);
    p.close();
    return p;
  }

  Path _buildBrachioradialis(int side) {
    double s = side.toDouble();
    double sW = _sW, aW = _aW;
    final p = Path();
    p.moveTo((sW + aW - 1) * s, yEl - 6);
    p.quadraticBezierTo((sW + aW) * s, yEl + 10, (sW + aW - 1) * s, yWr - 6);
    p.quadraticBezierTo((sW + aW * 0.5) * s, yWr - 2, (sW + aW * 0.4) * s, yEl + 4);
    p.close();
    return p;
  }

  Path _buildForearm(int side) {
    double s = side.toDouble();
    double sW = _sW, aW = _aW;
    final p = Path();
    p.moveTo((sW + aW * 0.4) * s, yEl + 4);
    p.quadraticBezierTo((sW + aW * 0.5) * s, yWr - 2, (sW + 2) * s, yWr - 4);
    p.quadraticBezierTo((sW + 2) * s, yEl + 10, (sW + aW * 0.4) * s, yEl + 4);
    p.close();
    return p;
  }

  Path _buildAbs(int side, int row) {
    double s = side.toDouble();
    double wW = _wW;
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
    double s = side.toDouble();
    double cW = _cW;
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
    // Mirror
    final pm = Path();
    final mat = Float64List.fromList([-1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1]);
    pm.addPath(p, Offset.zero, matrix4: mat);
    p.addPath(pm, Offset.zero);
    return p;
  }

  Path _buildRF(int side) {
    double s = side.toDouble();
    double tW = _tW;
    final p = Path();
    p.moveTo(4, yCr + 6);
    p.quadraticBezierTo(tW * 0.45 * s, yCr + 14, tW * 0.45 * s, yKn - 24);
    p.quadraticBezierTo(tW * 0.35 * s, yKn - 4, tW * 0.2 * s, yKn + 2);
    p.quadraticBezierTo(2, yKn - 2, 2, yCr + 10);
    p.close();
    return p;
  }

  Path _buildVL(int side) {
    double s = side.toDouble();
    double tW = _tW;
    final p = Path();
    p.moveTo(tW * 0.45 * s, yCr + 14);
    p.quadraticBezierTo(tW * 0.7 * s, yCr + 20, tW * 0.7 * s, yKn - 20);
    p.quadraticBezierTo(tW * 0.65 * s, yKn - 4, tW * 0.45 * s, yKn - 4);
    p.quadraticBezierTo(tW * 0.45 * s, yKn - 24, tW * 0.45 * s, yCr + 14);
    p.close();
    return p;
  }

  Path _buildVM(int side) {
    double s = side.toDouble();
    double tW = _tW;
    final p = Path();
    p.moveTo(tW * 0.2 * s, yKn - 6);
    p.quadraticBezierTo(tW * 0.4 * s, yKn - 14, tW * 0.45 * s, yKn - 20);
    p.quadraticBezierTo(tW * 0.4 * s, yKn - 2, tW * 0.2 * s, yKn + 2);
    p.close();
    return p;
  }

  Path _buildSartorius(int side) {
    double s = side.toDouble();
    double hW = _hW, tW = _tW;
    final p = Path();
    p.moveTo(hW * 0.6 * s, yHi - 6);
    p.quadraticBezierTo(hW * 0.3 * s, yCr + 6, tW * 0.3 * s, yCr + 12);
    p.quadraticBezierTo(tW * 0.1 * s, yCr + 16, tW * 0.1 * s, yKn - 20);
    p.quadraticBezierTo(tW * 0.2 * s, yKn - 6, tW * 0.3 * s, yCr + 12);
    p.close();
    return p;
  }

  Path _buildTibialis(int side) {
    double s = side.toDouble();
    double c2 = _cW2;
    final p = Path();
    p.moveTo(c2 * 0.3 * s, yKn + 6);
    p.quadraticBezierTo(c2 * 0.5 * s, yKn + 18, c2 * 0.5 * s, yAn - 18);
    p.quadraticBezierTo(c2 * 0.4 * s, yAn - 4, c2 * 0.25 * s, yAn - 2);
    p.quadraticBezierTo(c2 * 0.15 * s, yKn + 12, c2 * 0.3 * s, yKn + 6);
    p.close();
    return p;
  }

  Path _buildGastrocnemius(int side) {
    double s = side.toDouble();
    double c2 = _cW2;
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

  Path _buildCombinedQuad(int side) {
    double s = side.toDouble(), tW = _tW;
    final p = Path();
    p.moveTo(4, yCr + 6);
    p.quadraticBezierTo(tW * 0.7 * s, yCr + 16, tW * 0.7 * s, yKn - 20);
    p.quadraticBezierTo(tW * 0.5 * s, yKn - 2, tW * 0.2 * s, yKn + 2);
    p.quadraticBezierTo(2, yKn - 2, 2, yCr + 10);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant FrontBodyPainter old) {
    return old.metrics != metrics || old.highlightedMuscles != highlightedMuscles;
  }
}
