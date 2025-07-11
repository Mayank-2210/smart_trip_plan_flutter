// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../presentation/home/home_screen.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  // 🔐 Sign up with email & password
  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
    BuildContext context,
  ) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // ✅ Update display name
    await userCredential.user!.updateDisplayName(name);
    await userCredential.user!.reload(); // Refresh local user cache

    // ✅ Navigate to Home with username
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(username: name),
      ),
    );
  }

  // 🔐 Sign in with Google
  Future<void> signInWithGoogle(BuildContext context) async {
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    // ✅ Get display name with fallback
    final name = userCredential.user?.displayName ?? 'Traveler';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(username: name),
      ),
    );
  }

  // OPTIONAL: You can add logout here later
}
