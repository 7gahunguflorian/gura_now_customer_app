import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mot de passe modifié avec succès.')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text('Changer le mot de passe', style: AppTextStyles.heading3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            AppTextField(
              controller: _currentCtrl,
              label: 'Mot de passe actuel',
              obscureText: true,
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _newCtrl,
              label: 'Nouveau mot de passe',
              obscureText: true,
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _confirmCtrl,
              label: 'Confirmer le nouveau mot de passe',
              obscureText: true,
              validator: (v) {
                if (v != _newCtrl.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return Validators.validatePassword(v);
              },
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Enregistrer',
              onPressed: _loading ? null : _submit,
              isLoading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}
