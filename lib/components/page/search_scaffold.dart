import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:possystem/components/search_bar.dart';

class SearchScaffold<T> extends StatefulWidget {
  const SearchScaffold({
    Key key,
    @required this.onChanged,
    @required this.onLoad,
    @required this.itemBuilder,
    @required this.emptyBuilder,
    this.heroTag,
    this.text = '',
    this.hintText = '',
    this.labelText = '',
    this.helperText = '',
    this.maxLength = 30,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  final Future<List<T>> Function(String) onChanged;
  final Future<List<T>> Function(int) onLoad;
  final String heroTag;
  final int maxLength;
  final String text;
  final String helperText;
  final String hintText;
  final String labelText;
  final TextCapitalization textCapitalization;
  final Widget Function(BuildContext, T item) itemBuilder;
  final Widget Function(BuildContext, String text) emptyBuilder;

  @override
  SearchScaffoldState<T> createState() => SearchScaffoldState<T>();
}

class SearchScaffoldState<T> extends State<SearchScaffold> {
  final GlobalKey<SearchBarState> searchBar = GlobalKey<SearchBarState>();
  bool isFinish = false;
  bool isSearching = false;
  int get count => list.length;
  bool get isEmpty => list.isEmpty;
  List<T> list = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: SearchBar(
          key: searchBar,
          onChanged: _onChanged,
          text: widget.text,
          hintText: widget.hintText,
          labelText: widget.labelText,
          helperText: widget.helperText,
          maxLength: widget.maxLength,
          textCapitalization: widget.textCapitalization,
        ),
        heroTag: widget.heroTag,
        transitionBetweenRoutes: widget.heroTag != null,
      ),
      child: SafeArea(
        child: Center(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: isSearching
                ? CircularProgressIndicator()
                : isEmpty
                    ? widget.emptyBuilder(context, searchBar.currentState.text)
                    : _loadMore(),
          ),
        ),
      ),
    );
  }

  LoadMore _loadMore() {
    return LoadMore(
      isFinish: isFinish,
      onLoadMore: _onLoadMore,
      textBuilder: (LoadMoreStatus status) {
        switch (status) {
          case LoadMoreStatus.fail:
            return '加載失敗，請點擊重試';
          case LoadMoreStatus.idle:
            return '加載更多';
          case LoadMoreStatus.loading:
            return '加載中';
          case LoadMoreStatus.nomore:
            return '加載完畢';
          default:
            return '';
        }
      },
      child: ListView.builder(
        itemBuilder: (context, index) =>
            widget.itemBuilder(context, list[index]),
        itemCount: count,
      ),
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

  Future<bool> _onLoadMore() async {
    final List<T> newList = await widget.onLoad(count);
    if (newList.isEmpty) {
      setState(() => isFinish = true);
    } else {
      setState(() => list.addAll(newList));
    }

    return true;
  }

  Future<void> _onRefresh() async {
    await _onChanged(searchBar.currentState.text);
  }
}
