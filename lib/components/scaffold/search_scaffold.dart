import 'package:flutter/material.dart';
import 'package:possystem/components/search_bar.dart';
import 'package:possystem/constants/icons.dart';

class SearchScaffold<T> extends StatefulWidget {
  const SearchScaffold({
    Key key,
    @required this.onChanged,
    @required this.itemBuilder,
    @required this.emptyBuilder,
    @required this.initialBuilder,
    this.heroTag,
    this.text = '',
    this.hintText = '',
    this.labelText = '',
    this.helperText = '',
    this.maxLength = 30,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  final Future<List<T>> Function(String) onChanged;
  final String heroTag;
  final int maxLength;
  final String text;
  final String helperText;
  final String hintText;
  final String labelText;
  final TextCapitalization textCapitalization;
  final Widget Function(BuildContext) initialBuilder;
  final Widget Function(BuildContext, T item) itemBuilder;
  final Widget Function(BuildContext, String text) emptyBuilder;

  @override
  SearchScaffoldState<T> createState() => SearchScaffoldState<T>();
}

class SearchScaffoldState<T> extends State<SearchScaffold> {
  final GlobalKey<SearchBarState> searchBar = GlobalKey<SearchBarState>();

  bool isSearching = true;
  bool get isNotEmpty => list.isNotEmpty;
  int get count => list.length;
  List<T> list = [];

  void setSearchKeyword(String keyword) {
    searchBar.currentState.text = keyword;
  }

  void updateView() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // very first time
    if (searchBar.currentState == null) {
      Future.delayed(Duration.zero).then((value) => _onChanged(widget.text));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        title: SearchBar(
          key: searchBar,
          heroTag: widget.heroTag,
          onChanged: _onChanged,
          text: widget.text,
          hintText: widget.hintText,
          labelText: widget.labelText,
          helperText: widget.helperText,
          maxLength: widget.maxLength,
          textCapitalization: widget.textCapitalization,
          hideCounter: true,
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: isSearching ? CircularProgressIndicator() : _body(context),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (searchBar.currentState.text.isEmpty) {
      return Center(child: widget.initialBuilder(context));
    } else if (isNotEmpty) {
      return Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '搜尋到$count個結果',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        Expanded(child: _resultList()),
      ]);
    } else {
      return widget.emptyBuilder(context, searchBar.currentState.text);
    }
  }

  Widget _resultList() {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) =>
          widget.itemBuilder(context, list[index]),
      itemCount: list.length,
    );
  }

  Future<void> _onChanged(String text) async {
    setState(() {
      list.clear();
      isSearching = true;
    });
    final List<T> newList = await widget.onChanged(text);
    setState(() {
      list.addAll(newList);
      isSearching = false;
    });
  }

  Future<void> _onRefresh() async {
    await _onChanged(searchBar.currentState.text);
  }
}
