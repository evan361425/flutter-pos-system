import 'package:flutter/material.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/helpers/logger.dart';

class AnalysisCard<T> extends StatefulWidget {
  final Widget Function(BuildContext context, T metric) builder;

  final Future<T> Function() loader;

  const AnalysisCard({
    Key? key,
    required this.builder,
    required this.loader,
  }) : super(key: key);

  @override
  State<AnalysisCard<T>> createState() => _AnalysisCardState<T>();
}

class _AnalysisCardState<T> extends State<AnalysisCard<T>> {
  T? metric;
  String? error;

  @override
  Widget build(BuildContext context) {
    final m = metric;
    final e = error;
    final child = e != null
        ? Center(child: Text(e))
        : m == null
            ? const CircularLoading()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget.builder(context, m),
              );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: SizedBox(
        width: double.infinity,
        child: AspectRatio(
          aspectRatio: 1.6,
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget
        .loader()
        .then((value) => setState(() => metric = value))
        .onError((e, stack) {
      Log.err(e ?? 'unknown', 'load_metrics', stack);
      setState(() => error = e?.toString() ?? 'unknown');
    });
  }
}
