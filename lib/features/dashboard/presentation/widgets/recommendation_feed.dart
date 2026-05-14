import 'package:flutter/material.dart';
import '../../../../shared/widgets/glass_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RecommendationFeed extends StatelessWidget {
  const RecommendationFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily AI Recommendations',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _RecommendationCard(
                title: 'Master Flutter State',
                subtitle: 'Learn Riverpod in 10 mins',
                icon: LucideIcons.gem,
                color: Colors.blue,
              ),
              _RecommendationCard(
                title: 'Mock Interview Prep',
                subtitle: 'Practice Google SWE questions',
                icon: LucideIcons.messageSquare,
                color: Colors.purple,
              ),
              _RecommendationCard(
                title: 'Resume Review',
                subtitle: 'AI detected 3 missing keywords',
                icon: LucideIcons.fileText,
                color: Colors.teal,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _RecommendationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
