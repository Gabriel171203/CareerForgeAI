import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      final hasLocale = prefs.containsKey('selected_locale');
      
      if (hasLocale) {
        context.go('/welcome');
      } else {
        context.go('/language');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.sparkles,
              size: 64,
              color: Theme.of(context).colorScheme.tertiary,
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(duration: 1.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
            .shimmer(duration: 1.seconds),
            const SizedBox(height: 24),
            Text(
              'CareerForge AI',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fade(duration: 800.ms).slideY(begin: 0.5, end: 0),
          ],
        ),
      ),
    );
  }
}
