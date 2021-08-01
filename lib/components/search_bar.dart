import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';

class SearchBar extends StatefulWidget {
  final int maxLength;
  final String text;
  final String helperText;
  final String hintText;
  final String labelText;
  final Color? cursorColor;
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
    this.textCapitalization = TextCapitalization.none,
    this.cursorColor,
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
    final focusedBorder = widget.cursorColor == null
        ? null
        : UnderlineInputBorder(
            borderSide: BorderSide(color: widget.cursorColor!));

    final suffix = isEmpty
        ? null
        : GestureDetector(
            onTap: () {
              controller.clear();
              _onChanged('');
            },
            child: Icon(KIcons.clear, size: 16.0),
          );

    return TextField(
      controller: controller,
      maxLength: widget.maxLength,
      autofocus: true,
      onChanged: _onChanged,
      textCapitalization: widget.textCapitalization,
      textInputAction: TextInputAction.done,
      onSubmitted: _onChanged,
      cursorColor: widget.cursorColor,
      decoration: InputDecoration(
        isDense: true,
        focusedBorder: focusedBorder,
        suffix: suffix,
        hintText: widget.hintText,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: kSpacing1),
      ),
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
