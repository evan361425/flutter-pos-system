import 'package:flutter/material.dart';
import 'package:possystem/components/style/search_bar_inline.dart';

class SearchBarWrapper<T> extends StatefulWidget {
  final String? text;

  final String? labelText;

  final String? hintText;

  final String? Function(String)? validator;

  final String? Function(String?)? formValidator;

  final Future<Iterable<T>> Function(String) search;

  final Iterable<T> initData;

  final Widget Function(BuildContext, T) itemBuilder;

  final Widget Function(BuildContext, String) emptyBuilder;

  const SearchBarWrapper({
    Key? key,
    this.text,
    this.labelText,
    this.hintText,
    this.validator,
    this.formValidator,
    required this.search,
    required this.initData,
    required this.itemBuilder,
    required this.emptyBuilder,
  }) : super(key: key);

  @override
  State<SearchBarWrapper<T>> createState() => _SearchBarWrapperState<T>();
}

class _SearchBarWrapperState<T> extends State<SearchBarWrapper<T>> {
  late final SearchController searchController;

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: searchController,
      builder: widget.text == null
          ? (BuildContext context, SearchController controller) {
              return IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => controller.openView(),
              );
            }
          : (BuildContext context, SearchController controller) {
              return SearchBarInline(
                text: widget.text,
                hintText: widget.hintText,
                labelText: widget.labelText,
                validator: widget.formValidator,
                onTap: () => controller.openView(),
              );
            },
      viewHintText: widget.hintText,
      viewBuilder: (suggestions) => suggestions.first,
      suggestionsBuilder: (context, controller) {
        if (controller.text.isEmpty) {
          return [buildItems(context, widget.initData)];
        }

        return [
          FutureBuilder<Iterable<T>>(
            future: widget.search(controller.text),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                // TODO: error handler
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data;
              if (data == null || data.isEmpty) {
                final error = widget.validator?.call(controller.text);
                // [Column] widget minimum children height
                if (error != null) {
                  return buildSingle(
                    context,
                    ListTile(
                      title: Text(error),
                      leading: const Icon(Icons.warning_amber_sharp),
                    ),
                  );
                }

                return buildSingle(
                  context,
                  widget.emptyBuilder(context, controller.text),
                );
              }

              return buildItems(context, data);
            },
          )
        ];
      },
    );
  }

  @override
  void initState() {
    searchController = SearchController();
    if (widget.text != null) {
      searchController.text = widget.text!;
    }
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget buildItems(BuildContext context, Iterable<T> items) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => widget.itemBuilder(
          context,
          items.elementAt(index),
        ),
      ),
    );
  }

  Widget buildSingle(BuildContext context, Widget child) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) => child,
      ),
    );
  }
}
