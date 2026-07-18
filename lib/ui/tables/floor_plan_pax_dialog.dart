import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';

/// Minimum interactive size for high-stress POS touch screens.
const double kPosTouchTarget = 64;

/// Dialog asking how many guests (pax) sit at a free table.
///
/// Quick-tap chips for 1–6 plus a compact numpad for larger parties.
class FloorPlanPaxDialog extends StatefulWidget {
  const FloorPlanPaxDialog({super.key, required this.tableName, this.maxSeats});

  final String tableName;
  final int? maxSeats;

  /// Returns the confirmed guest count, or null if cancelled.
  static Future<int?> show(
    BuildContext context, {
    required String tableName,
    int? maxSeats,
  }) {
    return showDialog<int>(
      context: context,
      builder: (_) =>
          FloorPlanPaxDialog(tableName: tableName, maxSeats: maxSeats),
    );
  }

  @override
  State<FloorPlanPaxDialog> createState() => _FloorPlanPaxDialogState();
}

class _FloorPlanPaxDialogState extends State<FloorPlanPaxDialog> {
  late int _pax;

  int? get _max =>
      widget.maxSeats != null && widget.maxSeats! > 0 ? widget.maxSeats : null;

  @override
  void initState() {
    super.initState();
    final max = _max;
    _pax = max != null && max > 0 && max < 2 ? max : 2;
    if (max != null && _pax > max) _pax = max;
  }

  @override
  Widget build(BuildContext context) {
    final local = MaterialLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.tableName),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Guests (pax)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              key: const Key('floor_plan.pax'),
              '$_pax',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_max != null)
              Text('Max $_max', style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (var n = 1; n <= 6; n++)
                  _PaxQuickButton(
                    key: Key('floor_plan.pax.quick.$n'),
                    label: '$n',
                    selected: _pax == n,
                    enabled: _max == null || n <= _max!,
                    onTap: () => _setPax(n),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _PaxNumpad(
              onDigit: _appendDigit,
              onBackspace: _backspace,
              onClear: () => _setPax(1),
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          height: kPosTouchTarget,
          child: PopButton(title: local.cancelButtonLabel),
        ),
        SizedBox(
          height: kPosTouchTarget,
          child: FilledButton(
            key: const Key('floor_plan.pax.confirm'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(kPosTouchTarget, kPosTouchTarget),
            ),
            onPressed: _submit,
            child: Text(local.okButtonLabel),
          ),
        ),
      ],
    );
  }

  void _setPax(int value) {
    final max = _max;
    if (value < 1) return;
    if (max != null && value > max) return;
    setState(() => _pax = value);
  }

  void _appendDigit(int digit) {
    final next = _pax == 0 ? digit : (_pax * 10) + digit;
    final max = _max;
    if (max != null && next > max) return;
    if (next > 99) return;
    setState(() => _pax = next);
  }

  void _backspace() {
    final next = _pax ~/ 10;
    setState(() => _pax = next < 1 ? 1 : next);
  }

  void _submit() {
    if (_pax < 1) return;
    final max = _max;
    if (max != null && _pax > max) return;
    Navigator.of(context).pop(_pax);
  }
}

class _PaxQuickButton extends StatelessWidget {
  const _PaxQuickButton({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kPosTouchTarget,
      height: kPosTouchTarget,
      child: selected
          ? FilledButton(onPressed: enabled ? onTap : null, child: Text(label))
          : OutlinedButton(
              onPressed: enabled ? onTap : null,
              child: Text(label),
            ),
    );
  }
}

class _PaxNumpad extends StatelessWidget {
  const _PaxNumpad({
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(
            children: [
              for (final d in row)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: SizedBox(
                      height: kPosTouchTarget,
                      child: OutlinedButton(
                        key: Key('floor_plan.pax.pad.$d'),
                        onPressed: () => onDigit(d),
                        child: Text('$d'),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SizedBox(
                  height: kPosTouchTarget,
                  child: OutlinedButton(
                    key: const Key('floor_plan.pax.pad.clear'),
                    onPressed: onClear,
                    child: const Text('C'),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SizedBox(
                  height: kPosTouchTarget,
                  child: OutlinedButton(
                    key: const Key('floor_plan.pax.pad.0'),
                    onPressed: () => onDigit(0),
                    child: const Text('0'),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SizedBox(
                  height: kPosTouchTarget,
                  child: OutlinedButton(
                    key: const Key('floor_plan.pax.pad.back'),
                    onPressed: onBackspace,
                    child: const Icon(Icons.backspace_outlined),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
