import 'package:flutter/material.dart';
import 'package:possystem/components/search_bar.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/translator.dart';

class SearchScaffold<T> extends StatefulWidget {
  final Future<Iterable<T>> Function(String) handleChanged;
  final int maxLength;
  final String text;
  final String helperText;
  final String hintText;
  final String labelText;
  final TextCapitalization textCapitalization;
  final List<T> initialData;
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

class SearchScaffoldState<T> extends State<SearchScaffold<T>> {
  final GlobalKey<SearchBarState> searchBar = GlobalKey<SearchBarState>();

  final List<T> list = [];

  bool isSearching = false;

  int get count => list.length;

  bool get isNotEmpty => list.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
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
          cursorColor: colorScheme.brightness == Brightness.dark
              ? colorScheme.onSurface
              : colorScheme.onPrimary,
        ),
      ),
      body: isSearching ? const CircularLoading() : _body(context),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.text.isNotEmpty) {
      _handleChanged(widget.text);
    }
  }

  Widget _body(BuildContext context) {
    // null or true
    if (searchBar.currentState?.text.isEmpty != false) {
      return _listBuilder(context, widget.initialData);
    } else if (isNotEmpty) {
      return Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: HintText(tt('search_count', {'count': count})),
        ),
        Expanded(child: _listBuilder(context, list)),
      ]);
    } else {
      return widget.emptyBuilder(context, searchBar.currentState!.text);
    }
  }

  Future<void> _handleChanged(String text) async {
    final newList = await widget.handleChanged(text);

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
