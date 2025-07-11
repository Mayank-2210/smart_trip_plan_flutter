import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_trip_plan/presentation/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String username;
  final String email;
  final int totalTokens;


  const ProfileScreen({
    super.key,
    required this.username,
    required this.email,
    required this.totalTokens,

  });

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokenCost = (totalTokens * 0.0001).toStringAsFixed(4); // ₹ estimation

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F4),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF065F46),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("👤 User Info", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF065F46),
                  child: Icon(Icons.person, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Text("Token Usage", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _buildTokenCard("Total Tokens Used", totalTokens, Colors.teal),
            const SizedBox(height: 16),
            _buildTokenProgressBar("Prompt Tokens", (totalTokens * 0.4).toInt(), totalTokens, Colors.blue),
            const SizedBox(height: 10),
            _buildTokenProgressBar("Response Tokens", (totalTokens * 0.6).toInt(), totalTokens, Colors.green),
            const SizedBox(height: 12),
            Text("💰 Estimated Cost: ₹$tokenCost", style: const TextStyle(fontSize: 16)),

            const Spacer(),

            Center(
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF065F46),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// Progress Bar with Label
  Widget _buildTokenProgressBar(String label, int value, int max, Color color) {
    final percent = max == 0 ? 0.0 : value / max;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $value", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  /// Token Total Card
  Widget _buildTokenCard(String label, int value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text("$value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
