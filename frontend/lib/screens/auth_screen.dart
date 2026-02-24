import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  theme.colorScheme.surface,
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(theme),
                    const SizedBox(height: 48),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLogin ? 'ACCESS GRANTED' : 'NEW OPERATIVE',
                              style: theme.textTheme.labelLarge?.copyWith(
                                letterSpacing: 2,
                                color: theme.hintColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (!_isLogin) ...[
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'DISPLAY NAME',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'EMAIL ADDRESS',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'PASSWORD',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () => _handleSubmit(context),
                                child: authProvider.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(_isLogin ? 'ENGAGE' : 'REGISTER'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton(
                                onPressed: () =>
                                    setState(() => _isLogin = !_isLogin),
                                child: Text(
                                  _isLogin
                                      ? "REQUEST NEW CLEARANCE (REGISTER)"
                                      : "ALREADY CLEARANCE (LOGIN)",
                                  style: const TextStyle(
                                      fontSize: 10, letterSpacing: 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Column(
      children: [
        Icon(Icons.security, size: 80, color: theme.colorScheme.primary)
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 2.seconds, color: Colors.white24),
        const SizedBox(height: 16),
        Text(
          'DECEPTION',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 40,
            letterSpacing: 8,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          'AUTHENTICATION PROTOCOL',
          style: theme.textTheme.bodySmall?.copyWith(
            letterSpacing: 4,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    try {
      if (_isLogin) {
        await auth.signIn(_emailController.text, _passwordController.text);
      } else {
        await auth.signUp(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PROTOCOL FAILURE: $e')),
        );
      }
    }
  }
}
