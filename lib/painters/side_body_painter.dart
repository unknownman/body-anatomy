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
      (size.width - _vw * sc) / 2,
      (size.height - _vh * sc) / 2,
    );
    canvas.scale(sc, sc);

    _drawOutline(canvas);
    _drawMuscles(canvas);

    canvas.restore();
  }

  void _drawOutline(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cX = 28.0 * _cf;
    final wX = 18.0 * _wf;
    final hX = 26.0 * _hf;
    final sX = 38.0 * _sf;
    final aW = 9.0 * _af;

    final p = Path();

    p.moveTo(0, 10);

    p.cubicTo(30, 10, 44, 22, 52, 34);
    p.cubicTo(56, 40, 56, 46, 52, 52);

    p.cubicTo(48, 56, 42, 60, 38, 62);

    final chestP = 40 + cX * 0.2;
    p.cubicTo(36, 64, chestP, 74, chestP, 82);
    p.cubicTo(chestP, 90, 34 + wX * 0.1, 114, 34 + wX * 0.1, 122);
    p.cubicTo(34 + wX * 0.1, 130, 32 + hX * 0.1, 150, 32 + hX * 0.1, 155);
    p.cubicTo(36, 270, 32, 316, 30, 358);
    p.cubicTo(28, 364, 30, 368, 44, 374);

    p.cubicTo(50, 376, 52, 378, 48, 380);
    p.cubicTo(36, 382, 20, 378, 4, 376);

    p.cubicTo(-6, 374, -10, 370, -8, 358);
    p.cubicTo(-6, 348, -12, 316, -16, 310);
    p.cubicTo(-22, 302, -22, 270, -18, 260);
    p.cubicTo(-14, 250, -12, 206, -16, 200);

    final gluteX = -36 * _hf;
    p.cubicTo(-18, 192, gluteX, 164, gluteX, 158);
    p.cubicTo(gluteX - 2, 150, gluteX + 2, 144, -28, 140);

    p.cubicTo(-24, 136, -20, 114, -22, 110);
    p.cubicTo(-26, 104, -24, 80, -30, 76);
    p.cubicTo(-34, 72, -28, 64, -24, 60);

    p.cubicTo(-20, 54, -22, 44, -18, 34);
    p.cubicTo(-14, 24, -6, 12, 0, 10);

    p.close();
    canvas.drawPath(p, paint);

    _drawSideArm(canvas, sX, aW);
  }

  void _drawSideArm(Canvas canvas, double sX, double aW) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final armW = aW * 0.7;
    final shX = sX * 0.7;

    final p = Path();
    p.moveTo(shX, 66);
    p.cubicTo(shX + armW, 70, shX + armW + 2, 100, shX + armW, 116);
    p.cubicTo(shX + armW - 1, 124, shX, 140, shX - 2, 156);
    p.cubicTo(shX - 4, 162, shX + 2, 166, shX + 4, 162);
    p.cubicTo(shX + 6, 154, shX + 8, 132, shX + 6, 118);
    p.cubicTo(shX + 4, 104, shX + 2, 70, shX, 66);
    p.close();
    canvas.drawPath(p, paint);
  }

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
    final sX = 38.0 * _sf;
    final aW = 9.0 * _af;
    final p = Path();
    p.moveTo(24, 64);
    p.cubicTo(sX * 0.8 + aW * 0.5, sX * 0.1 + 60, sX * 0.8 + aW * 0.5, 92, sX * 0.7 + aW * 0.3, 100);
    p.cubicTo(sX * 0.5, 102, 22, 92, 24, 64);
    p.close();
    return p;
  }

  Path _buildPectoral() {
    final cX = 28.0 * _cf;
    final p = Path();
    p.moveTo(30, 78);
    p.cubicTo(38 + cX * 0.15, 76, 42 + cX * 0.15, 84, 38 + cX * 0.1, 90);
    p.cubicTo(34, 92, 26, 86, 30, 78);
    p.close();
    return p;
  }

  Path _buildAbdominals() {
    final wX = 18.0 * _wf;
    final p = Path();
    p.moveTo(26, 108);
    p.cubicTo(30 + wX * 0.1, 110, 32 + wX * 0.1, 126, 28 + wX * 0.08, 136);
    p.cubicTo(24, 134, 22, 118, 26, 108);
    p.close();
    return p;
  }

  Path _buildGlute() {
    final hX = 26.0 * _hf;
    final p = Path();
    final gX = -36 * hX / 26;
    p.moveTo(-14, 148);
    p.cubicTo(gX * 0.7, 144, gX, 152, gX * 0.9, 158);
    p.cubicTo(gX * 0.7, 164, -16, 168, -10, 162);
    p.close();
    return p;
  }

  Path _buildQuadriceps() {
    final p = Path();
    p.moveTo(26, 164);
    p.cubicTo(34, 168, 36, 206, 34, 240);
    p.cubicTo(28, 244, 22, 216, 22, 180);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant SideBodyPainter old) {
    return old.metrics != metrics || old.highlightedMuscles != highlightedMuscles;
  }
}
