import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/services/staff/employee_manager_service.dart';

/// AppBar action that locks the terminal and returns to the PIN screen.
class StaffLockAction extends StatelessWidget {
  const StaffLockAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: EmployeeManagerService.instance,
      builder: (context, _) {
        final name =
            EmployeeManagerService.instance.currentEmployee?.name ?? '';
        return IconButton(
          key: const Key('home.lock_action'),
          tooltip: name.isEmpty ? 'Lock' : 'Lock ($name)',
          icon: const Icon(Icons.lock_outline),
          onPressed: () {
            EmployeeManagerService.instance.logout();
            context.goNamed(AppRouteNames.lock);
          },
        );
      },
    );
  }
}
