import 'package:flutter/material.dart';

class FadeInTitleScaffold extends StatefulWidget {
  FadeInTitleScaffold({
    Key key,
    this.leading,
    this.trailing,
    this.title,
    this.body,
    this.floatingActionButton,
  }) : super(key: key);

  final Widget leading;
  final Widget trailing;
  final String title;
  final Widget body;
  final Widget floatingActionButton;

  @override
  _FadeInTitleScaffoldState createState() => _FadeInTitleScaffoldState();
}

class _FadeInTitleScaffoldState extends State<FadeInTitleScaffold> {
  double _opacity = 0;

  bool _scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.axis == Axis.vertical) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.leading,
        actions: <Widget>[widget.trailing],
        title: AnimatedOpacity(
          duration: Duration(seconds: 0),
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
}
