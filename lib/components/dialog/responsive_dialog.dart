import 'package:flutter/material.dart';
import 'package:possystem/components/style/gradient_scroll_hint.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/breakpoint.dart';

class ResponsiveDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final Widget? action;
  final bool scrollable;

  const ResponsiveDialog({
    super.key,
    required this.title,
    required this.content,
    this.action,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialog = size.width > Breakpoint.medium.max;

    if (dialog) {
      final dialog = AlertDialog(
        title: title,
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        scrollable: scrollable,
        content: Stack(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: Breakpoint.compact.max),
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
        actions: action == null
            ? null
            : [
                PopButton(title: MaterialLocalizations.of(context).cancelButtonLabel),
                action!,
              ],
      );

      // TODO: use another package for showing snackbar in dialog.
      // This is a workaround for showing snackbar in dialog. [IgnorePointer] is
      // used to pass the touch event to the dialog behind the scaffold. But
      // this will also block the action (i.e. close SnackBar) in snackbar.
      return ScaffoldMessenger(
        child: Stack(children: [
          dialog,
          const IgnorePointer(
            child: Scaffold(primary: false, backgroundColor: Colors.transparent),
          ),
        ]),
      );
    }

    return Dialog.fullscreen(
      child: ScaffoldMessenger(
        child: Scaffold(
          primary: false,
          appBar: AppBar(
            primary: false,
            title: title,
            leading: const CloseButton(),
            actions: action == null ? [] : [action!],
          ),
          body: scrollable ? SingleChildScrollView(child: content) : content,
        ),
      ),
    );
  }
}
