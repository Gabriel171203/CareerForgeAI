import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Hero Illustration Placeholder
              Center(
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.1),
                        colorScheme.tertiary.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(LucideIcons.bot, size: 100, color: colorScheme.primary)
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .slideY(duration: 2.seconds, begin: -0.1, end: 0.1),
                      Positioned(
                        right: 40,
                        top: 20,
                        child: Icon(LucideIcons.sparkle, size: 30, color: colorScheme.secondary)
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .scale(duration: 1.5.seconds, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 800.ms).scale(),
              ),
              const SizedBox(height: 48),
              
              // Typrography
              Text(
                'Shape Your Future with AI',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              Text(
                'Discover career paths, master skills, and simulate real industry interviews to achieve your dream job.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ).animate().fade(delay: 600.ms).slideY(begin: 0.2, end: 0),
              
              const Spacer(),
              
              // Action Buttons
              FilledButton(
                onPressed: () {
                  // Navigate to Questionnaire
                  context.push('/onboarding/questionnaire');
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Get Started'),
              ).animate().fade(delay: 800.ms).slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 16),
              
              OutlinedButton(
                onPressed: () {
                  // Navigate to Login
                  context.push('/auth/login');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('I already have an account'),
              ).animate().fade(delay: 1000.ms).slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
