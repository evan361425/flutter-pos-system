import 'package:flutter/material.dart';
import 'package:possystem/components/circular_loading.dart';
import 'package:possystem/components/search_bar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helper/custom_styles.dart';

class SearchScaffold<T> extends StatefulWidget {
  const SearchScaffold({
    Key? key,
    required this.onChanged,
    required this.itemBuilder,
    required this.emptyBuilder,
    required this.initialData,
    this.heroTag,
    this.text = '',
    this.hintText = '',
    this.labelText = '',
    this.helperText = '',
    this.maxLength = 30,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  final Future<List<T>> Function(String) onChanged;
  final String? heroTag;
  final int maxLength;
  final String text;
  final String helperText;
  final String hintText;
  final String labelText;
  final TextCapitalization textCapitalization;
  final Future<List<T>> Function() initialData;
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
    searchBar.currentState!.text = keyword;
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
          child: isSearching ? CircularLoading() : _body(context),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (searchBar.currentState!.text.isEmpty) {
      return FutureBuilder<List<T>>(
        future: widget.initialData() as Future<List<T>>,
        builder: (context, snapshot) {
          // while data is loading:
          if (!snapshot.hasData) return CircularLoading();

          return _listBuilder(context, snapshot.data!);
        },
      );
    } else if (isNotEmpty) {
      return Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '搜尋到$count個結果',
            style: Theme.of(context).textTheme.muted,
          ),
        ),
        Expanded(child: _listBuilder(context, list)),
      ]);
    } else {
      return widget.emptyBuilder(context, searchBar.currentState!.text);
    }
  }

  Widget _listBuilder(BuildContext context, List<T> data) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return widget.itemBuilder(context, data[index]);
      },
      itemCount: data.length,
    );
  }

  Future<void> _onChanged(String text) async {
    setState(() {
      list.clear();
      isSearching = true;
    });
    final newList = await widget.onChanged(text) as List<T>;
    setState(() {
      list.addAll(newList);
      isSearching = false;
    });
  }

  Future<void> _onRefresh() async {
    await _onChanged(searchBar.currentState!.text);
  }
}
