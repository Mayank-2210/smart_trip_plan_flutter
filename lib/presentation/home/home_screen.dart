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

  /// Load saved itineraries from Firestore
  void _loadItineraries() async {
    final data = await firebaseService.getItineraries();
    setState(() => savedItineraries = data);
  }

  /// Generate itinerary using Ollama and track token usage
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

      // Approximate token count: 1 token ≈ 4 characters (very rough estimate)
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

  /// Save itinerary to Firestore
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

  /// Open first location on Google Maps
  void _openMap() {
    if (itineraryJson == null) return;

    final coords = itineraryJson!['days'][0]['items'][0]['location'];
    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$coords");

    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Delete itinerary from Firestore
  void _deleteItinerary(String id) async {
    await firebaseService.deleteItinerary(id);
    _loadItineraries();
  }

  /// Refine itinerary by putting previous prompt back
  void _refineItinerary() {
    _promptController.text = previousPrompt;
  }

  /// Share itinerary
  void _shareItinerary(String data) {
    Share.share(data);
  }

  /// Show saved itinerary full screen
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

  /// Show profile dialog with logout
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
            icon: const Icon(Icons.person),
            onPressed: _showProfileDialog,
            tooltip: "Profile",
          )
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hi ${widget.username},", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Where do you want to go?"),
                  const SizedBox(height: 16),

                  // PROMPT
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promptController,
                          decoration: const InputDecoration(
                            hintText: "Generate your itinerary",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isLoading ? null : _sendPrompt,
                        child: isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Go"),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ACTIONS
                  Row(
                    children: [
                      ElevatedButton(onPressed: _refineItinerary, child: const Text("Refine Itinerary")),
                      const SizedBox(width: 10),
                      ElevatedButton(onPressed: _saveItinerary, child: const Text("Save Itinerary")),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // GENERATED ITINERARY
                  if (itineraryJson != null)
                    Expanded(
                      child: Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: ListView(
                            children: [
                              Text(itineraryJson!['title'], style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text("${itineraryJson!['startDate']} → ${itineraryJson!['endDate']}"),
                              const SizedBox(height: 16),
                              for (var day in itineraryJson!['days']) ...[
                                Text("${day['date']} - ${day['summary']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                for (var item in day['items'])
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text("${item['time']} - ${item['activity']} (${item['location']})"),
                                  ),
                                const SizedBox(height: 12),
                              ],
                              ElevatedButton.icon(
                                onPressed: _openMap,
                                icon: const Icon(Icons.map),
                                label: const Text("Open First Location in Maps"),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  const Text("Your Saved Itineraries:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: savedItineraries.length,
                      itemBuilder: (context, index) {
                        final item = savedItineraries[index];
                        return GestureDetector(
                          onTap: () => _showSavedItinerary(item),
                          onLongPress: () => _deleteItinerary(item.id),
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              width: 200,
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _deleteItinerary(item.id)),
                                      IconButton(
                                          icon: const Icon(Icons.share),
                                          onPressed: () => _shareItinerary(item.jsonData)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // DEBUG OVERLAY FOR TOKENS
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
