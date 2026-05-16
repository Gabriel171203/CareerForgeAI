import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/language_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/onboarding/presentation/screens/questionnaire_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/main_dashboard_screen.dart';

import '../../services/auth/firebase_auth_service.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }
}

// Provide the router globally using Riverpod
final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final user = authState.value;
      
      final isLoggingIn = state.matchedLocation == '/auth/login' || 
                          state.matchedLocation == '/welcome' ||
                          state.matchedLocation == '/language' ||
                          state.matchedLocation == '/';

      if (user == null) {
        // If not logged in and trying to access protected route (like Questionnaire or Dashboard)
        if (!isLoggingIn) return '/auth/login';
      } else {
        // If logged in and trying to access login/welcome
        if (isLoggingIn) return '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/language',
        name: 'language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/questionnaire',
        name: 'questionnaire',
        builder: (context, state) => const QuestionnaireScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const MainDashboardScreen(),
      ),
    ],
  );
});
