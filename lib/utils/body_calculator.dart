import '../models/body_metrics.dart';

class BodyCalculator {
  BodyCalculator._();

  static const double _refChest = 100.0;
  static const double _refWaist = 85.0;
  static const double _refHip = 98.0;
  static const double _refCollar = 42.0;

  static double chestFactor(BodyMetrics m) =>
      (m.chestCm / _refChest).clamp(0.75, 1.35);

  static double waistFactor(BodyMetrics m) =>
      (m.waistCm / _refWaist).clamp(0.7, 1.35);

  static double hipFactor(BodyMetrics m) =>
      (m.hipCm / _refHip).clamp(0.75, 1.35);

  static double shoulderFactor(BodyMetrics m) =>
      (m.shoulderWidth / (_refCollar * 1.5)).clamp(0.8, 1.25);

  static double armFactor(BodyMetrics m) =>
      (m.bmi / 22.5).clamp(0.75, 1.3);
}
