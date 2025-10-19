import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constants/roles.dart';
import '../../../core/widgets/role_badge.dart';
import '../../../data/models/app_user.dart';
import '../../../mvc/providers.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Stream<List<AppUser>> stream;
    if (_filter == 'all') {
      stream = users.watchByRole(UserRoles.student);
    } else {
      stream = users.watchByRole(_filter);
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Gestion des Utilisateurs',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: RoleBadge(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filtres
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrer par rôle',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'Tous les utilisateurs',
                        selected: _filter == 'all',
                        onSelected: (v) => setState(() => _filter = 'all'),
                        colorScheme: colorScheme,
                      ),
                      _FilterChip(
                        label: 'Administrateurs',
                        selected: _filter == UserRoles.admin,
                        onSelected: (v) => setState(() => _filter = UserRoles.admin),
                        colorScheme: colorScheme,
                        color: colorScheme.error,
                      ),
                      _FilterChip(
                        label: 'Enseignants',
                        selected: _filter == UserRoles.teacher,
                        onSelected: (v) => setState(() => _filter = UserRoles.teacher),
                        colorScheme: colorScheme,
                        color: colorScheme.primary,
                      ),
                      _FilterChip(
                        label: 'Étudiants',
                        selected: _filter == UserRoles.student,
                        onSelected: (v) => setState(() => _filter = UserRoles.student),
                        colorScheme: colorScheme,
                        color: colorScheme.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<AppUser>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = snapshot.data ?? [];

                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _filter == 'all'
                                ? 'Aucun utilisateur trouvé'
                                : 'Aucun ${_getRoleLabel(_filter)} trouvé',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _filter == 'all'
                                ? 'Créez le premier utilisateur pour commencer'
                                : 'Aucun utilisateur avec ce rôle',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final u = items[i];
                      return _UserCard(
                        user: u,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        ref: ref,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.signup),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Créer un compte'),
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case UserRoles.admin:
        return 'administrateur';
      case UserRoles.teacher:
        return 'enseignant';
      case UserRoles.student:
        return 'étudiant';
      default:
        return 'utilisateur';
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.colorScheme,
    this.color,
  });

  final String label;
  final bool selected;
  final Function(bool) onSelected;
  final ColorScheme colorScheme;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? colorScheme.primary;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: colorScheme.surfaceVariant,
      selectedColor: chipColor,
      checkmarkColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.colorScheme,
    required this.textTheme,
    required this.ref,
  });

  final AppUser user;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final WidgetRef ref;

  Color _getRoleColor(String role) {
    switch (role) {
      case UserRoles.admin:
        return colorScheme.error;
      case UserRoles.teacher:
        return colorScheme.primary;
      case UserRoles.student:
        return colorScheme.secondary;
      default:
        return colorScheme.onSurface;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case UserRoles.admin:
        return 'Admin';
      case UserRoles.teacher:
        return 'Enseignant';
      case UserRoles.student:
        return 'Étudiant';
      default:
        return 'Utilisateur';
    }
  }

  IconData _getRoleIcon(String role) {
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
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(user.role);

    return Card(
      elevation: 1,
      color: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getRoleIcon(user.role),
                color: roleColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Informations utilisateur
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.isEmpty ? '(Sans nom)' : user.name,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getRoleLabel(user.role),
                      style: textTheme.labelSmall?.copyWith(
                        color: roleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Dropdown de rôle
            _RoleDropdown(
              value: user.role,
              onChanged: (r) async {
                if (r == null || r == user.role) return;
                await ref.read(usersControllerProvider).setUser(
                  AppUser(
                    id: user.id,
                    name: user.name,
                    email: user.email,
                    role: r,
                  ),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rôle mis à jour: ${user.name} → ${_getRoleLabel(r)}'),
                    backgroundColor: colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({
    required this.value,
    required this.onChanged,
    required this.colorScheme,
  });

  final String value;
  final ValueChanged<String?> onChanged;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
          ),
          items: const [
            DropdownMenuItem(
              value: UserRoles.admin,
              child: Text('Admin'),
            ),
            DropdownMenuItem(
              value: UserRoles.teacher,
              child: Text('Enseignant'),
            ),
            DropdownMenuItem(
              value: UserRoles.student,
              child: Text('Étudiant'),
            ),
          ],
        ),
      ),
    );
  }
}