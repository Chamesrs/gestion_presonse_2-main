import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constants/roles.dart';
import '../../../core/widgets/role_badge.dart';
import '../../../core/widgets/admin_drawer.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/class_model.dart';
import '../../../data/providers.dart';
import '../../../mvc/providers.dart';
import 'class_editor_dialog.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserDocProvider).value;
    final classesCtrl = ref.watch(classesControllerProvider);
    final usersCtrl = ref.watch(usersControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final bool isAdmin = me?.role == UserRoles.admin;
    final String uid = ref.watch(authStateProvider).value?.uid ?? '';

    final stream = isAdmin
        ? classesCtrl.watchAll()
        : classesCtrl.watchForTeacher(uid);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Gestion des Classes',
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
      drawer: isAdmin ? const AdminDrawer() : null,
      body: StreamBuilder<List<ClassModel>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.class_outlined,
                    size: 64,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAdmin ? 'Aucune classe créée' : 'Aucune classe assignée',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAdmin
                        ? 'Créez votre première classe pour commencer'
                        : 'Contactez votre administrateur',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          final classes = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              itemCount: classes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = classes[index];
                return _ClassCard(
                  classModel: c,
                  isAdmin: isAdmin,
                  usersCtrl: usersCtrl,
                  classesCtrl: classesCtrl,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  ref: ref, // Passer ref au _ClassCard
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () => showClassEditorDialog(context, ref),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    required this.classModel,
    required this.isAdmin,
    required this.usersCtrl,
    required this.classesCtrl,
    required this.colorScheme,
    required this.textTheme,
    required this.ref, // Recevoir ref en paramètre
  });

  final ClassModel classModel;
  final bool isAdmin;
  final dynamic usersCtrl;
  final dynamic classesCtrl;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final WidgetRef ref; // Ajouter ref comme paramètre

  Future<void> _deleteClass(BuildContext context, ClassModel c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Supprimer la classe ?',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'La classe "${c.name}" sera définitivement supprimée.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await classesCtrl.remove(c.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom de classe et actions
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.class_outlined,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classModel.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StreamBuilder<AppUser?>(
                        stream: usersCtrl.watchUser(classModel.teacherId),
                        builder: (context, snap) {
                          final teacher = snap.data;
                          return Text(
                            'Enseignant: ${teacher?.name ?? '—'}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                if (isAdmin) ...[
                  IconButton(
                    tooltip: 'Modifier',
                    icon: Icon(
                      Icons.edit_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    onPressed: () => showClassEditorDialog(context, ref, existing: classModel),
                  ),
                  IconButton(
                    tooltip: 'Supprimer',
                    icon: Icon(
                      Icons.delete_outline,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    onPressed: () => _deleteClass(context, classModel),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Informations supplémentaires
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoItem(
                    icon: Icons.people_outline,
                    value: '${classModel.studentIds.length}',
                    label: 'Étudiants',
                    colorScheme: colorScheme,
                  ),
                  _InfoItem(
                    icon: Icons.calendar_today_outlined,
                    value: '${classModel.createdAt.day}/${classModel.createdAt.month}/${classModel.createdAt.year}',
                    label: 'Créée le',
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.colorScheme,
  });

  final IconData icon;
  final String value;
  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}