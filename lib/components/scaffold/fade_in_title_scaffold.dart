import 'package:flutter/material.dart';

class FadeInTitleScaffold extends StatefulWidget {
  final Widget? leading;
  final Widget? trailing;
  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  const FadeInTitleScaffold({
    Key? key,
    this.leading,
    this.trailing,
    required this.title,
    required this.body,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  _FadeInTitleScaffoldState createState() => _FadeInTitleScaffoldState();
}

class _FadeInTitleScaffoldState extends State<FadeInTitleScaffold> {
  double _opacity = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.leading,
        actions: widget.trailing == null ? null : <Widget>[widget.trailing!],
        title: AnimatedOpacity(
          duration: const Duration(seconds: 0),
          opacity: _opacity,
          child: Text(widget.title),
        ),
      ),
      floatingActionButton: widget.floatingActionButton,
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: _scrollListener,
          child: SingleChildScrollView(
            child: widget.body,
          ),
        ),
      ),
    );
  }

  bool _scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.axis == Axis.vertical) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        setState(() {
          _opacity = scrollInfo.metrics.pixels >= 40
              ? 1
              : scrollInfo.metrics.pixels / 40;
        });
      });
    }
    // continue bubbleing
    return false;
  }
}
