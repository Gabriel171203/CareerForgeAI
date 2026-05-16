import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../services/auth/firebase_auth_service.dart';
import '../../../../../shared/widgets/glass_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan kata sandi tidak boleh kosong')),
      );
      return;
    }

    if (!_isLogin && _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      if (_isLogin) {
        await authService.signInWithEmailPassword(
            _emailController.text.trim(), _passwordController.text.trim());
      } else {
        await authService.signUpWithEmailPassword(
          email: _emailController.text.trim(), 
          password: _passwordController.text.trim(),
          displayName: _nameController.text.trim(),
        );
      }
      
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().split(']').last.trim(), maxLines: 2)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient Animation
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withOpacity(0.3),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(duration: 3.seconds, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GlassCard(
                  blur: 20,
                  opacity: 0.05,
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        _isLogin ? LucideIcons.logIn : LucideIcons.userPlus,
                        size: 48,
                        color: theme.colorScheme.tertiary,
                      ).animate().scale(),
                      const SizedBox(height: 16),
                      Text(
                        _isLogin ? 'Welcome Back' : 'Create Account',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fade().slideY(),
                      const SizedBox(height: 32),
                      
                      if (!_isLogin) 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(LucideIcons.user),
                              labelText: 'Full Name',
                            ),
                          ),
                        ).animate().fade().slideX(),
                      
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(LucideIcons.mail),
                          labelText: 'Email Address',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(LucideIcons.lock),
                          labelText: 'Password',
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      _isLoading 
                          ? const Center(child: CircularProgressIndicator())
                          : FilledButton(
                              onPressed: _submit,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(_isLogin ? 'Login' : 'Sign Up'),
                              ),
                            ).animate().fade().scale(),
                      
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() => _isLogin = !_isLogin);
                        },
                        child: Text(_isLogin 
                          ? "Don't have an account? Sign Up" 
                          : "Already have an account? Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
