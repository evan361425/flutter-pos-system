import 'package:flutter/material.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/snackbar.dart';

class ItemLoader<T, U> extends StatefulWidget {
  final Widget Function(T) builder;

  final Future<Iterable<T>> Function() loader;

  final Future<U> Function() metricsLoader;

  final Widget Function(U) metricsBuilder;

  final Widget prototypeItem;

  final int itemLoadSize;

  final Widget emptyChild;

  const ItemLoader({
    Key? key,
    required this.builder,
    required this.loader,
    required this.prototypeItem,
    this.itemLoadSize = 10,
    required this.metricsLoader,
    required this.metricsBuilder,
    this.emptyChild = const SizedBox.shrink(),
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
      widget.metricsBuilder(metrics as U),
      const Divider(),
      Expanded(
        child: ListView.builder(
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

            return widget.builder(items[index]);
          },
        ),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    loadData();
    loadMetrics();
  }

  int get length => items.length;

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

  void loadData() {
    if (!isFinish) {
      showSnackbarWhenFailed(
        widget.loader().then((data) {
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
}
