import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchBar extends StatefulWidget {
  SearchBar({
    Key key,
    @required this.onChanged,
    this.text = '',
    this.hintText = '',
    this.labelText = '',
    this.helperText = '',
    this.maxLength = 30,
    this.hideCounter = false,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  final int maxLength;
  final String text;
  final String helperText;
  final String hintText;
  final String labelText;
  final bool hideCounter;
  final TextCapitalization textCapitalization;
  final void Function(String) onChanged;

  @override
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  final controller = TextEditingController();

  set text(String text) {
    controller.text = text;
    _onChanged(text);
  }

  String get text => controller.text;

  bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      maxLength: widget.maxLength,
      autofocus: true,
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
      padding: EdgeInsets.zero,
      placeholder: widget.hintText,
      onSubmitted: _onChanged,
      // expands: true,
      suffix: isEmpty
          ? null
          : CupertinoButton(
              onPressed: () {
                controller.clear();
                _onChanged('');
              },
              child: Icon(Icons.clear),
            ),
    );
  }

  void _onChanged(String text) {
    text = text.trim();
    if (text.isEmpty) {
      setState(() => isEmpty = true);
    } else if (isEmpty) {
      setState(() => isEmpty = false);
    }
    widget.onChanged(text);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller.text = widget.text;
    isEmpty = widget.text.isEmpty;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
