import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/services/shift/shift_manager_service.dart';
import 'package:possystem/services/staff/employee_manager_service.dart';
import 'package:possystem/ui/shift/open_register_dialog.dart';

/// Full-screen PIN pad that unlocks the shared POS terminal.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxDigits = 6;

  String _pin = '';
  bool _busy = false;
  bool _error = false;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _shakeController, curve: .easeOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_busy || _pin.length >= _maxDigits) return;
    setState(() {
      _error = false;
      _pin += digit;
    });
    if (_pin.length >= 4 && _pin.length == _maxDigits) {
      _submit();
    }
  }

  void _onBackspace() {
    if (_busy || _pin.isEmpty) return;
    setState(() {
      _error = false;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  void _onClear() {
    if (_busy) return;
    setState(() {
      _error = false;
      _pin = '';
    });
  }

  Future<void> _submit() async {
    if (_busy || _pin.length < 4) return;

    setState(() => _busy = true);
    final ok = await EmployeeManagerService.instance.login(_pin);
    if (!mounted) return;

    if (ok) {
      if (!ShiftManagerService.instance.hasOpenShift) {
        final opened = await showOpenRegisterDialog(context);
        if (!mounted) return;
        if (!opened) {
          EmployeeManagerService.instance.logout();
          setState(() {
            _busy = false;
            _pin = '';
          });
          return;
        }
      }
      context.goNamed(AppRouteNames.floorPlan);
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _busy = false;
      _error = true;
      _pin = '';
    });
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Icon(
              Icons.lock_outline,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Enter PIN',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock this terminal to continue',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: .center,
                children: List.generate(_maxDigits, (i) {
                  final filled = i < _pin.length;
                  return Container(
                    key: Key('lock.dot.$i'),
                    margin: const .symmetric(horizontal: 6),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: .circle,
                      color: filled
                          ? (_error ? colorScheme.error : colorScheme.primary)
                          : colorScheme.outlineVariant,
                    ),
                  );
                }),
              ),
            ),
            if (_error) ...[
              const SizedBox(height: 12),
              Text(
                'Incorrect PIN',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
            const Spacer(flex: 2),
            _PinPad(
              enabled: !_busy,
              onDigit: _onDigit,
              onBackspace: _onBackspace,
              onClear: _onClear,
              onSubmit: _submit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PinPad extends StatelessWidget {
  const _PinPad({
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
      ['C', '0', 'OK'],
    ];

    return Padding(
      padding: const .symmetric(horizontal: 48),
      child: Column(
        children: [
          for (final row in keys)
            Padding(
              padding: const .only(bottom: 12),
              child: Row(
                mainAxisAlignment: .spaceEvenly,
                children: [
                  for (final key in row)
                    _PinKey(
                      label: key,
                      enabled: enabled,
                      onPressed: () {
                        switch (key) {
                          case 'C':
                            onClear();
                          case 'OK':
                            onSubmit();
                          default:
                            onDigit(key);
                        }
                      },
                    ),
                ],
              ),
            ),
          TextButton.icon(
            key: const Key('lock.backspace'),
            onPressed: enabled ? onBackspace : null,
            icon: const Icon(Icons.backspace_outlined),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: FilledButton.tonal(
        key: Key('lock.key.$label'),
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          textStyle: Theme.of(context).textTheme.headlineSmall,
        ),
        child: Text(label),
      ),
    );
  }
}
