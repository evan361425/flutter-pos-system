import 'package:flutter/material.dart';
import 'package:possystem/components/search_bar.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/translator.dart';

class SearchScaffold<T> extends StatefulWidget {
  final Future<List<T>> Function(String) handleChanged;
  final int maxLength;
  final String text;
  final String helperText;
  final String hintText;
  final String labelText;
  final TextCapitalization textCapitalization;
  final Future<List<T>> Function() initialData;
  final Widget Function(BuildContext, T item) itemBuilder;
  final Widget Function(BuildContext, String text) emptyBuilder;

  const SearchScaffold({
    Key? key,
    required this.handleChanged,
    required this.itemBuilder,
    required this.emptyBuilder,
    required this.initialData,
    this.text = '',
    this.hintText = '',
    this.labelText = '',
    this.helperText = '',
    this.maxLength = 30,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  SearchScaffoldState<T> createState() => SearchScaffoldState<T>();
}

class SearchScaffoldState<T> extends State<SearchScaffold> {
  final GlobalKey<SearchBarState> searchBar = GlobalKey<SearchBarState>();

  final List<T> list = [];

  bool isSearching = true;

  int get count => list.length;
  bool get isNotEmpty => list.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        title: SearchBar(
          key: searchBar,
          onChanged: (text) {
            setState(() {
              list.clear();
              isSearching = true;
            });
            _handleChanged(text);
          },
          text: widget.text,
          hintText: widget.hintText,
          labelText: widget.labelText,
          helperText: widget.helperText,
          maxLength: widget.maxLength,
          textCapitalization: widget.textCapitalization,
          hideCounter: true,
          cursorColor: colorScheme.brightness == Brightness.dark
              ? colorScheme.onSurface
              : colorScheme.onPrimary,
        ),
      ),
      body: isSearching ? CircularLoading() : _body(context),
    );
  }

  @override
  void initState() {
    super.initState();
    _handleChanged(widget.text);
  }

  Widget _body(BuildContext context) {
    if (searchBar.currentState?.text.isEmpty == true) {
      return FutureBuilder<List<T>>(
        future: widget.initialData() as Future<List<T>>,
        builder: (context, snapshot) {
          // while data is loading:
          if (!snapshot.hasData) return CircularLoading();
          if (snapshot.hasError) {
            error(
                snapshot.error.toString(), 'search.error', snapshot.stackTrace);
            return Text(tt('unknown_error'));
          }

          return _listBuilder(context, snapshot.data!);
        },
      );
    } else if (isNotEmpty) {
      return Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            tt('search_count', {'count': count}),
            style: Theme.of(context).textTheme.muted,
          ),
        ),
        Expanded(child: _listBuilder(context, list)),
      ]);
    } else {
      return widget.emptyBuilder(context, searchBar.currentState!.text);
    }
  }

  Future<void> _handleChanged(String text) async {
    final newList = await widget.handleChanged(text) as List<T>;

    setState(() {
      list.addAll(newList);
      isSearching = false;
    });
  }

  Widget _listBuilder(BuildContext context, List<T> data) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return widget.itemBuilder(context, data[index]);
      },
      itemCount: data.length,
    );
  }
}
