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

  static const double _vw = 220;
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
  static const double ySh = 92, yCh = 132;
  static const double yWa = 172, yHi = 218, yCr = 243;
  static const double yKn = 322, yAn = 408, yFt = 432;

  double get _sW => 26.0 * _sf;
  double get _aS => 8.0 * _af; // arm width in side view

  // ─────────────────────────────────────────
  //  LAYER 1 + 2: Silhouette & Outline
  // ─────────────────────────────────────────
  void _drawSilhouette(Canvas canvas) {
    canvas.drawPath(
      _buildProfilePath(),
      Paint()
        ..color = const Color(0xFFF2EDE8)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawOutline(Canvas canvas) {
    canvas.drawPath(
      _buildProfilePath(),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  Path _buildProfilePath() {
    final p = Path();
    double bP = _isF ? 32 + _cf * 4 : 26 + _cf * 2;
    double bU = _isF ? yCh - 4 : yCh - 8;
    double bL = _isF ? yCh + 10 : yCh + 4;
    double aP = 22 + _wf * 4;
    double pP = 22 + _hf * 3;
    double gP = _isF ? -28 - _hf * 6 : -24 - _hf * 4;
    double uB = _isF ? -16 : -18 - _sf * 2;

    // ── Front contour ──
    p.moveTo(0, yHT);
    p.quadraticBezierTo(18, yHT + 4, 24, 20);
    p.quadraticBezierTo(28, 26, 30, 30);
    p.quadraticBezierTo(34, 32, 36, 34);
    p.quadraticBezierTo(30, 36, 32, 40);
    p.quadraticBezierTo(30, 42, 28, 46);
    p.quadraticBezierTo(30, 48, 28, 50);
    p.quadraticBezierTo(24, 54, 22, 60);
    p.lineTo(22, yNB);

    // Chest / bust
    p.cubicTo(24, ySh + 4, bP, yCh - 12, bP, bU);
    p.quadraticBezierTo(bP - 2, yCh + 6, bL, bL + 6);

    // Abdomen
    p.cubicTo(26, bL + 12, aP, yWa - 8, aP - 2, yWa + 4);
    p.cubicTo(aP - 4, yWa + 12, pP, yHi - 6, pP - 2, yHi + 4);
    p.cubicTo(pP - 4, yHi + 14, 14, yCr - 2, 10, yCr);

    // Leg front
    p.cubicTo(14, yCr + 6, 20, yCr + 30, 20, yKn - 30);
    p.quadraticBezierTo(20, yKn - 6, 18, yKn);
    p.cubicTo(18, yKn + 8, 16, yAn - 14, 14, yAn + 2);
    p.cubicTo(14, yAn + 8, 26, yFt - 8, 30, yFt - 2);
    p.quadraticBezierTo(32, yFt + 2, 28, yFt + 4);
    p.cubicTo(22, yFt + 8, 6, yFt + 6, -4, yFt + 2);
    p.quadraticBezierTo(-8, yFt, -6, yFt - 4);

    // ── Back contour ──
    p.quadraticBezierTo(-4, yFt - 8, -2, yAn + 4);

    double cB = -4 - _af * 10;
    p.cubicTo(-2, yAn - 6, cB, yCr + 130, cB + 2, yKn + 22);
    p.quadraticBezierTo(cB + 4, yKn - 4, -4, yKn);

    p.cubicTo(-4, yKn - 8, -10, yCr + 30, -10, yCr + 4);
    p.cubicTo(-10, yCr - 2, -8, yHi + 8, -8, yHi + 4);

    // Glutes
    p.cubicTo(-8, yHi - 6, gP, yWa + 24, gP + 2, yWa + 6);
    p.quadraticBezierTo(gP + 4, yWa - 2, -10, yWa);

    // Back
    p.cubicTo(-10, yWa - 10, -12, bL + 8, -12, bL);
    p.cubicTo(-12, bL - 10, uB, yCh - 6, uB + 2, ySh + 8);
    p.quadraticBezierTo(uB - 2, yNB + 2, -10, yNB);

    // Back of neck & head
    p.quadraticBezierTo(-8, yNB - 8, -12, yHC + 8);
    p.quadraticBezierTo(-14, yHC - 6, -8, yHT + 6);
    p.quadraticBezierTo(-4, yHT, 0, yHT);

    p.close();
    return p;
  }

  // ─────────────────────────────────────────
  //  LAYER 3: Muscles
  // ─────────────────────────────────────────
  void _drawMuscles(Canvas canvas) {
    _drawMuscle(canvas, 'deltoid_right', _buildDeltoid());
    _drawMuscle(canvas, 'pectoral_right', _buildPectoral());
    _drawMuscle(canvas, 'abdominals', _buildAbdominals());
    _drawMuscle(canvas, 'obliques', _buildObliques());
    _drawMuscle(canvas, 'gluteus_maximus_right', _buildGlute());
    _drawMuscle(canvas, 'quadriceps_right', _buildQuadriceps());
    _drawMuscle(canvas, 'biceps_femoris_right', _buildHamstring());
    _drawMuscle(canvas, 'gastrocnemius_right', _buildCalf());
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

  Path _buildDeltoid() {
    double sW = _sW, aS = _aS;
    final p = Path();
    p.moveTo(18, ySh + 2);
    p.quadraticBezierTo(sW * 0.6 + aS, ySh + 8, sW * 0.6 + aS - 2, ySh + 36);
    p.quadraticBezierTo(sW * 0.5, ySh + 42, 18, ySh + 20);
    p.close();
    return p;
  }

  Path _buildPectoral() {
    double bP = _isF ? 30 + _cf * 4 : 26 + _cf * 2;
    final p = Path();
    p.moveTo(20, ySh + 10);
    p.quadraticBezierTo(bP, yCh - 14, bP + 2, yCh - 2);
    p.quadraticBezierTo(bP, yCh + 6, 24, yCh + 6);
    p.quadraticBezierTo(20, yCh + 2, 20, ySh + 20);
    p.close();
    return p;
  }

  Path _buildAbdominals() {
    double aP = 22 + _wf * 4;
    final p = Path();
    p.moveTo(20, yCh + 10);
    p.quadraticBezierTo(aP, yWa - 8, aP - 2, yWa + 2);
    p.quadraticBezierTo(aP - 4, yWa + 10, 16, yWa + 4);
    p.quadraticBezierTo(16, yCh + 12, 20, yCh + 10);
    p.close();
    return p;
  }

  Path _buildObliques() {
    final p = Path();
    p.moveTo(22, yCh + 12);
    p.quadraticBezierTo(28, yCh + 16, 26, yWa - 4);
    p.quadraticBezierTo(24, yWa + 6, 18, yWa + 4);
    p.quadraticBezierTo(18, yCh + 14, 24, yCh + 12);
    p.close();
    return p;
  }

  Path _buildGlute() {
    double gP = _isF ? -26 - _hf * 6 : -22 - _hf * 4;
    final p = Path();
    p.moveTo(-8, yHi + 2);
    p.quadraticBezierTo(gP, yWa + 22, gP + 2, yWa + 6);
    p.quadraticBezierTo(gP + 4, yWa - 2, -10, yWa);
    p.quadraticBezierTo(-8, yWa + 6, -8, yHi + 2);
    p.close();
    return p;
  }

  Path _buildQuadriceps() {
    final p = Path();
    p.moveTo(10, yCr + 4);
    p.quadraticBezierTo(18, yCr + 18, 19, yKn - 30);
    p.quadraticBezierTo(18, yKn - 4, 16, yKn);
    p.quadraticBezierTo(12, yKn - 4, 8, yCr + 8);
    p.close();
    return p;
  }

  Path _buildHamstring() {
    final p = Path();
    p.moveTo(-8, yCr + 6);
    p.quadraticBezierTo(-10, yCr + 18, -8, yKn - 20);
    p.quadraticBezierTo(-6, yKn - 4, -4, yKn);
    p.quadraticBezierTo(-4, yCr + 12, -8, yCr + 6);
    p.close();
    return p;
  }

  Path _buildCalf() {
    double cB = -4 - _af * 10;
    final p = Path();
    p.moveTo(12, yKn + 8);
    p.quadraticBezierTo(cB + 6, yKn + 20, cB + 4, yAn - 60);
    p.quadraticBezierTo(cB + 3, yAn - 20, 10, yAn - 4);
    p.quadraticBezierTo(10, yKn + 14, 14, yKn + 8);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant SideBodyPainter old) {
    return old.metrics != metrics || old.highlightedMuscles != highlightedMuscles;
  }
}
