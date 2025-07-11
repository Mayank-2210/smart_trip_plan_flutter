import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_trip_plan/models/itinerary_firestore_model.dart';
import 'package:smart_trip_plan/presentation/home/fullscreen_iternary.dart';
import 'package:smart_trip_plan/presentation/home/generating_screen.dart';
import 'package:smart_trip_plan/presentation/home/profile_screen.dart';
import 'package:smart_trip_plan/services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  List<ItineraryFirestoreModel> savedItineraries = [];

  @override
  void initState() {
    super.initState();
    _loadItineraries();
  }

  void _loadItineraries() async {
    final data = await _firebaseService.getItineraries();
    setState(() => savedItineraries = data);
  }

  void _navigateToGeneratingScreen() async {
  final prompt = _promptController.text.trim();
  if (prompt.isNotEmpty) {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GeneratingScreen(prompt: prompt, username: widget.username),
      ),
    );

    if (result == true) {
      _loadItineraries(); //Reload saved itineraries after saving
    }
  }
}

int totalTokensUsed = 0;
  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen(
        username: widget.username,
        email: FirebaseAuth.instance.currentUser?.email ?? 'N/A',
        totalTokens: totalTokensUsed,
        )),
    );
  }

  void _deleteItinerary(String id) async {
    await _firebaseService.deleteItinerary(id);
    _loadItineraries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF065F46),
        title: const Text("Smart Trip Planner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: _openProfile,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi ${widget.username},",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Where do you want to go?",
                style: TextStyle(fontSize: 16, color: Colors.grey)),

            const SizedBox(height: 20),

            // Prompt Box + Generate Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText: "Generate your itinerary",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _navigateToGeneratingScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF065F46),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Generate"),
                )
              ],
            ),

            const SizedBox(height: 30),

            const Text("Your Saved Itineraries:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            // Saved Itinerary Cards
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: savedItineraries.length,
                itemBuilder: (context, index) {
                  final item = savedItineraries[index];
return GestureDetector(
  onTap: () {
    final json = item.jsonData; // Already a JSON string
    final decoded = jsonDecode(json);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenItineraryScreen(itinerary: decoded),
      ),
    );
  },
  child: Container(
    width: 220,
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.prompt,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _deleteItinerary(item.id),
            ),
            IconButton(
              icon: const Icon(Icons.share, size: 20),
              onPressed: () {
                // optional: share logic
              },
            ),
          ],
        )
      ],
    ),
  ),
);

                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
