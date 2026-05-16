import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../services/auth/firebase_auth_service.dart';
import '../../../../../core/providers/language_provider.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../../services/database/career_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final userProfile = ref.watch(userProfileProvider).value;
    final selectedLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, user),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildQuickStats(context, userProfile),
                  const SizedBox(height: 32),
                  _buildSection(
                    context,
                    title: 'Settings',
                    children: [
                      _buildSettingItem(
                        context,
                        icon: LucideIcons.languages,
                        iconColor: Colors.blue,
                        title: 'Language / Bahasa',
                        subtitle: selectedLocale == 'id' ? 'Bahasa Indonesia' : 'English',
                        onTap: () => _showLanguageDialog(context, ref),
                      ),
                      _buildSettingItem(
                        context,
                        icon: LucideIcons.moon,
                        iconColor: Colors.purple,
                        title: 'Dark Mode',
                        subtitle: 'Follow System',
                        trailing: Switch(value: true, onChanged: (v) {}),
                      ),
                      _buildSettingItem(
                        context,
                        icon: LucideIcons.bell,
                        iconColor: Colors.orange,
                        title: 'Notifications',
                        subtitle: 'Enabled',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: 'Account',
                    children: [
                      _buildSettingItem(
                        context,
                        icon: LucideIcons.logOut,
                        iconColor: theme.colorScheme.error,
                        title: 'Sign Out',
                        textColor: theme.colorScheme.error,
                        onTap: () => ref.read(authServiceProvider).signOut(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'CareerForge AI v1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, dynamic user) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: theme.colorScheme.surface,
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(LucideIcons.user, size: 40, color: theme.colorScheme.primary),
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? user?.email?.split('@').first ?? 'Career Forger',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, dynamic profile) {
    return Row(
      children: [
        _buildStatCard(context, 'Ready Score', '${profile?.readinessScore ?? 0}%', LucideIcons.award, Colors.amber),
        const SizedBox(width: 16),
        _buildStatCard(context, 'Interest', profile?.interest ?? '-', LucideIcons.target, Colors.blue),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: trailing ?? const Icon(LucideIcons.chevronRight, size: 16),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Language', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              ListTile(
                leading: const Text('🇮🇩', style: TextStyle(fontSize: 24)),
                title: const Text('Bahasa Indonesia'),
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale('id');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: const Text('English'),
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale('en');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
