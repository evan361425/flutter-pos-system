import 'dart:async';

import 'package:flutter/material.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReloadableCard<T> extends StatefulWidget {
  final Widget Function(BuildContext context, T metric) builder;

  final Future<T> Function() loader;

  final List<ChangeNotifier>? notifiers;

  /// Required if you want to reload the card when it's visible.
  final String id;

  final String? title;

  final bool wrappedByCard;

  final Widget? action;

  const ReloadableCard({
    super.key,
    required this.id,
    required this.builder,
    required this.loader,
    this.title,
    this.notifiers,
    this.wrappedByCard = true,
    this.action,
  });

  @override
  State<ReloadableCard<T>> createState() => _ReloadableCardState<T>();
}

class _ReloadableCardState<T> extends State<ReloadableCard<T>> with AutomaticKeepAliveClientMixin {
  /// Error message when loading failed
  String? error;

  /// Data loaded from loader
  T? data;

  /// Whether the card is reloading
  bool reloadable = false;

  /// Last built target, used to prevent rebuild when reloading
  Widget? lastBuiltTarget;

  Future<T>? lastFuture;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(children: [
      if (widget.title != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
          child: buildTitle(),
        ),
      Stack(children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Breakpoint.medium.max),
          child: SizedBox(
            width: double.infinity,
            child: buildWrapper(buildTarget()),
          ),
        ),
        if (reloadable) buildReloading(),
      ]),
    ]);
  }

  @override
  void didUpdateWidget(covariant ReloadableCard<T> oldWidget) {
    // after reorder, the widget will be updated
    if (oldWidget.id != widget.id) {
      data = null;
      reloadable = true;
      reload();
      updateKeepAlive();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  bool get wantKeepAlive => data != null;

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
        child: Card(
          margin: const EdgeInsets.only(top: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8.0),
      child,
    ]);
  }

  Widget buildTitle() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        widget.title!,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
        overflow: TextOverflow.ellipsis,
      ),
      if (widget.action != null) widget.action!,
    ]);
  }

  Widget buildReloading() {
    return Positioned.fill(
      child: VisibilityDetector(
        key: Key('anal_card.${widget.id}'),
        onVisibilityChanged: (info) async {
          // if partially visible
          if (info.visibleFraction > 0.1) {
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

    load().then((value) {
      if (mounted) {
        setState(() => data = value);
      }
    });
    widget.notifiers?.forEach((e) {
      e.addListener(handleUpdate);
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.notifiers?.forEach((e) {
      e.removeListener(handleUpdate);
    });
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
      lastBuiltTarget = null;
      final inline = await load();

      setState(() {
        reloadable = false;
        lastBuiltTarget = null;
        data = inline;
      });
    }
  }

  void handleUpdate() {
    if (!reloadable) {
      setState(() {
        reloadable = true;
      });
    }
  }
}
