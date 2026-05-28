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
    final tX = 18.0 * _af.clamp(0.9, 1.3);

    final p = Path();

    // ── RIGHT HALF ──
    p.moveTo(0, 10);

    p.cubicTo(17, 10, 18, 28, 16, 44);
    p.cubicTo(14, 52, sX * 0.5, 58, sX, 62);

    p.cubicTo(sX + 6, 64, sX + 10, 68, sX + 8, 72);

    final aOut = sX + aW + 2;
    p.cubicTo(aOut, 76, aOut + 2, 108, aOut, 118);
    p.cubicTo(aOut - 1, 148, aOut - 2, 156, aOut - 3, 170);
    p.lineTo(sX + 4, 170);

    p.cubicTo(sX + 3, 156, sX + 2, 148, sX + 2, 118);
    p.cubicTo(sX + 2, 108, sX + 4, 82, sX + 4, 82);

    p.cubicTo(cX + 4, 82, cX + 6, 95, cX + 4, 100);
    p.cubicTo(cX + 2, 110, wX + 4, 120, wX + 2, 125);
    p.cubicTo(wX, 130, hX + 2, 140, hX + 4, 148);
    p.cubicTo(hX + 3, 155, hX, 162, 0, 168);

    p.cubicTo(6, 172, tX * 0.6, 240, tX * 0.7, 252);
    p.cubicTo(tX * 0.6, 264, tX * 0.4, 348, tX * 0.35, 358);
    p.cubicTo(tX * 0.3, 364, tX * 0.25, 370, tX * 0.25, 372);

    final fOut = tX * 1.2;
    p.lineTo(fOut + 2, 372);

    p.cubicTo(fOut + 3, 370, fOut + 2, 362, fOut, 358);
    p.cubicTo(fOut - 1, 264, fOut + 1, 250, fOut, 252);
    p.cubicTo(fOut - 1, 160, hX + 2, 158, hX + 2, 152);
    p.cubicTo(hX + 2, 148, hX + 4, 152, hX + 4, 148);

    // ── LEFT HALF (mirrored) ──
    final m = -1.0;

    p.cubicTo(hX * m + 4, 152, hX * m + 2, 148, hX * m + 2, 152);
    p.cubicTo(hX * m + 2, 158, fOut * m, 160, fOut * m, 252);
    p.cubicTo(fOut * m + 1, 250, fOut * m - 1, 264, fOut * m, 358);
    p.cubicTo(fOut * m + 2, 362, fOut * m + 3, 370, fOut * m + 2, 372);

    p.lineTo(tX * 0.25 * m, 372);

    p.cubicTo(tX * 0.25 * m, 370, tX * 0.3 * m, 364, tX * 0.35 * m, 358);
    p.cubicTo(tX * 0.4 * m, 348, tX * 0.6 * m, 264, tX * 0.7 * m, 252);
    p.cubicTo(tX * 0.6 * m, 240, 6 * m, 172, 0, 168);

    p.cubicTo(hX * m, 162, hX * m + 3, 155, hX * m + 4, 148);
    p.cubicTo(hX * m + 2, 140, wX * m, 130, wX * m + 2, 125);
    p.cubicTo(wX * m + 4, 120, cX * m + 2, 110, cX * m + 4, 100);
    p.cubicTo(cX * m + 6, 95, cX * m + 4, 82, sX * m + 4, 82);

    p.cubicTo(sX * m + 4, 82, sX * m + 2, 108, sX * m + 2, 118);
    p.cubicTo(sX * m + 2, 148, sX * m + 3, 156, sX * m + 4, 170);
    p.lineTo(aOut * m - 3, 170);

    p.cubicTo(aOut * m + 1, 156, aOut * m - 1, 148, aOut * m, 118);
    p.cubicTo(aOut * m + 2, 108, aOut * m, 76, sX * m + 8, 72);

    p.cubicTo(sX * m + 10, 68, sX * m + 6, 64, sX * m, 62);
    p.cubicTo(sX * 0.5 * m, 58, 14 * m, 52, 0, 44);
    p.cubicTo(0, 44, 0, 24, 0, 10);

    p.close();
    canvas.drawPath(p, paint);
  }

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
    final sX = 38.0 * _sf;
    final aW = 9.0 * _af;
    final s = side.toDouble();
    final p = Path();
    p.moveTo(sX * s, 62);
    p.cubicTo((sX + aW + 2) * s, 66, (sX + aW + 2) * s, 100, (sX + aW - 2) * s, 108);
    p.cubicTo((sX + 2) * s, 112, (sX + 2) * s, 82, sX * s * 0.7, 82);
    p.cubicTo(sX * s * 0.5, 78, sX * s * 0.3, 66, sX * s, 62);
    p.close();
    return p;
  }

  Path _buildLatissimus(int side) {
    final cX = 28.0 * _cf;
    final wX = 18.0 * _wf;
    final s = side.toDouble();
    final p = Path();
    p.moveTo(cX * 0.4 * s, 88);
    p.cubicTo(cX * s, 86, cX * s + 2, 100, cX * s, 106);
    p.cubicTo(cX * s - 1, 114, wX * s + 2, 120, wX * s - 1, 122);
    p.cubicTo(wX * s - 3, 118, cX * 0.3 * s, 110, cX * 0.3 * s, 100);
    p.close();
    return p;
  }

  Path _buildGlute(int side) {
    final s = side.toDouble();
    final hX = 26.0 * _hf;
    final p = Path();
    p.moveTo(4, 160);
    p.cubicTo(hX * 0.7 * s, 156, hX * s, 150, hX * s, 156);
    p.cubicTo(hX * s, 162, hX * s - 2, 168, hX * 0.5 * s, 170);
    p.cubicTo(hX * 0.2 * s, 172, 2, 168, 2, 164);
    p.close();
    return p;
  }

  Path _buildQuadriceps(int side) {
    final s = side.toDouble();
    final tX = 18.0 * _af.clamp(0.9, 1.3);
    final p = Path();
    p.moveTo(4, 170);
    p.cubicTo(tX * s * 0.8, 172, tX * s, 186, tX * s, 244);
    p.cubicTo(tX * s * 0.7, 250, tX * 0.4 * s, 254, 4, 252);
    p.cubicTo(2, 250, 2, 172, 4, 170);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant BackBodyPainter old) {
    return old.metrics != metrics || old.highlightedMuscles != highlightedMuscles;
  }
}
