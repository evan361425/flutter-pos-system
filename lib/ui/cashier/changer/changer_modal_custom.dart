import 'package:flutter/material.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/settings/currency_setting.dart';

class ChangerModalCustom extends StatefulWidget {
  final VoidCallback afterFavoriteAdded;

  const ChangerModalCustom({
    Key? key,
    required this.afterFavoriteAdded,
  }) : super(key: key);

  @override
  State<ChangerModalCustom> createState() => ChangerModalCustomState();
}

class ChangerModalCustomState extends State<ChangerModalCustom> {
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
  late FocusNode errorFocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final actions = Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      FilledButton(
        key: const Key('changer.custom.add_favorite'),
        onPressed: handleAddFavorite,
        child: const Text('新增常用'),
      ),
    ]);

    final sourceEntry = _wrapInRow(
      TextFormField(
        key: const Key('changer.custom.source.count'),
        controller: sourceCount,
        keyboardType: TextInputType.number,
        onChanged: handleCountChanged,
        decoration: const InputDecoration(labelText: '數量'),
        validator: Validator.positiveInt('數量', minimum: 1),
      ),
      DropdownButtonFormField<num>(
        key: const Key('changer.custom.source.unit'),
        value: sourceUnit,
        hint: const Text('幣值'),
        validator: Validator.positiveNumber('幣值'),
        onChanged: handleUnitChanged,
        items: _unitDropdownMenuItems(),
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
    final targetEntries = <Widget>[
      for (var entry in targets.asMap().entries)
        Padding(
          padding: const EdgeInsets.only(top: kSpacing1),
          child: _wrapInRow(
              TextFormField(
                key: Key('changer.custom.target.${entry.key}.count'),
                controller: entry.key == 0 ? targetController : null,
                initialValue:
                    entry.key == 0 ? null : entry.value.count?.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '數量'),
                validator: Validator.positiveInt('', allowNull: true),
                onSaved: (value) =>
                    entry.value.count = int.tryParse(value ?? ''),
              ),
              DropdownButtonFormField<num>(
                key: Key('changer.custom.target.${entry.key}.unit'),
                value: entry.value.unit,
                hint: const Text('幣值'),
                onChanged: (value) => setState(() => entry.value.unit = value),
                onSaved: (value) => entry.value.unit = value,
                items: ChangerModalCustomState._unitDropdownMenuItems(),
              ),
              entry.key == 0
                  ? null
                  : IconButton(
                      onPressed: () => setState(() {
                        targets.removeAt(entry.key);
                      }),
                      color: theme.colorScheme.error,
                      icon: const Icon(Icons.remove_circle_sharp),
                    )),
        )
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(kSpacing2),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              actions,
              const TextDivider(label: '從收銀機中拿出'),
              sourceEntry,
              const TextDivider(label: '換'),
              Focus(
                focusNode: errorFocus,
                child: Builder(builder: (context) {
                  return Focus.of(context).hasFocus
                      ? Center(
                          child: Text(
                            errorMessage,
                            style: theme.textTheme.bodyMedium!
                                .copyWith(color: theme.colorScheme.error),
                          ),
                        )
                      : const SizedBox();
                }),
              ),
              ...targetEntries,
              // add bottom
              const SizedBox(height: kSpacing1),
              OutlinedButton(
                onPressed: () => setState(() {
                  targets.add(CashierChangeEntryObject());
                }),
                child: const Icon(KIcons.add),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    sourceCount = TextEditingController(text: '1');
    targetController = TextEditingController();
    errorFocus = FocusNode();
  }

  @override
  void dispose() {
    sourceCount.dispose();
    targetController.dispose();
    errorFocus.dispose();
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
          for (var target in _mergedTargets().entries)
            CashierChangeEntryObject(count: target.value, unit: target.key)
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
        ...{
          for (var target in _mergedTargets().entries)
            Cashier.instance.indexOf(target.key): target.value
        },
      });
      return true;
    } else {
      _setError('$sourceUnit 元不夠換');
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
    final isValid = formKey.currentState!.validate();

    if (isValid) {
      formKey.currentState?.save();

      final count = int.parse(sourceCount.text);
      var total = count * sourceUnit!;

      for (var target in targets) {
        total -= target.total;
      }

      if (total == 0) {
        return true;
      }

      var msg = '$count 個 $sourceUnit 元沒辦法換';
      for (var target in targets) {
        if (!target.isEmpty) {
          msg += '\n- ${target.count} 個 ${target.unit} 元';
        }
      }
      _setError(msg);
    }

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
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Flexible(flex: 1, child: a),
      const SizedBox(width: kSpacing1),
      Flexible(flex: 1, child: b),
      if (c != null) c,
    ]);
  }

  void _setError(String msg) {
    setState(() {
      errorFocus.requestFocus();
      errorMessage = msg;
    });
  }

  static List<DropdownMenuItem<num>> _unitDropdownMenuItems() {
    return CurrencySetting.instance.unitList.map((unit) {
      return DropdownMenuItem(value: unit, child: Text(unit.toString()));
    }).toList();
  }
}
