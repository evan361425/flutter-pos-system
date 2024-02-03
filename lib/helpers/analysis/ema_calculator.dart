class EMACalculator {
  double result = 0;

  final double weightFactor;

  EMACalculator(int length) : weightFactor = 2 / (length + 1);

  double calculate(Iterable<num> data) {
    for (final value in data) {
      feed(value);
    }

    return result;
  }

  void feed(num value) {
    if (result == 0) {
      result = value.toDouble();
      return;
    }

    result = value * weightFactor + result * (1 - weightFactor);
  }
}
