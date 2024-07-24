import 'dart:io' show Platform;

import 'package:flutter/material.dart';

/// Try handle tricky issue: https://github.com/flutter/flutter/issues/140869
/// Solution from:
/// https://github.com/flutter/flutter/issues/140869#issuecomment-2247181468
class RouterPopScope extends StatefulWidget {
  final Widget child;

  final PopInvokedCallback? onPopInvoked;

  final bool canPop;

  const RouterPopScope({
    super.key,
    required this.child,
    this.canPop = true,
    this.onPopInvoked,
  });

  @override
  State<RouterPopScope> createState() => _RouterPopScopeState();
}

class _RouterPopScopeState extends State<RouterPopScope> {
  final bool _enable = Platform.isAndroid;
  ModalRoute? _route;
  BackButtonDispatcher? _parentBackBtnDispatcher;
  ChildBackButtonDispatcher? _backBtnDispatcher;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context);
    _updateBackButtonDispatcher();
  }

  @override
  void activate() {
    super.activate();
    _updateBackButtonDispatcher();
  }

  @override
  void deactivate() {
    super.deactivate();
    _disposeBackBtnDispatcher();
  }

  @override
  void dispose() {
    _disposeBackBtnDispatcher();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.canPop,
      onPopInvoked: widget.onPopInvoked,
      child: widget.child,
    );
  }

  void _updateBackButtonDispatcher() {
    if (!_enable) return;

    var dispatcher = Router.maybeOf(context)?.backButtonDispatcher;
    if (dispatcher != _parentBackBtnDispatcher) {
      _disposeBackBtnDispatcher();
      _parentBackBtnDispatcher = dispatcher;
      if (dispatcher is BackButtonDispatcher && dispatcher is! ChildBackButtonDispatcher) {
        dispatcher = dispatcher.createChildBackButtonDispatcher();
      }
      _backBtnDispatcher = dispatcher as ChildBackButtonDispatcher;
    }
    _backBtnDispatcher?.removeCallback(_handleBackButton);
    _backBtnDispatcher?.addCallback(_handleBackButton);
    _backBtnDispatcher?.takePriority();
  }

  void _disposeBackBtnDispatcher() {
    _backBtnDispatcher?.removeCallback(_handleBackButton);
    if (_backBtnDispatcher is ChildBackButtonDispatcher) {
      final child = _backBtnDispatcher as ChildBackButtonDispatcher;
      _parentBackBtnDispatcher?.forget(child);
    }
    _backBtnDispatcher = null;
    _parentBackBtnDispatcher = null;
  }

  Future<bool> _handleBackButton() async {
    if (_route != null && _route!.isFirst && _route!.isCurrent) {
      widget.onPopInvoked?.call(widget.canPop);
    }
    return widget.canPop;
  }
}
