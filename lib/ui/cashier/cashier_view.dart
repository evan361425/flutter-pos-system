import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

import 'widgets/unit_list_view.dart';

class CashierView extends StatefulWidget {
  final int? tabIndex;

  const CashierView({super.key, this.tabIndex});

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
      child: ListView(padding: const EdgeInsets.only(bottom: 76, top: 16), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Expanded(
            child: Tutorial(
              id: 'cashier.default',
              index: 2,
              title: S.cashierToDefaultTutorialTitle,
              message: S.cashierToDefaultTutorialContent,
              child: RouteCircularButton(
                key: const Key('cashier.defaulter'),
                onTap: handleSetDefault,
                icon: Icons.upload_sharp,
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
                popTrueShowSuccess: true,
                onTap: handleSurplus,
              ),
            ),
          ),
        ]),
        const UnitListView(),
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    tab = widget.tabIndex == null ? null : TutorialInTab(index: widget.tabIndex!, context: context);

    super.initState();
  }

  void handleSetDefault() async {
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

  void handleSurplus() async {
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
