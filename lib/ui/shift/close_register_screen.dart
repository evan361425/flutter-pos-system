import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/services/cart/receipt_service.dart';
import 'package:possystem/services/shift/shift_manager_service.dart';
import 'package:possystem/services/staff/employee_manager_service.dart';

/// End-of-shift UI: count drawer cash → close → print Z-report → lock.
class CloseRegisterScreen extends StatefulWidget {
  const CloseRegisterScreen({super.key});

  @override
  State<CloseRegisterScreen> createState() => _CloseRegisterScreenState();
}

class _CloseRegisterScreenState extends State<CloseRegisterScreen> {
  String _digits = '0';
  bool _busy = false;

  num get _amount {
    final parsed = num.tryParse(_digits);
    return parsed ?? 0;
  }

  void _onDigit(String digit) {
    if (_busy) return;
    setState(() {
      if (_digits == '0' && digit != '.') {
        _digits = digit;
      } else if (digit == '.' && _digits.contains('.')) {
        return;
      } else {
        _digits += digit;
      }
    });
  }

  void _onBackspace() {
    if (_busy || _digits.isEmpty) return;
    setState(() {
      _digits = _digits.length == 1
          ? '0'
          : _digits.substring(0, _digits.length - 1);
    });
  }

  void _onClear() {
    if (_busy) return;
    setState(() => _digits = '0');
  }

  Future<void> _submit() async {
    if (_busy) return;
    final shift = ShiftManagerService.instance.currentShift;
    if (shift == null || !shift.isOpen) {
      showSnackBar('No open shift', context: context);
      return;
    }

    setState(() => _busy = true);
    try {
      final closed = await ShiftManagerService.instance.closeShift(_amount);
      final metrics = await Seller.instance.getShiftReport(closed.id);

      unawaited(
        ReceiptService.instance.printZReport(closed, metrics).catchError((
          Object e,
          StackTrace stack,
        ) {
          Log.err(e, 'z_report_print_failed', stack);
        }),
      );

      Log.ger('close_register_done', {
        'shiftId': closed.id,
        'expected': metrics.expectedCash,
        'actual': closed.actualEndingCash,
        'variance': metrics.variance,
      });

      EmployeeManagerService.instance.logout();
      if (!mounted) return;
      context.goNamed(AppRouteNames.lock);
    } catch (e, stack) {
      Log.err(e, 'close_register_failed', stack);
      if (!mounted) return;
      setState(() => _busy = false);
      showSnackBar('Failed to close register', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shift = ShiftManagerService.instance.currentShift;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Close Register'),
        leading: const PopButton(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            Icon(
              Icons.point_of_sale_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Counted Cash in Drawer',
              style: theme.textTheme.headlineSmall,
            ),
            if (shift != null) ...[
              const SizedBox(height: 8),
              Text(
                'Starting float: ${shift.startingCash.toCurrency()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              key: const Key('close_register.amount'),
              _amount.toCurrency(),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(flex: 1),
            _CashPad(
              enabled: !_busy,
              onDigit: _onDigit,
              onBackspace: _onBackspace,
              onClear: _onClear,
              onSubmit: _submit,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FilledButton.icon(
                key: const Key('close_register.submit'),
                onPressed: _busy ? null : _submit,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_outline),
                label: const Text('Close & Print Z-Report'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CashPad extends StatelessWidget {
  const _CashPad({
    required this.enabled,
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    required this.onSubmit,
  });

  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', 'OK'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          for (final row in keys)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final key in row)
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: FilledButton.tonal(
                        key: Key('close_register.key.$key'),
                        onPressed: !enabled
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                switch (key) {
                                  case 'OK':
                                    onSubmit();
                                  default:
                                    onDigit(key);
                                }
                              },
                        style: FilledButton.styleFrom(
                          shape: const CircleBorder(),
                          textStyle: Theme.of(context).textTheme.headlineSmall,
                        ),
                        child: Text(key),
                      ),
                    ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                key: const Key('close_register.clear'),
                onPressed: enabled ? onClear : null,
                child: const Text('Clear'),
              ),
              TextButton.icon(
                key: const Key('close_register.backspace'),
                onPressed: enabled ? onBackspace : null,
                icon: const Icon(Icons.backspace_outlined),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
