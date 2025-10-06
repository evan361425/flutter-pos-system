import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/device.dart';
import 'package:possystem/translator.dart';

class DeviceView extends StatefulWidget {
  final Device device;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLogPress;

  const DeviceView({
    super.key,
    required this.device,
    this.trailing,
    this.onTap,
    this.onLogPress,
  });

  @override
  State<DeviceView> createState() => _DeviceViewState();
}

class _DeviceViewState extends State<DeviceView> {
  ValueNotifier<bool> waiting = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _buildCard(),
      ListenableBuilder(
        listenable: waiting,
        builder: (context, child) {
          if (waiting.value) {
            return const _Backdrop(child: CircularProgressIndicator.adaptive());
          }

          return const SizedBox.shrink();
        },
      ),
    ]);
  }

  Widget _buildCard() {
    return ListenableBuilder(
      listenable: widget.device,
      builder: (context, child) {
        return widget.device.connected ? _buildConnected() : _buildDisconnected();
      },
    );
  }

  Widget _buildConnected() {
    return Card(
      shadowColor: Colors.green,
      elevation: 4,
      margin: const EdgeInsets.fromLTRB(kHorizontalSpacing, 0, kHorizontalSpacing, kInternalSpacing),
      child: _wrapWithInkWell(Column(
        children: [
          ListTile(
            title: Text(widget.device.name),
            leading: Icon(_getDeviceIcon()),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HintText('Connected'),
                HintText('${widget.device.address}:${widget.device.port}'),
                if (widget.device.isPaired) 
                  HintText('Paired', style: TextStyle(color: Colors.green[600])),
              ],
            ),
            trailing: widget.trailing,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (!widget.device.isPaired)
              OutlinedButton(
                onPressed: _initiatePairing,
                child: const Text('Pair'),
              ),
            const SizedBox(width: 8.0),
            FilledButton(
              onPressed: disconnect,
              child: const Text('Disconnect'),
            ),
            const SizedBox(width: 8.0),
          ]),
          const SizedBox(height: 4),
        ],
      )),
    );
  }

  Widget _buildDisconnected() {
    return Card(
      shadowColor: Colors.amber,
      elevation: 4,
      margin: const EdgeInsets.fromLTRB(kHorizontalSpacing, 0, kHorizontalSpacing, kInternalSpacing),
      child: _wrapWithInkWell(Column(
        children: [
          ListTile(
            title: Text(widget.device.name),
            leading: Icon(_getDeviceIcon(), color: Colors.grey),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HintText('Disconnected'),
                HintText('${widget.device.address}:${widget.device.port}'),
              ],
            ),
            trailing: widget.trailing,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            FilledButton(
              onPressed: connect,
              child: const Text('Connect'),
            ),
            const SizedBox(width: 8.0),
          ]),
          const SizedBox(height: 4.0),
        ],
      )),
    );
  }

  Widget _wrapWithInkWell(Widget child) {
    if (widget.onTap == null) {
      return child;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: widget.onTap,
      onLongPress: widget.onLogPress,
      child: child,
    );
  }

  IconData _getDeviceIcon() {
    switch (widget.device.deviceType) {
      case DeviceType.cashier:
        return Icons.point_of_sale;
      case DeviceType.kitchen:
        return Icons.kitchen;
      case DeviceType.display:
        return Icons.tv;
      default:
        return Icons.devices;
    }
  }

  void connect() async {
    if (!waiting.value) {
      waiting.value = true;

      final success = await showSnackbarWhenFutureError(
        widget.device.connect(),
        'device_view_connect',
        context: context,
      );
      
      if (success && mounted) {
        showSnackBar('Connected to ${widget.device.name}', context: context);
      }

      waiting.value = false;
    }
  }

  void disconnect() async {
    if (!waiting.value) {
      waiting.value = true;

      await showSnackbarWhenFutureError(
        widget.device.disconnect(),
        'device_view_disconnect',
        context: context,
      );

      waiting.value = false;
    }
  }

  void _initiatePairing() async {
    if (!widget.device.connected) {
      showSnackBar('Device must be connected before pairing', context: context);
      return;
    }

    // Show pin dialog
    final pin = await _showPinDialog();
    if (pin != null) {
      waiting.value = true;
      
      final success = await showSnackbarWhenFutureError(
        widget.device.sendPairingRequest(pin),
        'device_pairing_request',
        context: context,
      );

      if (success && mounted) {
        showSnackBar('Pairing request sent', context: context);
      }

      waiting.value = false;
    }
  }

  Future<String?> _showPinDialog() async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pair Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the 4-digit PIN shown on the other device:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'PIN',
                hintText: '1234',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.length == 4) {
                Navigator.of(context).pop(controller.text);
              }
            },
            child: const Text('Pair'),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  final Widget child;

  const _Backdrop({required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: child),
      ),
    );
  }
}