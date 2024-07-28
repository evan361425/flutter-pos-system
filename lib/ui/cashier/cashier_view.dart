import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

import 'widgets/unit_list_tile.dart';

class CashierView extends StatefulWidget {
  final int? tabIndex;

  const CashierView({
    super.key,
    this.tabIndex,
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
          child: ListenableBuilder(
            listenable: Cashier.instance,
            builder: (context, _) {
              var i = 0;
              return ListView(padding: const EdgeInsets.only(bottom: kFABSpacing, top: kTopSpacing), children: [
                _buildActions(),
                const SizedBox(height: kInternalSpacing),
                for (final item in Cashier.instance.currentUnits)
                  UnitListTile(
                    item: item,
                    index: i++,
                  ),
              ]);
            },
          ),
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
    return Padding(
      padding: const EdgeInsets.only(right: kHorizontalSpacing),
      child: Row(children: [
        Tutorial(
          id: 'cashier.default',
          index: 2,
          title: S.cashierToDefaultTutorialTitle,
          message: S.cashierToDefaultTutorialContent,
          child: RouteIconButton(
            key: const Key('cashier.defaulter'),
            tooltip: S.cashierToDefaultTitle,
            icon: Icon(Cashier.instance.defaultNotSet ? Icons.star_border : Icons.star),
            onPressed: _handleSetDefault,
          ),
        ),
        const Spacer(),
        Material(
          elevation: 1.0,
          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
          child: Row(children: [
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0),
              child: VerticalDivider(width: 1, thickness: 1),
            ),
            Tutorial(
              index: 0,
              id: 'cashier.surplus',
              title: S.cashierSurplusTutorialTitle,
              message: S.cashierSurplusTutorialContent,
              child: RouteIconButton(
                key: const Key('cashier.surplus'),
                icon: const Icon(Icons.coffee_sharp),
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
