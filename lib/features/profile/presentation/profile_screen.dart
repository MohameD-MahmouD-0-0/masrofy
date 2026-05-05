import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/user_profile_service.dart';

// ─────────────────────────────────────────────────────────────
// ProfileScreen
// ─────────────────────────────────────────────────────────────
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _service = UserProfileService();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isEditing = false;
  bool _isSaving = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Save updated name to Firestore ──────────────────────
  Future<void> _saveName() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_currentUser == null) return;

    setState(() => _isSaving = true);
    try {
      await _service.updateFullName(
        uid: _currentUser!.uid,
        fullName: _nameController.text,
      );
      if (mounted) {
        setState(() => _isEditing = false);
        _showSnack('Name updated successfully', isError: false);
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to update name. Try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.red : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // Adaptive colours that work in both modes
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorder : const Color(0xffE5E7EB);
    final scaffoldBg =
        isDark ? AppColors.darkBackground : const Color(0xffF6F8FB);
    final secondaryText =
        isDark ? AppColors.darkSecondaryText : AppColors.littleGrey;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Profile card ──────────────────────────────
              _Card(
                isDark: isDark,
                cardBg: cardBg,
                cardBorder: cardBorder,
                child: _currentUser == null
                    ? _NotLoggedIn(secondaryText: secondaryText)
                    : StreamBuilder(
                        stream: _service
                            .userProfileStream(_currentUser!.uid),
                        builder: (context, snapshot) {
                          final data =
                              snapshot.data?.data() as Map<String, dynamic>?;
                          final fullName =
                              data?['fullName'] as String? ?? '—';
                          final email =
                              data?['email'] as String? ??
                                  _currentUser!.email ??
                                  '—';

                          // Prefill controller only when not editing
                          if (!_isEditing) {
                            _nameController.text = fullName;
                          }

                          return _ProfileContent(
                            fullName: fullName,
                            email: email,
                            isEditing: _isEditing,
                            isSaving: _isSaving,
                            nameController: _nameController,
                            formKey: _formKey,
                            colorScheme: colorScheme,
                            secondaryText: secondaryText,
                            onEditTap: () =>
                                setState(() => _isEditing = true),
                            onCancelTap: () =>
                                setState(() => _isEditing = false),
                            onSaveTap: _saveName,
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),

              // ── Appearance card ───────────────────────────
              _Card(
                isDark: isDark,
                cardBg: cardBg,
                cardBorder: cardBorder,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: secondaryText,
                            letterSpacing: 0.4,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _ThemeToggleRow(
                      isDark: isDark,
                      onToggle: () => ref
                          .read(themeNotifierProvider.notifier)
                          .toggle(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
    required this.child,
  });

  final bool isDark;
  final Color cardBg;
  final Color cardBorder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: child,
    );
  }
}

// ── Profile header + edit form ──────────────────────────────
class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.fullName,
    required this.email,
    required this.isEditing,
    required this.isSaving,
    required this.nameController,
    required this.formKey,
    required this.colorScheme,
    required this.secondaryText,
    required this.onEditTap,
    required this.onCancelTap,
    required this.onSaveTap,
  });

  final String fullName;
  final String email;
  final bool isEditing;
  final bool isSaving;
  final TextEditingController nameController;
  final GlobalKey<FormState> formKey;
  final ColorScheme colorScheme;
  final Color secondaryText;
  final VoidCallback onEditTap;
  final VoidCallback onCancelTap;
  final VoidCallback onSaveTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(28),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.primary,
            size: 38,
          ),
        ),
        const SizedBox(height: 14),

        // Name / edit field
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: isEditing
              ? _EditNameForm(
                  key: const ValueKey('form'),
                  controller: nameController,
                  formKey: formKey,
                  isSaving: isSaving,
                  colorScheme: colorScheme,
                  onCancel: onCancelTap,
                  onSave: onSaveTap,
                )
              : _DisplayName(
                  key: const ValueKey('display'),
                  fullName: fullName,
                  email: email,
                  secondaryText: secondaryText,
                  onEditTap: onEditTap,
                ),
        ),
      ],
    );
  }
}

class _DisplayName extends StatelessWidget {
  const _DisplayName({
    super.key,
    required this.fullName,
    required this.email,
    required this.secondaryText,
    required this.onEditTap,
  });

  final String fullName;
  final String email;
  final Color secondaryText;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              fullName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onEditTap,
              child: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(color: secondaryText, fontSize: 13),
        ),
      ],
    );
  }
}

class _EditNameForm extends StatelessWidget {
  const _EditNameForm({
    super.key,
    required this.controller,
    required this.formKey,
    required this.isSaving,
    required this.colorScheme,
    required this.onCancel,
    required this.onSave,
  });

  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final bool isSaving;
  final ColorScheme colorScheme;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Name cannot be empty';
              if (v.trim().length < 2) return 'Name is too short';
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSaving ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: isSaving ? null : onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Theme toggle row ────────────────────────────────────────
class _ThemeToggleRow extends StatelessWidget {
  const _ThemeToggleRow({required this.isDark, required this.onToggle});

  final bool isDark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: isDark ? const Color(0xff93C5FD) : const Color(0xffFBBF24),
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            isDark ? 'Dark Mode' : 'Light Mode',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Switch.adaptive(
          value: isDark,
          activeColor: AppColors.primary,
          onChanged: (_) => onToggle(),
        ),
      ],
    );
  }
}

// ── Not logged in placeholder ───────────────────────────────
class _NotLoggedIn extends StatelessWidget {
  const _NotLoggedIn({required this.secondaryText});
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.lock_outline_rounded,
            color: AppColors.primary, size: 36),
        const SizedBox(height: 10),
        Text('Not logged in',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Please sign in to view your profile.',
            textAlign: TextAlign.center,
            style: TextStyle(color: secondaryText, fontSize: 13)),
      ],
    );
  }
}