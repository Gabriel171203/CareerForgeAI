import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/providers/language_provider.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedLocale = ref.watch(localeProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(LucideIcons.languages, size: 80, color: theme.colorScheme.primary)
                    .animate().scale().rotate(begin: -0.1, end: 0),
                const SizedBox(height: 32),
                Text(
                  'Choose Your Language',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ).animate().fade().slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Pilih bahasa yang Anda gunakan',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ).animate().fade(delay: 200.ms),
                const SizedBox(height: 48),
                
                _buildLanguageOption(
                  context, 
                  ref,
                  'id', 
                  'Bahasa Indonesia', 
                  'Indonesian',
                  selectedLocale == 'id',
                ),
                const SizedBox(height: 16),
                _buildLanguageOption(
                  context, 
                  ref,
                  'en', 
                  'English', 
                  'English',
                  selectedLocale == 'en',
                ),
                
                const Spacer(),
                FilledButton(
                  onPressed: () => context.go('/welcome'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Continue / Lanjutkan'),
                ).animate().fade(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, 
    WidgetRef ref,
    String code, 
    String title, 
    String subtitle,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).setLocale(code),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.5) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: theme.colorScheme.primary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Text(
                code.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
            const Spacer(),
            if (isSelected)
              Icon(LucideIcons.checkCircle2, color: theme.colorScheme.primary),
          ],
        ),
      ),
    ).animate().fade().slideX(begin: 0.1, end: 0);
  }
}
