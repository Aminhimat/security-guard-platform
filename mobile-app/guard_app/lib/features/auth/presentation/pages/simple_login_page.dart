import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

class SimpleLoginPage extends StatefulWidget {
  const SimpleLoginPage({Key? key}) : super(key: key);

  @override
  State<SimpleLoginPage> createState() => _SimpleLoginPageState();
}

class _SimpleLoginPageState extends State<SimpleLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Security Guard Platform'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                const Icon(
                  Icons.security,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Sign In',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Email Field
                SizedBox(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Password Field
                SizedBox(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                
                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      
                      return ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Sign In', style: TextStyle(fontSize: 16)),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Demo Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(height: 8),
                      Text(
                        'Demo Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Use any email and password (6+ characters)\nExamples: admin@demo.com, guard@security.com',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    print('🎯 Login button pressed');
    if (_formKey.currentState?.validate() ?? false) {
      print('✅ Form validation passed');
      print('📧 Email: ${_emailController.text.trim()}');
      print('🔒 Password length: ${_passwordController.text.length}');
      
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    } else {
      print('❌ Form validation failed');
    }
  }
}
