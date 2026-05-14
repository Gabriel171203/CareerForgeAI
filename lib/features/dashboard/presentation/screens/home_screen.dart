import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../widgets/career_score_card.dart';
import '../widgets/recommendation_feed.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Gabriel! 👋',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ready to forge your career?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: const Icon(LucideIcons.user),
              ),
            ],
          ).animate().fade().slideY(begin: -0.2, end: 0),
          
          const SizedBox(height: 32),
          const CareerScoreCard(score: 78).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 32),
          const RecommendationFeed().animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
          
        ],
      ),
    );
  }
}
