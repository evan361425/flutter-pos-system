import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:possystem/components/style/gradient_scroll_hint.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/breakpoint.dart';

class ResponsiveDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final Widget? action;
  final Widget? floatingActionButton;
  final bool scrollable;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final Size? fixedSizeOnDialog;

  const ResponsiveDialog({
    super.key,
    required this.title,
    required this.content,
    this.floatingActionButton,
    this.action,
    this.scrollable = true,
    this.scaffoldMessengerKey,
    this.fixedSizeOnDialog,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialog = size.width > Breakpoint.medium.max;

    if (dialog) {
      final realContent = fixedSizeOnDialog == null
          ? content
          : SizedBox(
              width: fixedSizeOnDialog!.width == 0 ? null : fixedSizeOnDialog!.width,
              height: fixedSizeOnDialog!.height == 0 ? null : fixedSizeOnDialog!.height,
              child: content,
            );
      final dialog = AlertDialog(
        title: title,
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        scrollable: scrollable,
        content: Stack(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: Breakpoint.compact.max),
              child: realContent,
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
                PopButton(
                  key: const Key('pop'),
                  title: MaterialLocalizations.of(context).cancelButtonLabel,
                ),
                action!,
              ],
      );

      // Using _PropertyHolderWidget to allow [Scaffold]'s snackbar able to be
      // clicked but not blocking the dialog.
      // https://stackoverflow.com/a/56290622/12089368
      return ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Stack(children: [
          _Transparent(child: dialog),
          _Transparent(
            foreground: true,
            child: Scaffold(
              primary: false,
              floatingActionButton: floatingActionButton,
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              backgroundColor: Colors.transparent,
            ),
          ),
        ]),
      );
    }

    return Dialog.fullscreen(
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          primary: false,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          appBar: AppBar(
            primary: false,
            title: title,
            leading: const CloseButton(key: Key('pop')),
            actions: action == null ? [] : [action!],
          ),
          body: scrollable ? SingleChildScrollView(child: content) : content,
        ),
      ),
    );
  }
}

class _Transparent extends SingleChildRenderObjectWidget {
  final bool foreground;

  const _Transparent({
    this.foreground = false,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return foreground ? _Foreground() : RenderProxyBox();
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {}
}

class _Foreground extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    super.hitTest(result, position: position);

    /// If greater than 10, it means not just tap on the empty space
    /// for example:
    /// - tap on FloatingActionButton has 18 targets
    /// - tap on Snackbar has 18 targets
    return result.path.length > 10;
  }
}
