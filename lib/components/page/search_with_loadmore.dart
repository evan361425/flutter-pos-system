import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:possystem/components/search_bar.dart';

class SearchWithLoadmore extends StatefulWidget {
  const SearchWithLoadmore({
    Key key,
    this.searchBar,
  }) : super(key: key);

  final SearchBar searchBar;

  @override
  SearchWithLoadmoreState createState() => SearchWithLoadmoreState();
}

class SearchWithLoadmoreState extends State<SearchWithLoadmore> {
  int get count => list.length;

  List<int> list = [];

  void load() {
    print('load');
    setState(() {
      list.addAll(List.generate(15, (v) => v));
      print('data count = ${list.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          widget.searchBar,
          RefreshIndicator(
            onRefresh: _refresh,
            child: LoadMore(
              isFinish: count >= 60,
              onLoadMore: _loadMore,
              whenEmptyLoad: false,
              delegate: DefaultLoadMoreDelegate(),
              textBuilder: DefaultLoadMoreTextBuilder.chinese,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 40.0,
                    alignment: Alignment.center,
                    child: Text(list[index].toString()),
                  );
                },
                itemCount: count,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _loadMore() async {
    print('onLoadMore');
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    load();
    return true;
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    list.clear();
    load();
  }
}
