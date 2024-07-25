import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

import 'widgets/unit_list_view.dart';

class CashierView extends StatefulWidget {
  final int? tabIndex;
  final bool circularActions;

  const CashierView({
    super.key,
    this.tabIndex,
    this.circularActions = true,
  });

  @override
  State<CashierView> createState() => _CashierViewState();
}

class _CashierViewState extends State<CashierView> with AutomaticKeepAliveClientMixin {
  late final TutorialInTab? tab;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return TutorialWrapper(
      tab: tab,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Breakpoint.medium.max),
          child: UnitListView(leading: _buildActions()),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    tab = widget.tabIndex == null ? null : TutorialInTab(index: widget.tabIndex!, context: context);

    super.initState();
  }

  Widget _buildActions() {
    if (widget.circularActions) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Expanded(
          child: Tutorial(
            id: 'cashier.default',
            index: 2,
            title: S.cashierToDefaultTutorialTitle,
            message: S.cashierToDefaultTutorialContent,
            child: RouteCircularButton(
              key: const Key('cashier.defaulter'),
              onTap: _handleSetDefault,
              icon: Cashier.instance.defaultNotSet ? Icons.star_border : Icons.star,
              text: S.cashierToDefaultTitle,
            ),
          ),
        ),
        Expanded(
          child: Tutorial(
            index: 1,
            id: 'cashier.change',
            title: S.cashierChangerTutorialTitle,
            message: S.cashierChangerTutorialContent,
            child: RouteCircularButton(
              key: const Key('cashier.changer'),
              route: Routes.cashierChanger,
              icon: Icons.sync_alt_sharp,
              text: S.cashierChangerTitle,
              popTrueShowSuccess: true,
            ),
          ),
        ),
        Expanded(
          child: Tutorial(
            index: 0,
            id: 'cashier.surplus',
            title: S.cashierSurplusTutorialTitle,
            message: S.cashierSurplusTutorialContent,
            child: RouteCircularButton(
              key: const Key('cashier.surplus'),
              icon: Icons.coffee_sharp,
              text: S.cashierSurplusTitle,
              onTap: _handleSurplus,
            ),
          ),
        ),
      ]);
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Material(
          elevation: 1.0,
          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
          child: Row(children: [
            Tutorial(
              id: 'cashier.default',
              index: 2,
              title: S.cashierToDefaultTutorialTitle,
              message: S.cashierToDefaultTutorialContent,
              child: IconButton(
                key: const Key('cashier.defaulter'),
                tooltip: S.cashierToDefaultTitle,
                icon: Icon(Cashier.instance.defaultNotSet ? Icons.star_border : Icons.star),
                iconSize: 32,
                onPressed: _handleSetDefault,
              ),
            ),
            Tutorial(
              index: 1,
              id: 'cashier.change',
              title: S.cashierChangerTutorialTitle,
              message: S.cashierChangerTutorialContent,
              child: RouteIconButton(
                key: const Key('cashier.changer'),
                route: Routes.cashierChanger,
                icon: const Icon(Icons.sync_alt_sharp),
                tooltip: S.cashierChangerTitle,
                popTrueShowSuccess: true,
              ),
            ),
            Tutorial(
              index: 0,
              id: 'cashier.surplus',
              title: S.cashierSurplusTutorialTitle,
              message: S.cashierSurplusTutorialContent,
              child: IconButton(
                key: const Key('cashier.surplus'),
                icon: const Icon(Icons.coffee_sharp),
                iconSize: 32,
                tooltip: S.cashierSurplusTitle,
                onPressed: _handleSurplus,
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  void _handleSetDefault() async {
    if (!Cashier.instance.defaultNotSet) {
      final result = await ConfirmDialog.show(
        context,
        title: S.cashierToDefaultDialogTitle,
        content: S.cashierToDefaultDialogContent,
      );

      if (!result) {
        return;
      }
    }

    await Cashier.instance.setDefault();

    if (mounted) {
      showSnackBar(context, S.actSuccess);
    }
  }

  void _handleSurplus() async {
    if (Cashier.instance.defaultNotSet) {
      return showSnackBar(context, S.cashierSurplusErrorEmptyDefault);
    }

    final result = await context.pushNamed(Routes.cashierSurplus);
    if (result == true) {
      if (mounted) {
        showSnackBar(context, S.actSuccess);
      }
    }
  }
}
