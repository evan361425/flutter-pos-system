import 'dart:async';

import 'package:flutter/material.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReloadableCard<T> extends StatefulWidget {
  final Widget Function(BuildContext context, T metric) builder;

  final Future<T> Function() loader;

  final ChangeNotifier? notifier;

  /// Required if you want to reload the card when it's visible.
  final String? id;

  final String? title;

  final bool wrappedByCard;

  const ReloadableCard({
    Key? key,
    this.id,
    required this.builder,
    required this.loader,
    this.title,
    this.notifier,
    this.wrappedByCard = true,
  }) : super(key: key);

  @override
  State<ReloadableCard<T>> createState() => _ReloadableCardState<T>();
}

class _ReloadableCardState<T> extends State<ReloadableCard<T>> {
  /// Error message when loading failed
  String? error;

  /// Data loaded from loader
  T? data;

  /// Whether the card is reloading
  bool reloadable = false;

  /// Last built target, used to prevent rebuild when reloading
  Widget? lastBuiltTarget;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 432),
        child: SizedBox(
          width: double.infinity,
          child: buildWrapper(buildTarget()),
        ),
      ),
      if (reloadable) buildReloading(),
    ]);
  }

  /// Main content of the card
  Widget buildTarget() {
    if (error != null) {
      return Center(child: Text(error!));
    }

    if (data == null) {
      return const CircularLoading();
    }

    // when reloading, only show the circular loading indicator and
    // should not rebuild the target
    if (reloadable && lastBuiltTarget != null) {
      return lastBuiltTarget!;
    }

    return lastBuiltTarget = widget.builder(context, data as T);
  }

  /// Wrap the target with card or not
  Widget buildWrapper(Widget child) {
    if (widget.wrappedByCard) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) buildTitle(),
            Card(
              margin: const EdgeInsets.only(top: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: child,
              ),
            ),
          ],
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8.0),
      child,
    ]);
  }

  Widget buildTitle() {
    return Text(
      widget.title!,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget buildReloading() {
    return Positioned.fill(
      child: VisibilityDetector(
        key: Key('anal_card.${widget.id}'),
        onVisibilityChanged: (info) async {
          // if partially visible
          if (info.visibleFraction > 0) {
            await reload();
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
    );
  }

  @override
  void initState() {
    super.initState();

    load().then((value) => setState(() => data = value));
    widget.notifier?.addListener(changeListener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.notifier?.removeListener(changeListener);
  }

  Future<T?> load() {
    return widget.loader().onError((e, stack) {
      Log.err(e ?? 'unknown', 'load_metrics', stack);
      setState(() => error = e?.toString() ?? 'unknown');
      return Future.value(null);
    });
  }

  Future<void> reload() async {
    // only reload when data changed
    if (reloadable) {
      reloadable = false;
      lastBuiltTarget = null;
      final inline = await load();

      setState(() {
        data = inline;
      });
    }
  }

  void changeListener() {
    if (!reloadable) {
      setState(() {
        reloadable = true;
      });
    }
  }
}
