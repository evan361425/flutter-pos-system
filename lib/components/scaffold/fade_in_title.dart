import 'package:flutter/material.dart';

class FadeInTitleScaffold extends StatefulWidget {
  FadeInTitleScaffold({
    Key key,
    this.appBarLeading,
    this.appBarActions,
    this.appBarTitle,
    this.body,
    this.floatingActionButton,
  }) : super(key: key);

  final Widget appBarLeading;
  final List<Widget> appBarActions;
  final String appBarTitle;
  final Widget body;
  final Widget floatingActionButton;

  @override
  _FadeInTitleScaffoldState createState() => _FadeInTitleScaffoldState();
}

class _FadeInTitleScaffoldState extends State<FadeInTitleScaffold> {
  double _opacity = 0;

  bool _scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.axis == Axis.vertical) {
      setState(() {
        _opacity = scrollInfo.metrics.pixels >= 40
            ? 1
            : scrollInfo.metrics.pixels / 40;
      });
    }
    // continue bubbleing
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.appBarLeading,
        actions: widget.appBarActions,
        title: AnimatedOpacity(
          duration: Duration(seconds: 0),
          opacity: _opacity,
          child: Text(widget.appBarTitle),
        ),
      ),
      floatingActionButton: widget.floatingActionButton,
      body: NotificationListener<ScrollNotification>(
        onNotification: _scrollListener,
        child: SingleChildScrollView(
          child: widget.body,
        ),
      ),
    );
  }
}
