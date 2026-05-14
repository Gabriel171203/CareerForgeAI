import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp() will go here later
  runApp(
    const ProviderScope(
      child: CareerForgeApp(),
    ),
  );
}

class CareerForgeApp extends ConsumerWidget {
  const CareerForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'CareerForge AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Supports dark/light mode toggle via settings
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
