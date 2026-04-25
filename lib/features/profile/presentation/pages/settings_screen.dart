import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/profile_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  final bool _darkModeEnabled = true; // Already in dark mode

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Paramètres'),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // General Section
            const _SectionHeader(title: 'Général'),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Recevoir des mises à jour',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (val) {
                        setState(() => _notificationsEnabled = val);
                        context.read<ProfileBloc>().add(
                              ProfilePreferencesUpdateRequested(
                                  {'notifications_enabled': val}));
                      },
                      activeThumbColor: AppColors.accent,
                      activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
                      inactiveThumbColor: AppColors.textSecondary,
                      inactiveTrackColor: AppColors.surfaceContainer,
                    ),
                  ),
                  const Divider(
                    color: AppColors.borderGray,
                    height: 1,
                    indent: 56,
                  ),
                  _SettingsTile(
                    icon: Icons.language,
                    title: 'Langue',
                    subtitle: 'Français (Burundi)',
                    onTap: () {
                      // TODO: Show language picker
                    },
                  ),
                  const Divider(
                    color: AppColors.borderGray,
                    height: 1,
                    indent: 56,
                  ),
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Mode Sombre',
                    subtitle: 'Interface sombre activée',
                    trailing: Switch(
                      value: _darkModeEnabled,
                      onChanged: (val) {
                        // For now, dark mode is always enabled
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Le mode clair sera bientôt disponible'),
                            backgroundColor: AppColors.info,
                          ),
                        );
                      },
                      activeThumbColor: AppColors.accent,
                      activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
                      inactiveThumbColor: AppColors.textSecondary,
                      inactiveTrackColor: AppColors.surfaceContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Privacy Section
            const _SectionHeader(title: 'Confidentialité'),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Politique de confidentialité',
                    onTap: () {
                      // TODO: Navigate to privacy policy
                    },
                  ),
                  const Divider(
                    color: AppColors.borderGray,
                    height: 1,
                    indent: 56,
                  ),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Conditions d\'utilisation',
                    onTap: () {
                      // TODO: Navigate to terms
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Support Section
            const _SectionHeader(title: 'Support'),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: 'Aide & FAQ',
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                  const Divider(
                    color: AppColors.borderGray,
                    height: 1,
                    indent: 56,
                  ),
                  _SettingsTile(
                    icon: Icons.support_agent_outlined,
                    title: 'Contacter le support',
                    onTap: () {
                      // TODO: Open support chat
                    },
                  ),
                  const Divider(
                    color: AppColors.borderGray,
                    height: 1,
                    indent: 56,
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'À propos de Gura Now',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Gura Now',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2024 Gura Now Burundi',
                        applicationIcon: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppColors.gradientAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            color: AppColors.textOnAccent,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Version
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  (onTap != null
                      ? const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        )
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      );
}
