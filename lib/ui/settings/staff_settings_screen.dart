import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/staff/employee.dart';
import 'package:possystem/services/staff/employee_manager_service.dart';

/// Manager-only CRUD UI for offline staff accounts.
class StaffSettingsScreen extends StatefulWidget {
  const StaffSettingsScreen({super.key});

  @override
  State<StaffSettingsScreen> createState() => _StaffSettingsScreenState();
}

class _StaffSettingsScreenState extends State<StaffSettingsScreen> {
  late Future<List<Employee>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = EmployeeManagerService.instance.getEmployees();
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  Future<void> _openEditor({Employee? employee}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _EmployeeFormSheet(employee: employee),
    );
    if (saved == true && mounted) await _refresh();
  }

  Future<void> _delete(Employee employee) async {
    final ok = await ConfirmDialog.show(
      context,
      title: 'Delete ${employee.name}?',
      content: 'This employee will no longer be able to unlock the terminal.',
    );
    if (!ok || !mounted) return;

    try {
      await EmployeeManagerService.instance.deleteEmployee(employee.id);
      if (!mounted) return;
      showSnackBar('Employee deleted', context: context);
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      showSnackBar(e.toString(), context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff'),
        leading: const PopButton(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('staff.add'),
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add employee'),
      ),
      body: FutureBuilder<List<Employee>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != .done) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final employees = snapshot.data ?? const <Employee>[];
          if (employees.isEmpty) {
            return EmptyBody(
              onPressed: () => _openEditor(),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const .only(bottom: 88),
              itemCount: employees.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final employee = employees[index];
                return ListTile(
                  key: Key('staff.item.${employee.id}'),
                  leading: CircleAvatar(
                    child: Icon(
                      employee.isManager
                          ? Icons.admin_panel_settings_outlined
                          : Icons.person_outline,
                    ),
                  ),
                  title: Text(employee.name),
                  subtitle: Text(
                    employee.isManager ? 'Manager' : 'Server',
                  ),
                  trailing: Row(
                    mainAxisSize: .min,
                    children: [
                      IconButton(
                        key: Key('staff.edit.${employee.id}'),
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openEditor(employee: employee),
                      ),
                      IconButton(
                        key: Key('staff.delete.${employee.id}'),
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(employee),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmployeeFormSheet extends StatefulWidget {
  const _EmployeeFormSheet({this.employee});

  final Employee? employee;

  @override
  State<_EmployeeFormSheet> createState() => _EmployeeFormSheetState();
}

class _EmployeeFormSheetState extends State<_EmployeeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _pinController;
  late EmployeeRole _role;
  bool _saving = false;

  bool get _isEdit => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _nameController = TextEditingController(text: e?.name ?? '');
    _pinController = TextEditingController(text: e?.passcode ?? '');
    _role = e?.role ?? .server;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;

    setState(() => _saving = true);
    final employee = Employee(
      id: widget.employee?.id,
      name: _nameController.text.trim(),
      passcode: _pinController.text.trim(),
      role: _role,
    );

    try {
      await EmployeeManagerService.instance.saveEmployee(employee);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showSnackBar(e.toString(), context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: .fromLTRB(24, 8, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            Text(
              _isEdit ? 'Edit employee' : 'Add employee',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('staff.form.name'),
              controller: _nameController,
              textInputAction: .next,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('staff.form.pin'),
              controller: _pinController,
              keyboardType: .number,
              obscureText: true,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'PIN (4–6 digits)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || !RegExp(r'^\d{4,6}$').hasMatch(v)) {
                  return 'Enter 4 to 6 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            SegmentedButton<EmployeeRole>(
              segments: const [
                ButtonSegment(
                  value: .server,
                  label: Text('Server'),
                  icon: Icon(Icons.person_outline),
                ),
                ButtonSegment(
                  value: .manager,
                  label: Text('Manager'),
                  icon: Icon(Icons.admin_panel_settings_outlined),
                ),
              ],
              selected: {_role},
              onSelectionChanged: (set) {
                setState(() => _role = set.first);
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('staff.form.save'),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : Text(_isEdit ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}
