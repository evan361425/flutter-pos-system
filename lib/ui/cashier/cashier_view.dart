import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/route_buttons.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

import 'widgets/unit_list_tile.dart';

class CashierView extends StatelessWidget {
  const CashierView({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: Breakpoint.medium.max),
        child: ListenableBuilder(
          listenable: Cashier.instance,
          builder: (context, _) {
            var i = 0;
            return ListView(padding: const EdgeInsets.only(bottom: kFABSpacing, top: kTopSpacing), children: [
              _buildActions(context),
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
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: kHorizontalSpacing),
      child: Row(children: [
        Tutorial(
          id: 'cashier.default',
          title: S.cashierToDefaultTutorialTitle,
          message: S.cashierToDefaultTutorialContent,
          preferVertical: true,
          child: RouteIconButton(
            key: const Key('cashier.defaulter'),
            label: S.cashierToDefaultTitle,
            icon: Icon(Cashier.instance.defaultNotSet ? Icons.star_border_outlined : Icons.star),
            onPressed: () => _handleSetDefault(context),
          ),
        ),
        const Spacer(),
        ButtonGroup(buttons: [
          Tutorial(
            id: 'cashier.change',
            title: S.cashierChangerTutorialTitle,
            message: S.cashierChangerTutorialContent,
            preferVertical: true,
            child: RouteIconButton(
              key: const Key('cashier.changer'),
              route: Routes.cashierChanger,
              icon: const Icon(Icons.sync_alt_outlined),
              label: S.cashierChangerTitle,
              popTrueShowSuccess: true,
            ),
          ),
          Tutorial(
            id: 'cashier.surplus',
            title: S.cashierSurplusTutorialTitle,
            message: S.cashierSurplusTutorialContent,
            preferVertical: true,
            child: RouteIconButton(
              key: const Key('cashier.surplus'),
              icon: const Icon(Icons.coffee_outlined),
              label: S.cashierSurplusTitle,
              onPressed: () => _handleSurplus(context),
            ),
          ),
        ]),
      ]),
    );
  }

  void _handleSetDefault(BuildContext context) async {
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

    if (context.mounted) {
      showSnackBar(S.actSuccess, context: context);
    }
  }

  void _handleSurplus(BuildContext context) async {
    if (Cashier.instance.defaultNotSet) {
      return showSnackBar(S.cashierSurplusErrorEmptyDefault, context: context);
    }

    final result = await context.pushNamed(Routes.cashierSurplus);
    if (result == true) {
      if (context.mounted) {
        showSnackBar(S.actSuccess, context: context);
      }
    }
  }
}
