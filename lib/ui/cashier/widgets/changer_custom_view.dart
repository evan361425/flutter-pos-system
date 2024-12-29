import 'package:flutter/material.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

class ChangerCustomView extends StatefulWidget {
  final VoidCallback afterFavoriteAdded;

  const ChangerCustomView({
    super.key,
    required this.afterFavoriteAdded,
  });

  @override
  State<ChangerCustomView> createState() => ChangerCustomViewState();
}

class ChangerCustomViewState extends State<ChangerCustomView> {
  final formKey = GlobalKey<FormState>();

  /// Money to changed
  List<CashierChangeEntryObject> targets = [CashierChangeEntryObject()];

  /// Count of source unit
  late TextEditingController sourceCount;

  /// First target count controller
  ///
  /// It will be changed by programmatically
  late TextEditingController targetController;

  num? sourceUnit;

  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final actions = Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      FilledButton(
        key: const Key('changer.custom.add_favorite'),
        onPressed: handleAddFavorite,
        child: Text(S.cashierChangerCustomAddBtn),
      ),
    ]);

    final sourceEntry = _wrapInRow(
      TextFormField(
        key: const Key('changer.custom.source.count'),
        controller: sourceCount,
        keyboardType: TextInputType.number,
        onChanged: handleCountChanged,
        decoration: InputDecoration(labelText: S.cashierChangerCustomCountLabel),
        validator: Validator.positiveInt(S.cashierChangerCustomCountLabel, minimum: 1),
      ),
      DropdownButtonFormField<num>(
        key: const Key('changer.custom.source.unit'),
        value: sourceUnit,
        hint: Text(S.cashierChangerCustomUnitLabel),
        isDense: true,
        style: Theme.of(context).textTheme.bodyMedium,
        onChanged: handleUnitChanged,
        items: _unitDropdownMenuItems(),
      ),
    );
    final targetEntries = <Widget>[
      for (var entry in targets.asMap().entries)
        Padding(
          padding: const EdgeInsets.only(top: kInternalSpacing),
          child: _wrapInRow(
              TextFormField(
                key: Key('changer.custom.target.${entry.key}.count'),
                controller: entry.key == 0 ? targetController : null,
                initialValue: entry.key == 0 ? null : entry.value.count?.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: S.cashierChangerCustomCountLabel),
                validator: Validator.positiveInt('', allowNull: true),
                onSaved: (value) => entry.value.count = int.tryParse(value ?? ''),
              ),
              DropdownButtonFormField<num>(
                key: Key('changer.custom.target.${entry.key}.unit'),
                value: entry.value.unit,
                hint: Text(S.cashierChangerCustomCountLabel),
                style: Theme.of(context).textTheme.bodyMedium,
                onChanged: (value) => setState(() => entry.value.unit = value),
                onSaved: (value) => entry.value.unit = value,
                items: _unitDropdownMenuItems(),
              ),
              entry.key == 0
                  ? null
                  : IconButton(
                      onPressed: () => setState(() {
                        targets.removeAt(entry.key);
                      }),
                      color: theme.colorScheme.error,
                      icon: const Icon(KIcons.entryRemove),
                      tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                    )),
        )
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing),
      child: Form(
        key: formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          actions,
          if (errorMessage.isNotEmpty)
            Center(
              child: Text(
                errorMessage,
                style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.error),
              ),
            ),
          TextDivider(label: S.cashierChangerCustomDividerFrom),
          sourceEntry,
          TextDivider(label: S.cashierChangerCustomDividerTo),
          ...targetEntries,
          // add bottom
          const SizedBox(height: kInternalSpacing),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              targets.add(CashierChangeEntryObject());
            }),
            icon: const Icon(KIcons.add),
            label: Text(S.cashierChangerCustomUnitAddBtn),
          )
        ]),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    sourceCount = TextEditingController(text: '1');
    targetController = TextEditingController();
  }

  @override
  void dispose() {
    sourceCount.dispose();
    targetController.dispose();
    super.dispose();
  }

  void handleAddFavorite() async {
    if (!validate()) return;

    await Cashier.instance.addFavorite(CashierChangeBatchObject(
        source: CashierChangeEntryObject(
          count: int.parse(sourceCount.text),
          unit: sourceUnit!,
        ),
        targets: [
          for (var target in _mergedTargets().entries) CashierChangeEntryObject(count: target.value, unit: target.key)
        ]));

    // close keyboard
    if (mounted) {
      FocusScope.of(context).unfocus();
    }

    widget.afterFavoriteAdded();
  }

  Future<bool> handleApply() async {
    if (!validate()) return false;

    final index = Cashier.instance.indexOf(sourceUnit!);
    final count = int.parse(sourceCount.text);

    if (Cashier.instance.validate(index, count)) {
      await Cashier.instance.update({
        index: -count,
        ...{for (var target in _mergedTargets().entries) Cashier.instance.indexOf(target.key): target.value},
      });
      return true;
    } else {
      _setError(S.cashierChangerErrorNotEnough(sourceUnit!.toCurrency()));
      return false;
    }
  }

  void handleCountChanged(String value) {
    _changeSource(int.tryParse(value));
  }

  void handleUnitChanged(num? value) {
    setState(() {
      sourceUnit = value;

      _changeSource(int.tryParse(sourceCount.text));
    });
  }

  bool validate() {
    if (sourceUnit == null || sourceUnit! <= 0) {
      _setError(S.invalidNumberPositive(S.cashierChangerCustomUnitLabel));
      return false;
    }

    if (formKey.currentState?.validate() != true) {
      return false;
    }

    // this will trigger onSaved and set up the value
    formKey.currentState?.save();

    final count = int.parse(sourceCount.text);
    var total = count * sourceUnit!;

    for (var target in targets) {
      total -= target.total;
    }

    if (total == 0) {
      return true;
    }

    var msg = S.cashierChangerErrorInvalidHead(count, sourceUnit!.toCurrency());
    for (var target in targets) {
      if (!target.isEmpty) {
        msg += '\n •  ${S.cashierChangerErrorInvalidBody(target.count!, target.unit!.toCurrency())}';
      }
    }
    _setError(msg);
    return false;
  }

  void _changeSource(int? count) {
    if (count == null || sourceUnit == null) {
      return;
    }

    setState(() {
      final result = Cashier.instance.findPossibleChange(count, sourceUnit!);
      targets = [result ?? CashierChangeEntryObject()];
      targetController.text = targets.first.count?.toString() ?? '';
    });
  }

  Map<num, int> _mergedTargets() {
    final deltas = <num, int>{};

    for (var target in targets) {
      if (!target.isEmpty) {
        final old = deltas[target.unit!] ?? 0;
        deltas[target.unit!] = old + target.count!;
      }
    }

    return deltas;
  }

  Widget _wrapInRow(Widget a, Widget b, [Widget? c]) {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, spacing: kInternalSpacing, children: [
      Flexible(flex: 1, child: a),
      Flexible(flex: 1, child: b),
      if (c != null) c,
    ]);
  }

  void _setError(String msg) {
    if (mounted) {
      setState(() {
        errorMessage = msg;
      });
    }
  }

  List<DropdownMenuItem<num>> _unitDropdownMenuItems() {
    return CurrencySetting.instance.unitList.map((unit) {
      return DropdownMenuItem(value: unit, child: Text(unit.toString()));
    }).toList();
  }
}
