import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../screens/register_page.dart';
import '../services/auth_service.dart';
import '../services/service_locator.dart';
import '../utils/error_handler.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/loading_overlay.dart';
import '../models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthService _authService;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    try {
      debugPrint('Initializing login page...');
      _authService = ServiceLocator().authService;
      debugPrint('Login page initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Error initializing login page: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return LoadingOverlay(
      isLoading: _isLoading,
      loadingText: 'Logging in...',
      child: Scaffold(
        appBar: const CommonAppBar(
          title: 'Event Management System',
          showLogout: false,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.background,
                colorScheme.primary.withOpacity(0.1),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'appLogo',
                        child: Icon(
                          Icons.event,
                          size: 80,
                          color: colorScheme.primary,
                        ),
                      ).animate()
                        .fadeIn(duration: const Duration(milliseconds: 600))
                        .scale(delay: const Duration(milliseconds: 200)),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ).animate()
                        .fadeIn(duration: const Duration(milliseconds: 600))
                        .slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        'Please sign in to continue',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ).animate()
                        .fadeIn(duration: const Duration(milliseconds: 600))
                        .slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 32),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => const RegisterPage(),
                                          ),
                                        );
                                      },
                                      child: const Text('Register New Account'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate()
                        .fadeIn(duration: const Duration(milliseconds: 800))
                        .slideY(begin: 0.3, end: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final success = await _authService.login(
          _usernameController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;

        if (success) {
          final user = _authService.currentUser;
          if (!mounted) return;
          
          // Show welcome message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${user?.name ?? "User"}!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Wait for message to be visible
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;

          switch (user?.type) {
            case UserType.admin:
              Navigator.pushReplacementNamed(context, '/admin');
              break;
            case UserType.teacher:
              Navigator.pushReplacementNamed(context, '/teacher');
              break;
            case UserType.student:
              Navigator.pushReplacementNamed(context, '/student');
              break;
            default:
              ErrorHandler.showError(
                context,
                'Unknown user type. Please contact administrator.',
              );
          }
        } else {
          ErrorHandler.showError(
            context,
            'Invalid username or password. Please try again.',
          );
        }
      } catch (e) {
        if (!mounted) return;
        ErrorHandler.showError(
          context,
          'An error occurred while logging in. Please try again.',
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}