import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/roles.dart';
import '../../mvc/providers.dart';

class UsersCounters extends ConsumerWidget {
  const UsersCounters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CountCard(
          tooltip: 'Administrateurs',
          color: colorScheme.error,
          backgroundColor: colorScheme.errorContainer,
          stream: users.watchCountByRole(UserRoles.admin),
          icon: Icons.admin_panel_settings_outlined,
          label: 'Admins',
        ),
        const SizedBox(width: 8),
        _CountCard(
          tooltip: 'Enseignants',
          color: colorScheme.primary,
          backgroundColor: colorScheme.primaryContainer,
          stream: users.watchCountByRole(UserRoles.teacher),
          icon: Icons.school_outlined,
          label: 'Enseignants',
        ),
        const SizedBox(width: 8),
        _CountCard(
          tooltip: 'Étudiants',
          color: colorScheme.secondary,
          backgroundColor: colorScheme.secondaryContainer,
          stream: users.watchCountByRole(UserRoles.student),
          icon: Icons.group_outlined,
          label: 'Étudiants',
        ),
      ],
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.tooltip,
    required this.color,
    required this.backgroundColor,
    required this.stream,
    required this.icon,
    required this.label,
  });

  final String tooltip;
  final Color color;
  final Color backgroundColor;
  final Stream<int> stream;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        final isLoading = !snapshot.hasData;

        return Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône et compteur
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 14,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isLoading ? '...' : '$count',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Label
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
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