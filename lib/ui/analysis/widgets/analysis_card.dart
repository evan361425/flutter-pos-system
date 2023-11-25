import 'dart:async';

import 'package:flutter/material.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnalysisCard<T> extends StatefulWidget {
  final Widget Function(BuildContext context, T metric) builder;

  final Future<T> Function() loader;

  final ChangeNotifier? notifier;

  final String id;

  const AnalysisCard({
    Key? key,
    required this.id,
    required this.builder,
    required this.loader,
    this.notifier,
  }) : super(key: key);

  @override
  State<AnalysisCard<T>> createState() => _AnalysisCardState<T>();
}

class _AnalysisCardState<T> extends State<AnalysisCard<T>> {
  T? metric;
  String? error;
  bool shouldReload = false;

  @override
  Widget build(BuildContext context) {
    final m = metric;
    final e = error;
    final child = e != null
        ? Center(child: Text(e))
        : m == null
            ? const CircularLoading()
            : widget.builder(context, m);

    final card = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: SizedBox(
        width: double.infinity,
        child: AspectRatio(
          aspectRatio: 1.6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).cardColor),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );

    if (!shouldReload) {
      return card;
    }

    return Stack(children: [
      card,
      Positioned.fill(
        child: VisibilityDetector(
          key: Key('anal_card.${widget.id}'),
          onVisibilityChanged: (info) async {
            if (info.visibleFraction > 0) {
              final m = await load();
              setState(() {
                metric = m;
                shouldReload = false;
              });
            }
          },
          child: const ColoredBox(
            color: Colors.black12,
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ),
      )
    ]);
  }

  @override
  void initState() {
    super.initState();

    load().then((value) => setState(() => metric = value));
    widget.notifier?.addListener(reload);
  }

  @override
  void dispose() {
    super.dispose();
    widget.notifier?.removeListener(reload);
  }

  Future<T?> load() {
    return widget.loader().onError((e, stack) {
      Log.err(e ?? 'unknown', 'load_metrics', stack);
      setState(() => error = e?.toString() ?? 'unknown');
      return Future.value();
    });
  }

  void reload() {
    if (!shouldReload) {
      setState(() {
        shouldReload = true;
      });
    }
  }
}
