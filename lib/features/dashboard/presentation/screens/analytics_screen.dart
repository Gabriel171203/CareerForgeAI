import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../services/database/career_repository.dart';
import '../widgets/skill_radar_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Gap Analytics'),
        centerTitle: true,
      ),
      body: userProfileAsync.when(
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.barChart2, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  const Text('Please complete your profile to see analytics.'),
                ],
              ),
            );
          }

          // Use real data from Firestore
          final labels = profile.analytics.keys.toList();
          final values = profile.analytics.values.toList();
          
          if (labels.isEmpty) {
            return const Center(child: Text('No analytics data yet. Complete an interview!'));
          }


          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Your Skill Radar',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Targeting: ${profile.interest}'),
                      const SizedBox(height: 32),
                      SkillRadarChart(values: values, labels: labels),
                    ],
                  ),
                ).animate().fade().slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 32),
                Text(
                  'Your Key Strengths',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ).animate().fade(delay: 200.ms),
                const SizedBox(height: 16),
                
                // Show highest scoring categories as strengths
                ...profile.analytics.entries
                    .where((e) => e.value >= 7.0 || e.value == profile.analytics.values.reduce((a, b) => a > b ? a : b))
                    .take(2)
                    .map((e) => _buildSkillItem(context, e.key, e.value / 10.0)),
                
                const SizedBox(height: 24),
                Text(
                  'Forge AI Recommendation',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ).animate().fade(delay: 400.ms),
                const SizedBox(height: 16),
                
                if (profile.recommendations.isEmpty)
                  const Text('Finish an interview to get steps to improve!'),

                ...profile.recommendations.map((rec) => _buildSkillItem(context, rec, 0.3, isMissing: true)),

              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSkillItem(BuildContext context, String name, double progress, {bool isMissing = false}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(name, style: theme.textTheme.titleMedium)),
                Text(
                  isMissing ? 'Missing' : '${(progress * 100).toInt()}%', 
                  style: TextStyle(
                    color: isMissing ? theme.colorScheme.error : theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              borderRadius: BorderRadius.circular(8),
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: isMissing ? theme.colorScheme.error : theme.colorScheme.primary,
            ).animate().shimmer(),
          ],
        ),
      ),
    ).animate().fade().slideX();
  }
}
