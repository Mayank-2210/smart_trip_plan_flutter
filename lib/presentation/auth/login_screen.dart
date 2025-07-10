import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<void> _login() async {
    try {
      final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      final user = userCred.user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              username: user.displayName ?? user.email?.split('@')[0] ?? 'User',
            ),
          ),
        );
      }
    } catch (e) {
      print("Login failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 12),
            TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
