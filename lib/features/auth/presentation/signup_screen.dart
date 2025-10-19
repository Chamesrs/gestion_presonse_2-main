import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constants/roles.dart';
import '../../../mvc/providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = UserRoles.student;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider).signUp(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        role: _role,
      );
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.root);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('Erreur inscription: $e')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildRoleIcon(String role) {
    switch (role) {
      case UserRoles.admin:
        return Icon(Icons.admin_panel_settings_outlined, size: 20);
      case UserRoles.teacher:
        return Icon(Icons.school_outlined, size: 20);
      case UserRoles.student:
        return Icon(Icons.person_outlined, size: 20);
      default:
        return Icon(Icons.person_outlined, size: 20);
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
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header visuel
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_alt_1_outlined,
                      size: 50,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Créer un compte',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Rejoignez la communauté du lycée',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Carte du formulaire
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Champ nom complet
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: InputDecoration(
                                labelText: 'Nom complet',
                                prefixIcon: Icon(Icons.person_outlined,
                                    color: colorScheme.onSurface.withOpacity(0.6)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                              ),
                              validator: (v) => (v == null || v.trim().length < 2)
                                  ? 'Nom trop court'
                                  : null,
                            ),

                            const SizedBox(height: 16),

                            // Champ email
                            TextFormField(
                              controller: _emailCtrl,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined,
                                    color: colorScheme.onSurface.withOpacity(0.6)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => (v == null || v.isEmpty || !v.contains('@'))
                                  ? 'Email invalide'
                                  : null,
                            ),

                            const SizedBox(height: 16),

                            // Champ mot de passe
                            TextFormField(
                              controller: _passwordCtrl,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: Icon(Icons.lock_outlined,
                                    color: colorScheme.onSurface.withOpacity(0.6)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                              ),
                              obscureText: _obscurePassword,
                              validator: (v) => (v == null || v.length < 6)
                                  ? '6 caractères minimum'
                                  : null,
                            ),

                            const SizedBox(height: 24),

                            // Sélection du rôle
                            Text(
                              'Type de compte',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onBackground,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Cartes de sélection de rôle
                            Column(
                              children: [
                                _buildRoleCard(
                                  context,
                                  UserRoles.admin,
                                  'Administrateur',
                                  'Gestion complète du système',
                                  Icons.admin_panel_settings_outlined,
                                ),
                                const SizedBox(height: 8),
                                _buildRoleCard(
                                  context,
                                  UserRoles.teacher,
                                  'Enseignant',
                                  'Gestion des cours et présences',
                                  Icons.school_outlined,
                                ),
                                const SizedBox(height: 8),
                                _buildRoleCard(
                                  context,
                                  UserRoles.student,
                                  'Étudiant',
                                  'Marquer sa présence',
                                  Icons.person_outlined,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Bouton d'inscription
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _loading
                                    ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_add_alt_1, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Créer le compte',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Lien de connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Déjà un compte ? ',
                        style: TextStyle(
                          color: colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                      GestureDetector(
                        onTap: _loading ? null : () => context.go(AppRoutes.login),
                        child: Text(
                          'Connexion',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String role, String title, String description, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _role == role;

    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.6),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? colorScheme.primary : colorScheme.onBackground,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: colorScheme.primary)
            : null,
        onTap: _loading
            ? null
            : () => setState(() => _role = role),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}