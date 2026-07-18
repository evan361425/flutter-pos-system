import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/printer_config.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/services/printer/printer_config_store.dart';
import 'package:possystem/services/printer/printer_manager_service.dart';
import 'package:uuid/uuid.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  late final PrinterSettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PrinterSettingsController()..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scanAndShow() async {
    await _controller.scan();
    if (!mounted) return;

    if (_controller.lastError != null) {
      showSnackBar(_controller.lastError!, context: context);
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _DiscoveredPrintersSheet(
        controller: _controller,
        onSelected: (printer) async {
          Navigator.of(context).pop();
          await _showConfigForm(printer);
        },
      ),
    );
  }

  Future<void> _showConfigForm(DiscoveredPrinter printer) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PrinterConfigForm(
        discovered: printer,
        categories: _categoryNames(),
        onSave: (config) async {
          await _controller.save(config);
          if (!context.mounted) return;
          showSnackBar('Printer saved', context: context);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  List<String> _categoryNames() {
    try {
      return Menu.instance.itemList.map((e) => e.name).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leading: const PopButton(),
            title: const Text('Printer Management'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _controller.isScanning ? null : _scanAndShow,
            icon: _controller.isScanning
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search_outlined),
            label: Text(_controller.isScanning ? 'Scanning...' : 'Scan'),
          ),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _controller.reload,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 96, top: 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _controller.subnetController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'LAN subnet',
                            helperText:
                                'Example: 192.168.1 (scans TCP port 9100)',
                            prefixIcon: Icon(Icons.wifi_outlined),
                          ),
                        ),
                      ),
                      if (_controller.savedPrinters.isEmpty)
                        const _EmptyPrinterList()
                      else
                        ..._controller.savedPrinters.map(
                          (printer) => _SavedPrinterTile(
                            printer: printer,
                            onDelete: () => _controller.delete(printer.id),
                          ),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class PrinterSettingsController extends ChangeNotifier {
  PrinterSettingsController({
    PrinterConfigStore? store,
    PrinterManagerService? manager,
  }) : _store = store ?? PrinterConfigStore.instance,
       _manager = manager ?? PrinterManagerService.instance {
    _store.addListener(notifyListeners);
  }

  final PrinterConfigStore _store;
  final PrinterManagerService _manager;

  final TextEditingController subnetController = TextEditingController(
    text: '192.168.1',
  );

  bool isLoading = true;
  bool isScanning = false;
  String? lastError;
  List<DiscoveredPrinter> discoveredPrinters = const [];

  List<PrinterConfig> get savedPrinters => _store.items;

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();
    try {
      await _store.initialize();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reload() => _store.reload();

  Future<void> scan() async {
    isScanning = true;
    lastError = null;
    discoveredPrinters = const [];
    notifyListeners();

    final found = <DiscoveredPrinter>[];
    final errors = <String>[];
    final subnet = subnetController.text.trim();

    try {
      final results = await Future.wait<List<DiscoveredPrinter>>([
        _manager
            .scanNetworkPrinters(
              subnet,
              hostTimeout: const Duration(milliseconds: 120),
            )
            .catchError((Object error) {
              errors.add('LAN scan failed: $error');
              return <DiscoveredPrinter>[];
            }),
        _manager.scanUsbPrinters().catchError((Object error) {
          errors.add('USB scan failed: $error');
          return <DiscoveredPrinter>[];
        }),
      ]);
      found.addAll(results.expand((e) => e));
    } finally {
      discoveredPrinters = _deduplicate(found);
      lastError = errors.isEmpty ? null : errors.join('\n');
      isScanning = false;
      notifyListeners();
    }
  }

  Future<void> save(PrinterConfig config) => _store.save(config);

  Future<void> delete(String id) => _store.delete(id);

  List<DiscoveredPrinter> _deduplicate(List<DiscoveredPrinter> printers) {
    final seen = <String>{};
    return [
      for (final printer in printers)
        if (seen.add('${printer.type.name}:${printer.address}')) printer,
    ];
  }

  @override
  void dispose() {
    _store.removeListener(notifyListeners);
    subnetController.dispose();
    super.dispose();
  }
}

class _SavedPrinterTile extends StatelessWidget {
  const _SavedPrinterTile({required this.printer, required this.onDelete});

  final PrinterConfig printer;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final categories = printer.assignedCategories.isEmpty
        ? ''
        : '\nCategories: ${printer.assignedCategories.join(', ')}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(
          printer.type == PrinterConnectionType.lan
              ? Icons.wifi_outlined
              : Icons.usb_outlined,
        ),
        title: Text(printer.name),
        subtitle: Text(
          '${printer.type.name.toUpperCase()} | ${printer.address}\n'
          '${printer.role.name} | ${_paperLabel(printer.paperSize)}'
          '$categories',
        ),
        isThreeLine: printer.assignedCategories.isNotEmpty,
        trailing: IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _EmptyPrinterList extends StatelessWidget {
  const _EmptyPrinterList();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Icon(Icons.print_disabled_outlined, size: 48),
          SizedBox(height: 12),
          Text(
            'No managed printers yet.\nTap Scan to discover LAN/USB devices.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DiscoveredPrintersSheet extends StatelessWidget {
  const _DiscoveredPrintersSheet({
    required this.controller,
    required this.onSelected,
  });

  final PrinterSettingsController controller;
  final ValueChanged<DiscoveredPrinter> onSelected;

  @override
  Widget build(BuildContext context) {
    final printers = controller.discoveredPrinters;
    return SafeArea(
      child: printers.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No printers found. Check the subnet, LAN connectivity, or USB permissions.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              shrinkWrap: true,
              children: [
                const ListTile(
                  title: Text('Discovered printers'),
                  subtitle: Text('Tap a device to configure it'),
                ),
                for (final printer in printers)
                  ListTile(
                    leading: Icon(
                      printer.type == PrinterConnectionType.lan
                          ? Icons.wifi_outlined
                          : Icons.usb_outlined,
                    ),
                    title: Text(printer.name),
                    subtitle: Text(printer.address),
                    trailing: const Icon(Icons.navigate_next_outlined),
                    onTap: () => onSelected(printer),
                  ),
              ],
            ),
    );
  }
}

class _PrinterConfigForm extends StatefulWidget {
  const _PrinterConfigForm({
    required this.discovered,
    required this.categories,
    required this.onSave,
  });

  final DiscoveredPrinter discovered;
  final List<String> categories;
  final Future<void> Function(PrinterConfig config) onSave;

  @override
  State<_PrinterConfigForm> createState() => _PrinterConfigFormState();
}

class _PrinterConfigFormState extends State<_PrinterConfigForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  PrinterRole _role = PrinterRole.cashier;
  PaperSize _paperSize = PaperSize.mm80;
  final Set<String> _selectedCategories = {};
  bool _isTesting = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.discovered.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _test() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isTesting = true);
    final ok = await PrinterManagerService.instance.testConnection(_config());
    if (!mounted) return;
    setState(() => _isTesting = false);
    showSnackBar(
      ok ? 'Test print sent successfully' : 'Test print failed',
      context: context,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await widget.onSave(_config());
    if (!mounted) return;
    setState(() => _isSaving = false);
  }

  PrinterConfig _config() {
    return PrinterConfig(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      type: widget.discovered.type,
      address: widget.discovered.address,
      paperSize: _paperSize,
      role: _role,
      assignedCategories: _role == PrinterRole.kitchen
          ? _selectedCategories.toList(growable: false)
          : const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Configure Printer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  widget.discovered.type == PrinterConnectionType.lan
                      ? Icons.wifi_outlined
                      : Icons.usb_outlined,
                ),
                title: Text(widget.discovered.address),
                subtitle: Text(widget.discovered.type.name.toUpperCase()),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Custom name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PrinterRole>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: PrinterRole.values
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role.name)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _role = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PaperSize>(
                initialValue: _paperSize,
                decoration: const InputDecoration(
                  labelText: 'Paper size',
                  border: OutlineInputBorder(),
                ),
                items: PaperSize.values
                    .map(
                      (size) => DropdownMenuItem(
                        value: size,
                        child: Text(_paperLabel(size)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _paperSize = value);
                },
              ),
              if (_role == PrinterRole.kitchen) ...[
                const SizedBox(height: 16),
                Text(
                  'Assigned Categories',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (widget.categories.isEmpty)
                  const Text('No menu categories available yet.')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in widget.categories)
                        FilterChip(
                          label: Text(category),
                          selected: _selectedCategories.contains(category),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add(category);
                              } else {
                                _selectedCategories.remove(category);
                              }
                            });
                          },
                        ),
                    ],
                  ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isTesting ? null : _test,
                      icon: _isTesting
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.receipt_long_outlined),
                      label: const Text('Test Connection'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _paperLabel(PaperSize size) {
  return switch (size) {
    PaperSize.mm58 => '58mm',
    PaperSize.mm80 => '80mm',
  };
}
