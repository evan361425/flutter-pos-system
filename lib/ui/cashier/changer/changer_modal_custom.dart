import 'package:flutter/material.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/components/style/toast.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/providers/currency_provider.dart';

class ChangerModalCustom extends StatefulWidget {
  final void Function() handleFavoriteAdded;

  const ChangerModalCustom({
    Key? key,
    required this.handleFavoriteAdded,
  }) : super(key: key);

  @override
  ChangerModalCustomState createState() => ChangerModalCustomState();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final actions = Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ElevatedButton(
        onPressed: handleFavorite,
        child: Text('新增常用'),
      ),
    ]);

    final sourceEntry = _wrapInRow(
      TextFormField(
        controller: sourceCount,
        keyboardType: TextInputType.number,
        onChanged: handleCountChanged,
        decoration: InputDecoration(labelText: '數量'),
        validator: Validator.positiveInt('數量', minimum: 1),
      ),
      DropdownButtonFormField<num>(
        key: Key('changer.source'),
        value: sourceUnit,
        hint: Text('幣值'),
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
                controller: entry.key == 0 ? targetController : null,
                initialValue:
                    entry.key == 0 ? null : entry.value.count?.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '數量'),
                validator: Validator.positiveInt('', allowNull: true),
                onSaved: (value) =>
                    entry.value.count = int.tryParse(value ?? ''),
              ),
              DropdownButtonFormField<num>(
                key: Key('changer.target.${entry.key}'),
                value: entry.value.unit,
                hint: Text('幣值'),
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
                      color: theme.errorColor,
                      icon: Icon(Icons.remove_circle_sharp),
                    )),
        )
    ];

    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            actions,
            Divider(),
            Text('從收銀機中拿出'),
            sourceEntry,
            const TextDivider(label: '換'),
            ...targetEntries,
            // add bottom
            const SizedBox(height: kSpacing1),
            OutlinedButton(
              onPressed: () => setState(() {
                targets.add(CashierChangeEntryObject());
              }),
              child: Icon(KIcons.add),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    sourceCount.dispose();
    targetController.dispose();
    super.dispose();
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
      Toast.show(context, '$sourceUnit 元不夠換');
      return false;
    }
  }

  void handleCountChanged(String value) {
    _changeSource(int.tryParse(value));
  }

  void handleFavorite() async {
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

    widget.handleFavoriteAdded();
  }

  void handleUnitChanged(num? value) {
    setState(() {
      sourceUnit = value;

      _changeSource(int.tryParse(sourceCount.text));
    });
  }

  @override
  void initState() {
    super.initState();
    sourceCount = TextEditingController(text: '1');
    targetController = TextEditingController();
  }

  bool validate() {
    final isValid = formKey.currentState?.validate() ?? false;

    if (isValid) {
      formKey.currentState?.save();

      final count = int.parse(sourceCount.text);
      var total = count * sourceUnit!;

      targets.forEach((target) {
        total -= target.total;
      });

      if (total == 0) {
        return true;
      }

      var msg = '$count 個 $sourceUnit 元沒辦法換';
      targets.forEach((target) {
        if (!target.isEmpty) {
          msg += '\n- ${target.count} 個 ${target.unit} 元';
        }
      });
      Toast.show(context, msg);
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

    targets.forEach((target) {
      if (!target.isEmpty) {
        deltas[target.unit!] = deltas[target.unit!] == null
            ? target.count!
            : deltas[target.unit!]! + target.count!;
      }
    });

    return deltas;
  }

  Widget _wrapInRow(Widget a, Widget b, [Widget? c]) {
    return Row(children: [
      Expanded(child: a),
      const SizedBox(width: kSpacing1),
      Expanded(child: b),
      if (c != null) c,
    ]);
  }

  static List<DropdownMenuItem<num>> _unitDropdownMenuItems() {
    return CurrencyProvider.instance.unitList.map((unit) {
      return DropdownMenuItem(value: unit, child: Text(unit.toString()));
    }).toList();
  }
}
