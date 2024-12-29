import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/route_buttons.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/printer/widgets/printer_view.dart';

class PrinterPage extends StatelessWidget {
  const PrinterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      key: const Key('printers_page'),
      listenable: Printers.instance,
      builder: (context, child) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (Printers.instance.isEmpty) {
      return const _EmptyBody();
    }

    return ListView(children: [
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        ButtonGroup(buttons: [
          RouteIconButton(
            key: const Key('printer.settings'),
            route: Routes.printerSettings,
            icon: const Icon(Icons.settings),
            label: S.printerTitleSettings,
          ),
        ]),
        const SizedBox(width: kHorizontalSpacing),
      ]),
      const SizedBox(height: kInternalSpacing),
      SlidableItemList(
        hintText: '', // disabling hint text, no need to show count
        leading: Row(children: [
          Expanded(
            child: RouteElevatedIconButton(
              key: const Key('printer.create'),
              route: Routes.printerCreate,
              icon: const Icon(KIcons.add),
              label: S.printerTitleCreate,
            ),
          ),
        ]),
        delegate: SlidableItemDelegate(
          disableSlide: true,
          items: Printers.instance.itemList,
          tileBuilder: (printer, _, actorBuilder) => _Tile(printer, actorBuilder),
          handleDelete: (printer) => printer.remove(),
          deleteValue: 0,
          warningContentBuilder: (_, printer) => Text(S.dialogDeletionContent(printer.name, '')),
        ),
      ),
    ]);
  }
}

class _Tile extends StatelessWidget {
  final Printer item;
  final ActorBuilder actorBuilder;

  const _Tile(this.item, this.actorBuilder);

  @override
  Widget build(BuildContext context) {
    final actor = actorBuilder(context);
    return Padding(
      padding: const EdgeInsets.only(top: kInternalSpacing),
      child: PrinterView(
        printer: item,
        trailing: EntryMoreButton(onPressed: actor),
        onTap: () => context.pushNamed(Routes.printerUpdate, pathParameters: {'id': item.id}),
        onLogPress: actor,
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(children: [
      Positioned.fill(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(25, 118, 210, 1), // blue.shade700
                Color.fromRGBO(21, 101, 192, 1), // blue.shade800
                Color.fromRGBO(13, 71, 161, 1), // blue.shade900
                // only half screen will be shown, so below color is used but not shown
                Color.fromRGBO(13, 71, 161, 1),
                Color.fromRGBO(13, 71, 161, 1),
                Color.fromRGBO(13, 71, 161, 1),
              ],
            ),
          ),
          child: Column(children: [
            Expanded(
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Icon(
                      Icons.bluetooth,
                      color: Color.fromRGBO(13, 71, 161, 1), // blue.shade900
                      size: 56,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ]),
        ),
      ),
      Positioned.fill(
        child: ClipPath(
          clipper: _Wave1(),
          child: ColoredBox(color: theme.scaffoldBackgroundColor.withAlpha(102), child: const SizedBox.expand()),
        ),
      ),
      Positioned.fill(
        child: ClipPath(
          clipper: _Wave2(),
          child: ColoredBox(color: theme.scaffoldBackgroundColor, child: const SizedBox.expand()),
        ),
      ),
      Positioned.fill(
        child: Column(children: [
          const Spacer(),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  S.printerMetaHelper,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: kInternalSpacing),
                FilledButton(
                  onPressed: () => context.pushNamed(Routes.printerCreate),
                  child: Text(S.printerTitleCreate),
                ),
              ]),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _Wave1 extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    final w = size.width;
    final h = size.height;

    return Path()
      ..lineTo(0, 0.5 * h)
      ..quadraticBezierTo(0.15 * w, 0.4 * h, 0.3 * w, 0.45 * h)
      ..quadraticBezierTo(0.4 * w, 0.48 * h, 0.62 * w, 0.41 * h)
      ..quadraticBezierTo(0.8 * w, 0.35 * h, w, 0.43 * h)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;
}

class _Wave2 extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    final w = size.width;
    final h = size.height;

    return Path()
      ..lineTo(0, h / 2)
      ..quadraticBezierTo(0.18 * w, 0.56 * h, 0.31 * w, 0.45 * h)
      ..quadraticBezierTo(0.42 * w, 0.38 * h, 0.65 * w, 0.445 * h)
      ..quadraticBezierTo(0.8 * w, 0.48 * h, w, 0.41 * h)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;
}
