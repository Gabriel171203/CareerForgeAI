import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'home_screen.dart';
import 'analytics_screen.dart';
import '../../../mock_interview/presentation/screens/mock_interview_screen.dart';
import 'profile_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_providers.dart';

class MainDashboardScreen extends ConsumerWidget {
  const MainDashboardScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    AnalyticsScreen(),
    MockInterviewScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(dashboardIndexProvider);
    
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (idx) => ref.read(dashboardIndexProvider.notifier).state = idx,
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.layoutDashboard), label: 'Home'),
          NavigationDestination(icon: Icon(LucideIcons.crosshair), label: 'Analytics'),
          NavigationDestination(icon: Icon(LucideIcons.bot), label: 'Assistant'),
          NavigationDestination(icon: Icon(LucideIcons.user), label: 'Profile'),
        ],
      ),
    );
  }
}
