import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ NEW: Firebase import
import '../auth/signup_screen.dart'; // ✅ NEW: For navigation after logout

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _tripController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // ✅ NEW: Logout logic
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hey ${widget.username} 👋",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "What’s your vision for this trip?",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tripController,
              decoration: InputDecoration(
                hintText: "e.g. 5 days in Bali, solo, mid-budget...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.green[800],
              ),
              onPressed: () {
                final vision = _tripController.text;
                if (vision.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Creating itinerary for: $vision")),
                  );
                }
              },
              child: const Text("Create My Itinerary"),
            ),
            const SizedBox(height: 24),
            const Text(
              "Offline Saved Itineraries",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text("Japan Trip, 10 days vacation"),
              subtitle: const Text("Explore Kyoto, Tokyo, and Mt. Fuji"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
