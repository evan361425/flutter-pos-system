import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:possystem/constants/icons.dart';

class SearchBar extends StatefulWidget {
  final int maxLength;
  final String text;
  final String helperText;
  final String hintText;
  final String labelText;
  final bool hideCounter;
  final TextCapitalization textCapitalization;
  final void Function(String) onChanged;

  SearchBar({
    Key? key,
    required this.onChanged,
    this.text = '',
    this.hintText = '',
    this.labelText = '',
    this.helperText = '',
    this.maxLength = 30,
    this.hideCounter = false,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  final controller = TextEditingController();

  late bool isEmpty;

  String get text => controller.text;

  set text(String text) {
    controller.text = text;
    _onChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: widget.maxLength,
      autofocus: true,
      onChanged: _onChanged,
      textCapitalization: widget.textCapitalization,
      textInputAction: TextInputAction.done,
      onSubmitted: _onChanged,
      decoration: InputDecoration(
        isDense: true,
        suffix: isEmpty
            ? null
            : GestureDetector(
                onTap: () {
                  controller.clear();
                  _onChanged('');
                },
                child: Icon(KIcons.clear, size: 16.0),
              ),
        hintText: widget.hintText,
        counterText: '',
      ),
      // padding: EdgeInsets.zero,
      // placeholder: widget.hintText,
    );
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

  void _onChanged(String text) {
    text = text.trim();
    if (text.isEmpty) {
      setState(() => isEmpty = true);
    } else if (isEmpty) {
      setState(() => isEmpty = false);
    }
    widget.onChanged(text);
  }
}
