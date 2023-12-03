import 'package:flutter/material.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/snackbar.dart';

class ItemLoader<T, U> extends StatefulWidget {
  final Widget Function(BuildContext, T) builder;

  final Future<Iterable<T>> Function(int offset) loader;

  final Widget prototypeItem;

  final int itemLoadSize;

  final Future<U> Function() metricsLoader;

  final Widget Function(U) metricsBuilder;

  final ChangeNotifier? notifier;

  final Widget emptyChild;

  final EdgeInsets? padding;

  const ItemLoader({
    Key? key,
    required this.builder,
    required this.loader,
    required this.prototypeItem,
    this.itemLoadSize = 10,
    required this.metricsLoader,
    required this.metricsBuilder,
    this.notifier,
    this.emptyChild = const SizedBox.shrink(),
    this.padding,
  }) : super(key: key);

  @override
  State<ItemLoader<T, U>> createState() => ItemLoaderState<T, U>();
}

class ItemLoaderState<T, U> extends State<ItemLoader<T, U>> {
  final items = <T>[];

  U? metrics;

  bool isFinish = false;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty || metrics == null) {
      return isFinish ? widget.emptyChild : const CircularLoading();
    }

    return Column(children: [
      const SizedBox(height: 4.0),
      widget.metricsBuilder(metrics as U),
      const SizedBox(height: 4.0),
      Expanded(
        child: ListView.builder(
          padding: widget.padding,
          key: const Key('item_loader'),
          prototypeItem: widget.prototypeItem,
          itemBuilder: (context, index) {
            // loading over the size
            if (items.length == index) {
              if (isFinish) {
                return null;
              }
              // fetch more!
              loadData();
              return const CircularLoading();
            } else if (items.length < index) {
              // wait for fetching, this condition is only allowed when we are fetching more
              return null;
            }

            return widget.builder(context, items[index]);
          },
        ),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    widget.notifier?.addListener(reset);
    loadData();
    loadMetrics();
  }

  @override
  void dispose() {
    widget.notifier?.removeListener(reset);
    super.dispose();
  }

  void loadData() {
    if (!isFinish) {
      showSnackbarWhenFailed(
        widget.loader(items.length).then((data) {
          setState(() {
            isFinish = data.length != widget.itemLoadSize;
            items.addAll(data);
          });
        }),
        context,
        'item_loader_failed',
      );
    }
  }

  void loadMetrics() {
    if (metrics == null) {
      showSnackbarWhenFailed(
        widget.metricsLoader().then((data) {
          setState(() {
            metrics = data;
          });
        }),
        context,
        'metrics_loader_failed',
      );
    }
  }

  void reset() {
    if (mounted) {
      setState(() {
        items.clear();
        metrics = null;
        isFinish = false;
        loadData();
        loadMetrics();
      });
    }
  }
}
