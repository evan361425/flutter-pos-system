import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/repository/seller.dart';

class HistoryCleanDialog {
  static Future<DateTime?> show(BuildContext context) async {
    final result = await showDatePicker(
      context: context,
      firstDate: DateTime(2021, 1),
      lastDate: DateTime.now(),
      helpText: '選擇日期來清除該日以前（不含）的訂單紀錄。',
    );

    return result;
  }

  static Future<bool> confirm(BuildContext context, DateTime notAfter) async {
    final metric = await Seller.instance.getMetrics(DateTime(2021, 1), notAfter);

    var ok = false;
    if (context.mounted) {
      ok = await ConfirmDialog.show(
        context,
        title: '清除訂單紀錄？',
        content: '確定要清除到 ${notAfter.toLocal().toString().split(' ')[0]} 以前（不含當日）的訂單紀錄嗎？\n'
            '這將會清除 ${metric.count} 筆訂單。',
      );
    }

    if (ok) {
      await Seller.instance.clean(notAfter);
      return true;
    }

    return false;
  }
}

class HistoryScheduleResetIDDialog extends StatelessWidget {
  final GlobalKey<_PeriodSelectorState> _periodKey;

  const HistoryScheduleResetIDDialog._(GlobalKey<_PeriodSelectorState> key) : _periodKey = key;

  static Future<Period?> show(BuildContext context) async {
    final key = GlobalKey<_PeriodSelectorState>();
    final period = await showAdaptiveDialog<Period>(
      context: context,
      builder: (context) => HistoryScheduleResetIDDialog._(key),
    );

    return period;
  }

  @override
  Widget build(BuildContext context) {
    final local = MaterialLocalizations.of(context);
    return AlertDialog.adaptive(
      title: const Text('自動重置訂單編號'),
      content: Column(children: [
        const HintText('選擇區間來安排未來的訂單編號重置。'),
        _PeriodSelector(
          key: _periodKey,
          initialPeriod: const Period(values: [1], unit: PeriodUnit.xDayOfEachMonth),
        ),
      ]),
      actions: [
        PopButton(key: const Key('pop'), title: local.cancelButtonLabel),
        TextButton(
          onPressed: () {
            final period = _periodKey.currentState?.submit();
            if (period != null && context.mounted) {
              context.pop(period);
            }
          },
          child: Text(local.okButtonLabel),
        ),
      ],
    );
  }
}

class _PeriodSelector extends StatefulWidget {
  final Period initialPeriod;

  const _PeriodSelector({
    super.key,
    required this.initialPeriod,
  });

  @override
  State<_PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<_PeriodSelector> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<int> _notifier = ValueNotifier<int>(1);
  late TextEditingController _numberController;
  late Set<int> _values;
  late PeriodUnit _unit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DropdownButtonFormField<PeriodUnit>(
          value: _unit,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          items: [
            for (final unit in PeriodUnit.values)
              DropdownMenuItem<PeriodUnit>(
                value: unit,
                child: Text(unit.name),
              ),
          ],
          onChanged: _updateUnit,
        ),
        const SizedBox(width: 8),
        _buildNumberField(),
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
    _unit = widget.initialPeriod.unit;
    _values = widget.initialPeriod.values.toSet();
    _numberController = TextEditingController(text: _values.first.toString());
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Widget _buildNumberField() {
    return switch (_unit) {
      PeriodUnit.everyXDays || PeriodUnit.everyXWeeks => TextFormField(
          controller: _numberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: 'x = '),
          validator: Validator.positiveInt('x', minimum: 1),
        ),
      PeriodUnit.xDayOfEachWeek => DropdownButtonFormField<int>(
          hint: _buildValuesHint(),
          icon: const Icon(Icons.arrow_drop_down),
          validator: _validateValues,
          items: [
            for (var day = 1; day <= 7; day++)
              DropdownMenuItem<int>(
                value: day,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return CheckboxListTile(
                      value: _values.contains(day),
                      title: Text('星期 $day'),
                      onChanged: _updateValuesCallback(day),
                    );
                  },
                ),
              ),
          ],
          onChanged: (_) {},
        ),
      PeriodUnit.xDayOfEachMonth => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DropdownButtonFormField<int>(
            hint: _buildValuesHint(),
            icon: const Icon(Icons.arrow_drop_down),
            validator: _validateValues,
            items: [
              for (var day = 1; day <= 31; day++)
                DropdownMenuItem<int>(
                  value: day,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return CheckboxListTile(
                        value: _values.contains(day),
                        title: Text('第 $day 天'),
                        onChanged: _updateValuesCallback(day),
                      );
                    },
                  ),
                ),
            ],
            onChanged: (_) {},
          ),
          const HintText('若選擇第 31 天，則每月自動調整為最後一天，如 2 月和 4 月'),
        ]),
    };
  }

  Widget _buildValuesHint() {
    return ValueListenableBuilder(
      valueListenable: _notifier,
      builder: (context, value, child) {
        return Text(_values.isEmpty ? '無' : _values.join(', '));
      },
    );
  }

  void Function(bool?) _updateValuesCallback(int day) {
    return (bool? checked) {
      if (checked == true) {
        _values.add(day);
      } else {
        _values.remove(day);
      }
      _notifier.value++;
    };
  }

  void _updateUnit(PeriodUnit? value) {
    if (value != null) {
      setState(() {
        _unit = value;
        _values = {1}; // Reset
      });
    }
  }

  String? _validateValues(int? value) {
    return _values.isEmpty ? '請至少選擇一個日子' : null;
  }

  Period? submit() {
    if (_formKey.currentState?.validate() ?? false) {
      return Period(values: _values.toList(), unit: _unit);
    }
    return null;
  }
}
