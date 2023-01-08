import 'dart:math';

import 'package:flutter/material.dart';

class PercentileBar extends StatelessWidget {
  final num totalCount;

  final num currentCount;

  const PercentileBar(this.currentCount, this.totalCount, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.primaryColor;
    final percentile = totalCount == 0 ? 1 : min(1, currentCount / totalCount);
    final height = (theme.textTheme.bodyMedium?.fontSize ?? 14) * 1.5;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(8.0),
        color: color.withAlpha(128),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              height: constraints.maxHeight,
              width: constraints.maxWidth * percentile,
              color: color,
            );
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(_toString(totalCount)),
          ),
        ),
        Align(
          child: Text(_toString(currentCount)),
        ),
      ]),
    );
  }
}

String _toString(num v) {
  if (v is int || v == v.ceilToDouble()) {
    if (v < 10000) {
      return v.toStringAsFixed(0);
    }
  } else if (v < 1000) {
    return v.toStringAsFixed(1);
  }
  return v.toStringAsExponential(1);
}
