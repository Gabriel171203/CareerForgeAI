import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../services/ai/gemini_service.dart';
import '../../../../../services/auth/firebase_auth_service.dart';
import '../../../../../services/database/career_repository.dart';
import '../../../../../core/models/career_profile.dart';
import '../../../../../shared/widgets/glass_card.dart';

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
    final auth = ref.read(authStateProvider).value;
    final careerRepo = ref.read(careerRepositoryProvider);
    
    final skills = _skillsController.text.split(',').map((e) => e.trim()).toList();
    
    final result = await gemini.analyzeCareerProfile(
      skills: skills,
      interest: _interestController.text,
      experience: _experienceLevel,
    );
    
    if (result != null && auth != null) {
      final profile = CareerProfile(
        userId: auth.uid,
        interest: _interestController.text.trim(),
        skills: skills,
        experienceLevel: _experienceLevel,
        aiFeedback: result,
        readinessScore: 65, // Base score, can be dynamic later
        analytics: const {
          'Technical': 0.0,
          'Soft Skills': 0.0,
          'Experience': 0.0,
          'Culture': 0.0,
          'Leadership': 0.0,
        },
        recommendations: const [],
        updatedAt: DateTime.now(),
      );
      
      await careerRepo.saveProfile(profile);
    }
    
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
            initialValue: _experienceLevel,
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
    final theme = Theme.of(context);
    return SingleChildScrollView(
      key: const ValueKey('result'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.sparkles, size: 48, color: theme.colorScheme.primary),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            'Your AI Career Profile',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.bot, size: 20, color: theme.colorScheme.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'AI ANALYSIS',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _aiFeedback ?? 'Analysis failed.',
                  style: const TextStyle(height: 1.6, fontSize: 15),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.go('/dashboard'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Go to my Dashboard'),
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}
