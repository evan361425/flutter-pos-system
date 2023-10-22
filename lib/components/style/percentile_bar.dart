import 'package:flutter/material.dart';

class PercentileBar extends StatefulWidget {
  final num total;

  final num at;

  const PercentileBar(
    this.at,
    this.total, {
    Key? key,
  }) : super(key: key);

  @override
  State<PercentileBar> createState() => _PercentileBarState();
}

class _PercentileBarState extends State<PercentileBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _curveAnimation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(_toString(widget.at)),
            const Text('／'),
            Text(_toString(widget.total)),
          ],
        ),
        AnimatedBuilder(
          animation: _curveAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _controller.value,
              valueColor: _colorAnimation,
              backgroundColor: _colorAnimation.value?.withOpacity(0.2),
              semanticsLabel: '目前佔總數的 ${_curveAnimation.value}',
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
          begin: const Color(0xffff834c),
          end: const Color(0xffeebc01),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: const Color(0xff7fca2b),
          end: const Color(0xff81c9de),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: const Color(0xff3d88df),
          end: const Color(0xff8b6abc),
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
    if (oldWidget.at != widget.at) {
      _controller.animateTo(widget.total == 0 ? 1.0 : widget.at / widget.total);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
