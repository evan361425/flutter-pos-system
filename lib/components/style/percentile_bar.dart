import 'package:flutter/material.dart';

class PercentileBar extends StatelessWidget {
  final num totalCount;

  final num currentCount;

  const PercentileBar(this.currentCount, this.totalCount, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentile = totalCount == 0 ? 1.0 : currentCount / totalCount;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(_toString(currentCount)),
            const Text('／'),
            Text(_toString(totalCount)),
          ],
        ),
        LinearProgressIndicator(
          value: percentile,
          semanticsLabel: '庫存數量的比例',
        ),
      ],
    );
  }
}

/// Maximum 4 characters
String _toString(num v) {
  if (v is int || v == v.ceil()) {
    if (v < 10000) {
      return v.toStringAsFixed(0);
    }
  } else if (v < 1000) {
    return v.toStringAsFixed(1);
  }
  return v.toStringAsExponential(1);
}
