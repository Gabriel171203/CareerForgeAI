import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../services/ai/gemini_service.dart';
import '../../../../shared/widgets/glass_card.dart';

class QuestionnaireScreen extends ConsumerStatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  ConsumerState<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  int _currentStep = 0;
  final _skillsController = TextEditingController();
  final _interestController = TextEditingController();
  String _experienceLevel = 'Fresh Graduate';
  
  bool _isAnalyzing = false;
  String? _aiFeedback;

  Future<void> _submitAnalysis() async {
    setState(() => _isAnalyzing = true);
    
    final gemini = ref.read(geminiServiceProvider);
    final skills = _skillsController.text.split(',').map((e) => e.trim()).toList();
    
    final result = await gemini.analyzeCareerProfile(
      skills: skills,
      interest: _interestController.text,
      experience: _experienceLevel,
    );
    
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _aiFeedback = result;
        _currentStep++; // move to result
      });
    }
  }

  @override
  void dispose() {
    _skillsController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Assessment'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedSwitcher(
            duration: 500.ms,
            child: _buildCurrentStep(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    if (_isAnalyzing) {
      return Center(
        key: const ValueKey('analyzing'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'AI is analyzing your career profile...',
              style: Theme.of(context).textTheme.titleMedium,
            ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn().fadeOut(),
          ],
        ),
      );
    }
    
    if (_currentStep == 0) {
      return _buildForm(context);
    } else {
      return _buildResult(context);
    }
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tell us about yourself',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
             'We will use this data to calculate your readiness score and roadmap.',
             style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 32),
          
          TextFormField(
            controller: _interestController,
            decoration: const InputDecoration(
              labelText: 'Career Interest',
              hintText: 'e.g. Graphic Designer, Mobile Developer',
              prefixIcon: Icon(LucideIcons.target),
            ),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _skillsController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Your Skills (comma separated)',
              hintText: 'e.g. Figma, Dart, Illustration...',
              prefixIcon: Icon(LucideIcons.code),
            ),
          ),
          const SizedBox(height: 24),
          
          DropdownButtonFormField<String>(
            value: _experienceLevel,
            decoration: const InputDecoration(
              labelText: 'Experience Level',
              prefixIcon: Icon(LucideIcons.briefcase),
            ),
            items: const [
              DropdownMenuItem(value: 'Student', child: Text('Student / Mahasiswa')),
              DropdownMenuItem(value: 'Fresh Graduate', child: Text('Fresh Graduate')),
              DropdownMenuItem(value: 'Junior (1-2 years)', child: Text('Junior (1-2 years)')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _experienceLevel = val);
            },
          ),
          
          const SizedBox(height: 48),
          FilledButton(
            onPressed: () {
              if (_interestController.text.isNotEmpty && _skillsController.text.isNotEmpty) {
                 _submitAnalysis();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields first!')),
                );
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Generate AI Insights'),
            ),
          ),
        ],
      ).animate().fade().slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildResult(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('result'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(LucideIcons.sparkles, size: 64, color: Theme.of(context).colorScheme.secondary)
            .animate().scale().shimmer(duration: 2.seconds),
          const SizedBox(height: 24),
          Text(
            'Your AI Career Profile',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fade().slideY(),
          const SizedBox(height: 32),
          
          GlassCard(
            blur: 15,
            padding: const EdgeInsets.all(24),
            child: Text(
              _aiFeedback ?? 'Analysis failed.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ).animate().fade().scale(delay: 300.ms),
          
          const SizedBox(height: 48),
          FilledButton(
            onPressed: () => context.go('/dashboard'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Go to my Dashboard'),
            ),
          ).animate().fade(delay: 500.ms),
        ],
      ),
    );
  }
}
