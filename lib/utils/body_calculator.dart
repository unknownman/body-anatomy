import '../models/body_metrics.dart';

class BodyCalculator {
  BodyCalculator._();

  static const double _refChest = 95.0;
  static const double _refWaist = 80.0;
  static const double _refHip = 95.0;
  static const double _refShoulder = 63.0;
  static const double _refWeight = 70.0;
  static const double _refHeight = 170.0;

  static double chestFactor(BodyMetrics m) =>
      (m.chestCm / _refChest).clamp(0.6, 1.5);

  static double waistFactor(BodyMetrics m) =>
      (m.waistCm / _refWaist).clamp(0.6, 1.6);

  static double hipFactor(BodyMetrics m) =>
      (m.hipCm / _refHip).clamp(0.7, 1.5);

  static double shoulderFactor(BodyMetrics m) =>
      (m.shoulderWidth / _refShoulder).clamp(0.7, 1.4);

  static double armFactor(BodyMetrics m) {
    final sizeRatio = (m.weightKg / _refWeight) * (_refHeight / m.heightCm);
    return sizeRatio.clamp(0.6, 1.5);
  }

  static double heightScale(BodyMetrics m) =>
      (m.heightCm / _refHeight).clamp(0.7, 1.3);
}
