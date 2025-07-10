// lib/presentation/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:smart_trip_plan/services/auth_service.dart';
import 'login_screen.dart'; // ✅ NEW: Import LoginScreen

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  final authService = AuthService();

  /// Sign Up with Email/Password
  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        await authService.signUpWithEmail(
          emailController.text.trim(),
          passwordController.text.trim(),
          nameController.text.trim(),
          context,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign up successful")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign up failed: $e")),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  /// Google Sign In
  void _signInWithGoogle() async {
    setState(() => isLoading = true);

    try {
      await authService.signInWithGoogle(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signed in with Google")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-in failed: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 40),

                Text(
                  "Create your account",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text("Let’s plan your next adventure!",
                    style: theme.textTheme.bodyMedium),

                const SizedBox(height: 32),

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.contains('@')
                      ? null
                      : 'Please enter a valid email',
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.length < 6
                      ? 'Password must be 6+ characters'
                      : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _signUp,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Sign Up"),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        // ✅ NEW: Navigate to Login screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("or"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: Image.asset(
                      'assets/google_logo.png',
                      height: 20,
                    ),
                    label: const Text("Sign up with Google"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
