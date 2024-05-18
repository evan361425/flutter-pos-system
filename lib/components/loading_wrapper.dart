import 'package:flutter/material.dart';

class LoadingWrapper extends StatefulWidget {
  final Widget child;

  final bool isLoading;

  const LoadingWrapper({
    super.key,
    required this.child,
    this.isLoading = false,
  });

  @override
  State<LoadingWrapper> createState() => LoadingWrapperState();
}

class LoadingWrapperState extends State<LoadingWrapper> {
  late bool _isLoading;

  String? _status;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      widget.child,
      if (_isLoading)
        Positioned.fill(
          child: Container(
            color: Theme.of(context).colorScheme.surface.withAlpha(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                if (_status != null)
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.headlineSmall!,
                    child: Text(_status!),
                  ),
              ],
            ),
          ),
        ),
    ]);
  }

  void startLoading([String? status]) {
    setState(() {
      _status = status;
      _isLoading = true;
    });
  }

  void setStatus(String? status) {
    setState(() {
      _status = status;
    });
  }

  void finishLoading() {
    setState(() {
      _status = null;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading;
  }
}
