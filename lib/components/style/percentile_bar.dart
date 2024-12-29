import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/translator.dart';

class PercentileBar extends StatefulWidget {
  final num total;

  final num at;

  const PercentileBar(
    this.at,
    this.total, {
    super.key,
  });

  @override
  State<PercentileBar> createState() => _PercentileBarState();
}

class _PercentileBarState extends State<PercentileBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _curveAnimation;
  final nf = NumberFormat.compact(locale: S.localeName);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('${nf.format(widget.at)}／${nf.format(widget.total)}'),
          ],
        ),
        AnimatedBuilder(
          animation: _curveAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _controller.value,
              valueColor: _colorAnimation,
              backgroundColor: _colorAnimation.value?.withAlpha(51),
              semanticsLabel: S.semanticsPercentileBar(_curveAnimation.value),
            );
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: widget.total == 0 ? 1.0 : widget.at / widget.total,
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final colorTween = TweenSequence([
      TweenSequenceItem(
        tween: ColorTween(
          begin: const Color(0xff7fca2b),
          end: const Color(0xff81c9de),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: const Color(0xff81c9de),
          end: const Color(0xff3d88df),
        ),
        weight: 1,
      ),
    ]);

    _colorAnimation = _controller.drive(colorTween);
    _curveAnimation = _controller.drive(CurveTween(curve: Curves.easeIn));
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.at != widget.at || oldWidget.total != widget.total) {
      _controller.animateTo(widget.total == 0 ? 1.0 : widget.at / widget.total);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
