import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/shift/shift_manager_service.dart';
import 'package:possystem/services/staff/employee_manager_service.dart';

/// Modal asking for the cash float before the floor plan is reachable.
///
/// Returns `true` when a shift was opened successfully.
Future<bool> showOpenRegisterDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const OpenRegisterDialog(),
  );
  return result ?? false;
}

class OpenRegisterDialog extends StatefulWidget {
  const OpenRegisterDialog({super.key});

  @override
  State<OpenRegisterDialog> createState() => _OpenRegisterDialogState();
}

class _OpenRegisterDialogState extends State<OpenRegisterDialog> {
  final _controller = TextEditingController(text: '0');
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !(_formKey.currentState?.validate() ?? false)) return;

    final employee = EmployeeManagerService.instance.currentEmployee;
    if (employee == null) {
      setState(() => _error = 'Not logged in');
      return;
    }

    final amount = num.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (amount == null || amount < 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ShiftManagerService.instance.openShift(
        startingCash: amount,
        employeeId: employee.id,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e, stack) {
      Log.err(e, 'open_register_failed', stack);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Open Register'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter the starting cash float in the drawer.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('open_register.amount'),
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Starting Cash',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (value) {
                final n = num.tryParse(
                  (value ?? '').trim().replaceAll(',', '.'),
                );
                if (n == null || n < 0) return 'Invalid amount';
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('open_register.cancel'),
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('open_register.submit'),
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Open'),
        ),
      ],
    );
  }
}
