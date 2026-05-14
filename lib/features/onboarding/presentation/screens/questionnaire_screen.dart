import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuestionnaireScreen extends StatelessWidget {
  const QuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Profile Setup'),
      ),
      body: Center(
        child: FilledButton(
          onPressed: () {
            context.go('/dashboard');
          },
          child: const Text('Finish Setup -> Dashboard'),
        ),
      ),
    );
  }
}
