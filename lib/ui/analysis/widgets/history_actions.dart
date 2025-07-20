import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';

class HistoryCleanDialog extends StatefulWidget {
  const HistoryCleanDialog({super.key});

  static Future<DateTime?> show(BuildContext context) {
    return showAdaptiveDialog<DateTime>(
      context: context,
      builder: (context) => const HistoryCleanDialog(),
    );
  }

  @override
  State<HistoryCleanDialog> createState() => _HistoryCleanDialogState();
}

enum _Mode {
  lastYear,
  sixMonthsAgo,
  custom;
}

class _HistoryCleanDialogState extends State<HistoryCleanDialog> {
  _Mode mode = _Mode.lastYear;
  DateTime? customDate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final local = MaterialLocalizations.of(context);

    return AlertDialog.adaptive(
      title: Text(S.analysisHistoryActionClear),
      scrollable: true,
      content: Column(children: [
        RadioListTile.adaptive(
          groupValue: mode,
          value: _Mode.lastYear,
          title: Text(S.analysisHistoryActionClearLastYear),
          subtitle: Text(S.analysisHistoryActionClearSubtitle(DateTime(now.year - 1, now.month, now.day))),
          onChanged: _setMode,
        ),
        RadioListTile.adaptive(
          groupValue: mode,
          value: _Mode.sixMonthsAgo,
          title: Text(S.analysisHistoryActionClearLast6Months),
          subtitle: Text(S.analysisHistoryActionClearSubtitle(DateTime(now.year, now.month - 6, now.day))),
          onChanged: _setMode,
        ),
        RadioListTile.adaptive(
          groupValue: mode,
          value: _Mode.custom,
          title: Text(S.analysisHistoryActionClearCustom),
          subtitle: Text(customDate == null
              ? S.analysisHistoryActionClearCustomSubtitle
              : S.analysisHistoryActionClearSubtitle(customDate!)),
          toggleable: true,
          onChanged: _setMode,
        ),
      ]),
      actions: [
        PopButton(title: local.cancelButtonLabel),
        TextButton(
          onPressed: () => _onOk(context),
          child: Text(local.okButtonLabel),
        ),
      ],
    );
  }

  Future<void> _onOk(BuildContext context) async {
    final date = switch (mode) {
      _Mode.lastYear => DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day),
      _Mode.sixMonthsAgo => DateTime(DateTime.now().year, DateTime.now().month - 6, DateTime.now().day),
      _Mode.custom => customDate,
    };

    if (date != null) {
      final ok = await _confirmClean(context, date);
      if (context.mounted && ok) {
        context.pop(date);
      }
    }
  }

  void _setMode(_Mode? value) async {
    if (mounted) {
      // only custom mode toggleable (nullable)
      if (value == _Mode.custom || value == null) {
        await _selectCustomDate(context);
      } else {
        setState(() => mode = value);
      }
    }
  }

  Future<void> _selectCustomDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2021, 1),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() {
        mode = _Mode.custom;
        customDate = DateTime(selected.year, selected.month, selected.day);
      });
    }
  }

  Future<bool> _confirmClean(BuildContext context, DateTime notAfter) async {
    final metric = await Seller.instance.getMetrics(DateTime(2021, 1), notAfter);

    var ok = false;
    if (context.mounted) {
      ok = await ConfirmDialog.show(
        context,
        title: S.analysisHistoryActionClearConfirmTitle,
        content: S.analysisHistoryActionClearConfirmContent(notAfter, metric.count),
      );
    }

    return ok;
  }
}

class HistoryScheduleResetNoDialog extends StatelessWidget {
  final GlobalKey<_PeriodSelectorState> _periodKey;
  final Period? initialPeriod;

  const HistoryScheduleResetNoDialog._(GlobalKey<_PeriodSelectorState> key, this.initialPeriod) : _periodKey = key;

  static Future<Period?> show(BuildContext context) async {
    final key = GlobalKey<_PeriodSelectorState>();
    final origin = Period.fromCache();
    final period = await showAdaptiveDialog<Period>(
      context: context,
      builder: (context) => HistoryScheduleResetNoDialog._(key, origin.isInvalid ? null : origin),
    );

    return period;
  }

  @override
  Widget build(BuildContext context) {
    final local = MaterialLocalizations.of(context);
    return AlertDialog.adaptive(
      title: Text(S.analysisHistoryActionScheduleResetNoTitle),
      scrollable: true,
      content: Column(children: [
        HintText(S.analysisHistoryActionScheduleResetNoHint),
        _PeriodSelector(
          key: _periodKey,
          initialPeriod: initialPeriod ?? const Period(values: [1], unit: PeriodUnit.xDayOfEachMonth),
        ),
      ]),
      actions: [
        PopButton(title: local.cancelButtonLabel),
        TextButton(
          key: const Key('history.action.schedule_reset_no.ok'),
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

  Period get period => Period(values: _values.toList()..sort(), unit: _unit);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DropdownButtonFormField<PeriodUnit>(
          value: _unit,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          items: [
            for (final unit in PeriodUnit.values)
              DropdownMenuItem<PeriodUnit>(
                value: unit,
                child: Text(S.analysisHistoryActionScheduleResetNoPeriod(unit.name)),
              ),
          ],
          onChanged: _updateUnit,
        ),
        const SizedBox(width: 8),
        _buildNumberField(),
        if (_values.isNotEmpty) _buildNextHint(),
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
    _unit = widget.initialPeriod.unit;
    _values = widget.initialPeriod.values.toSet();
    _numberController = TextEditingController(text: _values.first.toString());
    _numberController.addListener(() {
      _values
        ..clear()
        ..add(int.tryParse(_numberController.text) ?? 1);
      _notifier.value++;
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    _notifier.dispose();
    super.dispose();
  }

  Widget _buildNumberField() {
    return switch (_unit) {
      PeriodUnit.everyXDays || PeriodUnit.everyXWeeks => TextFormField(
          key: const Key('history.action.schedule_reset_no.x_text_field'),
          controller: _numberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: 'X = '),
          validator: Validator.positiveInt('x', minimum: 1, maximum: 10000),
        ),
      PeriodUnit.xDayOfEachWeek => DropdownButtonFormField<int>(
          hint: _buildValuesHint(),
          icon: const Icon(Icons.arrow_drop_down),
          validator: _validateValues,
          items: [
            for (var day = 1; day <= 7; day++)
              DropdownMenuItem<int>(
                value: day,
                child: SizedBox(
                  width: 230,
                  child: StatefulBuilder(
                    builder: (context, rebuild) {
                      return CheckboxListTile(
                        dense: true,
                        value: _values.contains(day),
                        title: Text(S.analysisHistoryActionScheduleResetNoWeekday(DateTime(2025, 9, day))),
                        onChanged: _updateValuesCallback(day, rebuild),
                      );
                    },
                  ),
                ),
              ),
          ],
          onChanged: _noop,
        ),
      PeriodUnit.xDayOfEachMonth => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DropdownButtonFormField<int>(
            key: const Key('history.action.schedule_reset_no.month_day'),
            hint: _buildValuesHint(),
            icon: const Icon(Icons.arrow_drop_down),
            validator: _validateValues,
            items: [
              for (var day = 1; day <= 31; day++)
                DropdownMenuItem<int>(
                  value: day,
                  child: Center(
                    child: SizedBox(
                      width: 220,
                      child: StatefulBuilder(
                        builder: (context, rebuild) {
                          return CheckboxListTile(
                            value: _values.contains(day),
                            title: Text(S.analysisHistoryActionScheduleResetNoMonthDay(day)),
                            onChanged: _updateValuesCallback(day, rebuild),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
            onChanged: _noop,
          ),
          HintText(S.analysisHistoryActionScheduleResetNoMonthDayHint),
        ]),
    };
  }

  Widget _buildValuesHint() {
    return ValueListenableBuilder(
      valueListenable: _notifier,
      builder: (context, value, child) {
        if (_values.isEmpty) {
          return Text(S.analysisHistoryActionScheduleResetNoDaysEmpty);
        }

        final v = _values.toList();
        v.sort();
        return Text(v.join(', '));
      },
    );
  }

  Widget _buildNextHint() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ValueListenableBuilder(
        valueListenable: _notifier,
        builder: (context, value, child) {
          final today = Period.today();
          return Text(
            _values.isEmpty ? '' : S.analysisHistoryActionScheduleResetNoNext(period.nextDate(today, today)),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          );
        },
      ),
    );
  }

  void Function(bool?) _updateValuesCallback(int day, void Function(void Function()) rebuild) {
    return (bool? checked) {
      if (checked == true) {
        _values.add(day);
      } else {
        _values.remove(day);
      }
      _notifier.value++;
      rebuild(() {});
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
    return _values.isEmpty ? S.analysisHistoryActionScheduleResetNoErrorDaysEmpty : null;
  }

  Period? submit() {
    Period? result;
    if (_formKey.currentState?.validate() ?? false) {
      result = period;
    }

    return result;
  }
}

void _noop(int? _) {}
