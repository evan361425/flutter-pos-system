import 'package:flutter/material.dart';
import 'package:possystem/components/style/gradient_scroll_hint.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/breakpoint.dart';

class ResponsiveDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget> actions;

  const ResponsiveDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialog = size.width > Breakpoint.medium.max;

    if (dialog) {
      return AlertDialog(
        title: title,
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        content: Stack(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: Breakpoint.compact.max,
              ),
              child: content,
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: kDialogBottomSpacing,
              child: GradientScrollHint(
                isDialog: true,
                direction: Axis.vertical,
              ),
            ),
          ],
        ),
        actions: [
          PopButton(title: MaterialLocalizations.of(context).cancelButtonLabel),
          ...actions,
        ],
      );
    }

    return Dialog.fullscreen(
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        primary: false,
        appBar: AppBar(
          primary: false,
          title: title,
          leading: const CloseButton(),
          actions: actions,
        ),
        body: content,
      ),
    );
  }
}
