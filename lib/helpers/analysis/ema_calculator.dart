class EMACalculator {
  final double weightFactor;

  final int length;

  const EMACalculator(this.length) : weightFactor = 2 / (length + 1);

  double calculate(Iterable<num> data) {
    double carry = 0;

    for (final value in data) {
      carry = feed(value, carry);
    }

    return carry;
  }

  double feed(num value, double carry) {
    if (carry == 0) {
      return value.toDouble();
    }

    return value * weightFactor + carry * (1 - weightFactor);
  }
}
