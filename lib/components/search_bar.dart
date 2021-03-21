import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

class SearchBar extends StatefulWidget {
  SearchBar({
    Key key,
    @required this.onChanged,
    this.text = '',
    this.hintText = '',
    this.labelText = '',
    this.helperText = '',
    this.maxLength = 30,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  final int maxLength;
  final String text;
  final String helperText;
  final String hintText;
  final String labelText;
  final TextCapitalization textCapitalization;
  final void Function(String) onChanged;

  @override
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  final controller = TextEditingController();

  set text(String text) => controller.text = text;
  String get text => controller.text;

  bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(kPadding),
      child: TextField(
        controller: controller,
        maxLength: widget.maxLength,
        onChanged: (String text) {
          if (text.isEmpty) {
            setState(() => isEmpty = true);
          } else if (isEmpty) {
            setState(() => isEmpty = false);
          }
          widget.onChanged(text);
        },
        textCapitalization: widget.textCapitalization,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          helperText: widget.helperText,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: isEmpty
              ? null
              : IconButton(
                  onPressed: controller.clear,
                  icon: Icon(Icons.clear),
                ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    text = widget.text;
    isEmpty = widget.text.isEmpty;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
