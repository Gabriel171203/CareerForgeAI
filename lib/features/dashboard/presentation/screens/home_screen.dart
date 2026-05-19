  import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../services/database/career_repository.dart';
import '../../../../../services/auth/firebase_auth_service.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../providers/dashboard_providers.dart';

import '../widgets/career_score_card.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/recommendation_feed.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAuth = ref.watch(authStateProvider).value;
    final userProfile = ref.watch(userProfileProvider).value;
    
    final name = userAuth?.displayName ?? userAuth?.email?.split('@').first ?? 'Career Forger';
    final today = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(context, name, today),
              const SizedBox(height: 32),
              
              // Action Banner for missing profile
              if (userProfile == null)
                _buildMissingProfileBanner(context)
              else ...[
              // Main Metrics
              _buildSectionHeader(
                context, 
                'Career Status', 
                onSeeAll: () => ref.read(dashboardIndexProvider.notifier).state = 1,
              ),
              const SizedBox(height: 12),
              CareerScoreCard(score: userProfile.readinessScore),
              
              const SizedBox(height: 32),
              
              // NEW AI Insight Section
              _buildSectionHeader(
                context, 
                'Latest Forge Analysis', 
                emoji: '✨',
                onSeeAll: () => ref.read(dashboardIndexProvider.notifier).state = 2, 
              ),
              const SizedBox(height: 16),
              AIInsightCard(
                insight: userProfile.aiFeedback.isNotEmpty 
                    ? userProfile.aiFeedback 
                    : "Belum ada analisis. Mulai interview pertama Anda dengan Forge untuk mendapatkan feedback!",
                date: DateFormat('MMM d, yyyy').format(userProfile.updatedAt),
              ),

              
              const SizedBox(height: 32),
              
              // Quick Skills List
              _buildSectionHeader(
                context, 
                'Core Skills',
                onSeeAll: () => ref.read(dashboardIndexProvider.notifier).state = 1,
              ),
              const SizedBox(height: 12),
              _buildSkillChips(context, userProfile.skills),
              ],
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String date) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.2,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Icon(LucideIcons.bell, size: 20, color: theme.colorScheme.primary),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildSectionHeader(BuildContext context, String title, {String? emoji, VoidCallback? onSeeAll}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        if (emoji != null) ...[
          const SizedBox(width: 8),
          Text(emoji),
        ],
        const Spacer(),
        TextButton(
          onPressed: onSeeAll,
          child: const Text('See All', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildMissingProfileBanner(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.sparkles, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Personalize Your AI',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),
          const Text(
            'Complete your career profile to unlock personalized AI insights and skill analysis.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.push('/onboarding/questionnaire'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Start AI Analysis'),
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .shimmer(delay: 2.seconds, duration: 1.5.seconds);
  }

  Widget  _buildSkillChips(BuildContext context, List<String> skills) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.take(6).map((skill) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Text(
          skill,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      )).toList(),
    ).animate().fadeIn(delay: 500.ms);
  }
}
