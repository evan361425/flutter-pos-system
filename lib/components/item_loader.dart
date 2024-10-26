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

  final Widget? leading;

  const ItemLoader({
    super.key,
    required this.builder,
    required this.loader,
    required this.prototypeItem,
    this.itemLoadSize = 10,
    required this.metricsLoader,
    required this.metricsBuilder,
    this.notifier,
    this.emptyChild = const SizedBox.shrink(),
    this.leading,
    this.padding,
  });

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

    return ListView.builder(
      padding: widget.padding,
      key: const Key('item_loader'),
      prototypeItem: widget.leading == null ? widget.prototypeItem : null,
      itemBuilder: (context, index) {
        // leading is always the first item
        if (widget.leading != null) {
          if (index == 0) {
            return widget.leading!;
          }
          index--;
        }

        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: widget.metricsBuilder(metrics as U),
          );
        }

        index--;
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
    );
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
      showSnackbarWhenFutureError(
        widget.loader(items.length).then((data) {
          setState(() {
            isFinish = data.length != widget.itemLoadSize;
            items.addAll(data);
          });
        }),
        'item_loader_failed',
        context: context,
      );
    }
  }

  void loadMetrics() {
    if (metrics == null) {
      showSnackbarWhenFutureError(
        widget.metricsLoader().then((data) {
          setState(() {
            metrics = data;
          });
        }),
        'metrics_loader_failed',
        context: context,
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
