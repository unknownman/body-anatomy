import 'package:flutter/material.dart';
import '../models/body_metrics.dart';
import '../painters/front_body_painter.dart';
import '../painters/side_body_painter.dart';
import '../painters/back_body_painter.dart';

class BodyAnatomyViewer extends StatelessWidget {
  final BodyMetrics metrics;
  final Map<String, Color> highlightedMuscles;
  final double viewHeight;

  const BodyAnatomyViewer({
    super.key,
    required this.metrics,
    this.highlightedMuscles = const {},
    this.viewHeight = 360,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: viewHeight,
      child: Row(
        children: [
          Expanded(
            child: _BodyView(
              label: 'Front',
              painter: FrontBodyPainter(
                metrics: metrics,
                highlightedMuscles: highlightedMuscles,
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _BodyView(
              label: 'Side',
              painter: SideBodyPainter(
                metrics: metrics,
                highlightedMuscles: highlightedMuscles,
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _BodyView(
              label: 'Back',
              painter: BackBodyPainter(
                metrics: metrics,
                highlightedMuscles: highlightedMuscles,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyView extends StatelessWidget {
  final String label;
  final CustomPainter painter;

  const _BodyView({
    required this.label,
    required this.painter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: CustomPaint(
              painter: painter,
              size: Size.infinite,
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
