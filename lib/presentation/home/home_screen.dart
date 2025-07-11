import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_trip_plan/models/itinerary_firestore_model.dart';
import 'package:smart_trip_plan/services/firebase_service.dart';
import 'package:smart_trip_plan/services/ollama_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _promptController = TextEditingController();
  final ollamaService = OllamaService();
  final firebaseService = FirebaseService();

  Map<String, dynamic>? itineraryJson;
  List<ItineraryFirestoreModel> savedItineraries = [];

  bool isLoading = false;
  String previousPrompt = "";

  int totalTokensUsed = 0;
  int lastPromptTokens = 0;
  int lastResponseTokens = 0;

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadItineraries();
  }

  void _loadItineraries() async {
    final data = await firebaseService.getItineraries();
    setState(() => savedItineraries = data);
  }

  void _sendPrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      isLoading = true;
      itineraryJson = null;
    });

    try {
      final result = await ollamaService.generateItinerary(prompt);
      final responseJson = jsonEncode(result);

      lastPromptTokens = (prompt.length / 4).ceil();
      lastResponseTokens = (responseJson.length / 4).ceil();
      totalTokensUsed += lastPromptTokens + lastResponseTokens;

      setState(() {
        itineraryJson = result;
        previousPrompt = prompt;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Itinerary generated successfully")),
      );
    } catch (e) {
      print("AI Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate itinerary: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _saveItinerary() async {
    if (itineraryJson == null) return;

    final saved = ItineraryFirestoreModel(
      id: '',
      prompt: previousPrompt,
      jsonData: jsonEncode(itineraryJson),
      savedAt: DateTime.now(),
    );

    await firebaseService.saveItinerary(saved);
    _promptController.clear();
    _loadItineraries();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Itinerary saved")),
    );
  }

  void _openMap() {
    if (itineraryJson == null) return;

    final coords = itineraryJson!['days'][0]['items'][0]['location'];
    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$coords");

    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _deleteItinerary(String id) async {
    await firebaseService.deleteItinerary(id);
    _loadItineraries();
  }

  void _refineItinerary() {
    _promptController.text = previousPrompt;
  }

  void _shareItinerary(String data) {
    Share.share(data);
  }

  void _showSavedItinerary(ItineraryFirestoreModel itinerary) {
    final json = jsonDecode(itinerary.jsonData);
    showDialog(
      context: context,
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(itinerary.prompt),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(json['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("${json['startDate']} → ${json['endDate']}"),
              const SizedBox(height: 16),
              for (var day in json['days']) ...[
                Text("${day['date']} - ${day['summary']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                for (var item in day['items'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text("${item['time']} - ${item['activity']} (${item['location']})"),
                  ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${widget.username}"),
            Text("Email: ${currentUser?.email ?? 'N/A'}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("Logout"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Trip Planner"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: _showProfileDialog,
            tooltip: "Profile",
          )
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome, ${widget.username} 👋",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      )),
                  const SizedBox(height: 8),
                  const Text("Where would you like to go?", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText: "Enter your trip details",
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _sendPrompt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text("Generate Itinerary", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _refineItinerary,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Refine"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saveItinerary,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Save"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text("Saved Itineraries", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: savedItineraries.length,
                      itemBuilder: (context, index) {
                        final item = savedItineraries[index];
                        return GestureDetector(
                          onTap: () => _showSavedItinerary(item),
                          onLongPress: () => _deleteItinerary(item.id),
                          child: Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.prompt,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.share, size: 18),
                                    const SizedBox(width: 8),
                                    Icon(Icons.delete_outline, size: 18),
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
          ),

          if (kDebugMode)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "🔢 Tokens (last): P:$lastPromptTokens R:$lastResponseTokens\n📊 Total: $totalTokensUsed",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
