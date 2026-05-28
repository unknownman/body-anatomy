enum Gender { male, female }

class BodyMetrics {
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final double chestCm;
  final double waistCm;
  final double highHipCm;
  final double hipCm;
  final double collarCm;
  final double frontSleeveCm;
  final double inseamCm;

  const BodyMetrics({
    this.gender = Gender.male,
    this.heightCm = 170.0,
    this.weightKg = 70.0,
    this.chestCm = 95.0,
    this.waistCm = 80.0,
    this.highHipCm = 90.0,
    this.hipCm = 95.0,
    this.collarCm = 42.0,
    this.frontSleeveCm = 60.0,
    this.inseamCm = 78.0,
  });

  double get shoulderWidth => collarCm * 1.5;

  double get waistToHipRatio => hipCm > 0 ? waistCm / hipCm : 0;

  double get bmi {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }
}
