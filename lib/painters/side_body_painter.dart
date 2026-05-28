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

  // ── Perfectly Aligned Vertical Grid ──
  static const double yHT  = 20.0;
  static const double yHB  = 75.0;
  static const double yNB  = 95.0;
  static const double ySh  = 105.0;
  static const double yCh  = 160.0;
  static const double yWa  = 205.0;
  static const double yHi  = 245.0;
  static const double yCr  = 265.0;
  static const double yKn  = 345.0;
  static const double yAn  = 415.0;
  static const double yFt  = 435.0;
  static const double yToe  = 432.0;

  double get _sW => 26.0 * _sf;
  double get _aS => (_isF ? 7.0 : 10.0) * _af;

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

    // ── FRONT PROFILE (facing right) ──
    p.moveTo(0, yHT);
    p.quadraticBezierTo(14, yHT + 5, 16, yHT + 15);
    p.quadraticBezierTo(22, yHT + 22, 20, yHT + 26); // nose
    p.quadraticBezierTo(16, yHT + 32, 17, yHT + 38); // lips
    p.quadraticBezierTo(14, yHT + 44, 12, yHB);      // chin
    p.quadraticBezierTo(8, yHB + 10, 8, yNB);

    // Chest/Bust (Strictly fixed horizontal coordinate space to prevent spikes)
    if (_isF) {
      double bustX = 14 + _cf * 14;
      p.cubicTo(8, yNB + 15, bustX, yCh - 20, bustX, yCh);
      p.cubicTo(bustX, yCh + 15, 12, yCh + 25, 8, yCh + 35);
    } else {
      double chestX = 10 + _cf * 8;
      p.cubicTo(8, yNB + 15, chestX, yCh - 15, chestX, yCh);
      p.quadraticBezierTo(chestX - 2, yCh + 15, 6, yCh + 25);
    }

    // Abdomen & Front thigh
    double bellyX = (_isF ? 4 : 8) * _wf;
    p.cubicTo(6, yCh + 25, bellyX + 3, yWa - 10, bellyX, yWa);
    p.cubicTo(bellyX - 2, yWa + 15, 6, yHi - 10, 4, yHi);
    p.cubicTo(4, yHi + 10, 6, yCr, 4, yCr);
    p.cubicTo(6, yCr + 15, 12, yKn - 30, 10, yKn);

    // Shin & Toe
    p.cubicTo(10, yKn + 20, 8, yAn - 15, 6, yAn);
    p.cubicTo(6, yAn + 5, 16, yFt - 5, 20, yToe);
    p.quadraticBezierTo(20, yFt, 14, yFt);

    // Foot base
    p.lineTo(-12, yFt);

    // ── BACK PROFILE (bottom → top) ──
    p.quadraticBezierTo(-16, yFt, -12, yAn + 4);
    p.quadraticBezierTo(-10, yAn, -10, yAn - 5);

    double calfX = (_isF ? -12 : -15) * _af;
    p.cubicTo(-10, yAn - 20, calfX, yKn + 25, calfX, yKn + 15);
    p.quadraticBezierTo(calfX + 2, yKn - 5, -8, yKn - 10);
    p.cubicTo(-8, yKn - 20, -12, yCr + 15, -10, yCr);

    // Glutes (Beautiful curves for both genders)
    double gluteX = _isF ? -10 - _hf * 18 : -8 - _hf * 10;
    p.cubicTo(-10, yCr - 5, gluteX, yHi + 15, gluteX, yHi);
    p.cubicTo(gluteX, yHi - 15, -10, yWa + 15, -10, yWa);

    // Lumbar & Thoracic spines
    p.cubicTo(-10, yWa - 15, -12, yCh + 15, -12, yCh);
    double backX = (_isF ? -10 : -14) * _sf;
    p.cubicTo(-12, yCh - 15, backX, ySh + 15, backX, ySh);

    // Head back
    p.cubicTo(backX, ySh - 10, -10, yNB, -8, yNB - 10);
    p.cubicTo(-12, yNB - 25, -14, yHT + 25, 0, yHT);

    p.close();
    return p;
  }

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
    p.moveTo(0, ySh + 2);
    p.quadraticBezierTo(sW * 0.4 + aS, ySh + 8, sW * 0.4 + aS - 2, ySh + 36);
    p.quadraticBezierTo(sW * 0.3, ySh + 42, 0, ySh + 20);
    p.close();
    return p;
  }

  Path _buildPectoral() {
    double bP = _isF ? 14 + _cf * 14 : 10 + _cf * 8;
    final p = Path();
    p.moveTo(6, ySh + 10);
    p.quadraticBezierTo(bP, yCh - 14, bP, yCh);
    p.quadraticBezierTo(bP - 2, yCh + 6, 8, yCh + 12);
    p.quadraticBezierTo(6, yCh + 2, 6, ySh + 20);
    p.close();
    return p;
  }

  Path _buildAbdominals() {
    double aP = (_isF ? 4 : 8) * _wf;
    final p = Path();
    p.moveTo(8, yCh + 14);
    p.quadraticBezierTo(aP, yWa - 8, aP - 2, yWa + 2);
    p.quadraticBezierTo(aP - 4, yWa + 10, 4, yWa + 4);
    p.quadraticBezierTo(4, yCh + 16, 8, yCh + 14);
    p.close();
    return p;
  }

  Path _buildObliques() {
    final p = Path();
    p.moveTo(10, yCh + 16);
    p.quadraticBezierTo(14, yCh + 20, 12, yWa - 4);
    p.quadraticBezierTo(10, yWa + 6, 6, yWa + 4);
    p.quadraticBezierTo(6, yCh + 18, 10, yCh + 16);
    p.close();
    return p;
  }

  Path _buildGlute() {
    double gluteX = _isF ? -10 - _hf * 18 : -8 - _hf * 10;
    final p = Path();
    p.moveTo(-8, yHi + 4);
    p.quadraticBezierTo(gluteX, yWa + 22, gluteX + 2, yWa + 6);
    p.quadraticBezierTo(gluteX + 4, yWa - 2, -10, yWa);
    p.quadraticBezierTo(-8, yWa + 6, -8, yHi + 4);
    p.close();
    return p;
  }

  Path _buildQuadriceps() {
    final p = Path();
    p.moveTo(8, yCr + 4);
    p.quadraticBezierTo(16, yCr + 18, 17, yKn - 30);
    p.quadraticBezierTo(16, yKn - 4, 14, yKn);
    p.quadraticBezierTo(10, yKn - 4, 6, yCr + 8);
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
    p.moveTo(6, yKn + 8);
    p.quadraticBezierTo(cB + 6, yKn + 20, cB + 4, yAn - 60);
    p.quadraticBezierTo(cB + 3, yAn - 20, 4, yAn - 4);
    p.quadraticBezierTo(4, yKn + 14, 6, yKn + 8);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant SideBodyPainter old) {
    return old.metrics != metrics || old.highlightedMuscles != highlightedMuscles;
  }
}
