import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/roles.dart';
import '../../data/providers.dart';

class RoleBadge extends ConsumerWidget {
  const RoleBadge({super.key});

  String _label(String? role) {
    switch (role) {
      case UserRoles.admin:
        return 'Admin';
      case UserRoles.teacher:
        return 'Enseignant';
      case UserRoles.student:
        return 'Étudiant';
      default:
        return 'Invité';
    }
  }

  Color _backgroundColor(String? role, ColorScheme colorScheme) {
    switch (role) {
      case UserRoles.admin:
        return colorScheme.errorContainer;
      case UserRoles.teacher:
        return colorScheme.primaryContainer;
      case UserRoles.student:
        return colorScheme.secondaryContainer;
      default:
        return colorScheme.surfaceVariant;
    }
  }

  Color _textColor(String? role, ColorScheme colorScheme) {
    switch (role) {
      case UserRoles.admin:
        return colorScheme.onErrorContainer;
      case UserRoles.teacher:
        return colorScheme.onPrimaryContainer;
      case UserRoles.student:
        return colorScheme.onSecondaryContainer;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  IconData _icon(String? role) {
    switch (role) {
      case UserRoles.admin:
        return Icons.admin_panel_settings_outlined;
      case UserRoles.teacher:
        return Icons.school_outlined;
      case UserRoles.student:
        return Icons.person_outlined;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(currentUserDocProvider);
    final role = asyncUser.value?.role;
    final colorScheme = Theme.of(context).colorScheme;

    if (asyncUser.isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(right: 6),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Chargement...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor(role, colorScheme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _textColor(role, colorScheme).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon(role),
            size: 14,
            color: _textColor(role, colorScheme),
          ),
          const SizedBox(width: 6),
          Text(
            _label(role),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textColor(role, colorScheme),
            ),
          ),
        ],
      ),
    );
  }
}